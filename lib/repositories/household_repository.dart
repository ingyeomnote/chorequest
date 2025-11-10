/// Household Repository
library;

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/household_model.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';

/// Household Repository
///
/// Implements Repository pattern for Household data
/// with cache-first strategy:
/// - Read: Hive cache first, then Firestore
/// - Write: Firestore first, then Hive cache
/// - Real-time: Firestore listeners update cache
class HouseholdRepository {
  final FirestoreService _firestoreService;
  final Box<HouseholdModel> _localCache;
  final _log = Log.get('HouseholdRepository');

  static const String _collectionName = 'households';

  HouseholdRepository({
    required FirestoreService firestoreService,
    required Box<HouseholdModel> localCache,
  })  : _firestoreService = firestoreService,
        _localCache = localCache;

  // ==================== CREATE ====================

  /// Create new household
  Future<HouseholdModel> createHousehold(HouseholdModel household) async {
    try {
      _log.info('Creating household: ${household.id}');

      // 1. Save to Firestore
      await _firestoreService.setDocument(
        _collectionName,
        household.id,
        household.toFirestore(),
      );

      // 2. Update local cache
      await _localCache.put(household.id, household);

      _log.info('Household created successfully');
      return household;
    } catch (e) {
      _log.error('Failed to create household', e);
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get household by ID (cache-first)
  Future<HouseholdModel?> getHousehold(String householdId) async {
    try {
      _log.debug('Getting household: $householdId');

      // 1. Try cache first
      final cachedHousehold = _localCache.get(householdId);
      if (cachedHousehold != null) {
        _log.debug('Household found in cache');
        return cachedHousehold;
      }

      // 2. Fetch from Firestore
      final data = await _firestoreService.getDocument(
        _collectionName,
        householdId,
      );

      if (data == null) {
        _log.debug('Household not found');
        return null;
      }

      // 3. Update cache
      final household = HouseholdModel.fromFirestoreMap(householdId, data);
      await _localCache.put(householdId, household);

      return household;
    } catch (e) {
      _log.error('Failed to get household', e);
      rethrow;
    }
  }

  /// Get all households for a user (by memberIds)
  Future<List<HouseholdModel>> getHouseholdsForUser(String userId) async {
    try {
      _log.debug('Getting households for user: $userId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (query) => query.where('memberIds', arrayContains: userId),
      );

      final households = docs.map((doc) {
        final household = HouseholdModel.fromFirestore(doc);
        // Update cache
        _localCache.put(household.id, household);
        return household;
      }).toList();

      _log.debug('Found ${households.length} households');
      return households;
    } catch (e) {
      _log.error('Failed to get households for user', e);
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update household
  Future<void> updateHousehold(HouseholdModel household) async {
    try {
      _log.info('Updating household: ${household.id}');

      // 1. Update Firestore
      await _firestoreService.setDocument(
        _collectionName,
        household.id,
        household.toFirestore(),
        merge: true,
      );

      // 2. Update cache
      await _localCache.put(household.id, household);

      _log.info('Household updated successfully');
    } catch (e) {
      _log.error('Failed to update household', e);
      rethrow;
    }
  }

  /// Add member to household
  Future<void> addMember(String householdId, String userId) async {
    try {
      _log.info('Adding member $userId to household $householdId');

      await _firestoreService.runTransaction((transaction) async {
        final docRef = _firestoreService.firestore
            .collection(_collectionName)
            .doc(householdId);

        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Household not found');
        }

        final household = HouseholdModel.fromFirestore(snapshot);

        // Add member (method updates memberIds and memberCount)
        household.addMember(userId);

        transaction.update(docRef, {
          'memberIds': household.memberIds,
          'memberCount': household.memberCount,
          'updatedAt': Timestamp.fromDate(household.updatedAt),
        });

        // Update cache
        await _localCache.put(householdId, household);
      });

      _log.info('Member added successfully');
    } catch (e) {
      _log.error('Failed to add member', e);
      rethrow;
    }
  }

  /// Remove member from household
  Future<void> removeMember(String householdId, String userId) async {
    try {
      _log.info('Removing member $userId from household $householdId');

      await _firestoreService.runTransaction((transaction) async {
        final docRef = _firestoreService.firestore
            .collection(_collectionName)
            .doc(householdId);

        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Household not found');
        }

        final household = HouseholdModel.fromFirestore(snapshot);

        // Remove member
        household.removeMember(userId);

        transaction.update(docRef, {
          'memberIds': household.memberIds,
          'memberCount': household.memberCount,
          'updatedAt': Timestamp.fromDate(household.updatedAt),
        });

        // Update cache
        await _localCache.put(householdId, household);
      });

      _log.info('Member removed successfully');
    } catch (e) {
      _log.error('Failed to remove member', e);
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete household
  Future<void> deleteHousehold(String householdId) async {
    try {
      _log.warning('Deleting household: $householdId');

      // 1. Delete from Firestore
      await _firestoreService.deleteDocument(_collectionName, householdId);

      // 2. Remove from cache
      await _localCache.delete(householdId);

      _log.info('Household deleted successfully');
    } catch (e) {
      _log.error('Failed to delete household', e);
      rethrow;
    }
  }

  // ==================== REAL-TIME ====================

  /// Watch household (real-time updates)
  Stream<HouseholdModel?> watchHousehold(String householdId) {
    _log.debug('Watching household: $householdId');

    return _firestoreService
        .watchDocument(_collectionName, householdId)
        .map((snapshot) {
      if (!snapshot.exists) {
        // Remove from cache if deleted
        _localCache.delete(householdId);
        return null;
      }

      final household = HouseholdModel.fromFirestore(snapshot);

      // Update cache on every change
      _localCache.put(householdId, household);

      return household;
    });
  }

  /// Watch households for a user (real-time)
  Stream<List<HouseholdModel>> watchHouseholdsForUser(String userId) {
    _log.debug('Watching households for user: $userId');

    return _firestoreService.watchCollection(
      _collectionName,
      queryBuilder: (query) => query.where('memberIds', arrayContains: userId),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final household = HouseholdModel.fromFirestore(doc);

        // Update cache on every change
        _localCache.put(household.id, household);

        return household;
      }).toList();
    });
  }

  // ==================== CACHE ====================

  /// Get household from cache only
  HouseholdModel? getFromCache(String householdId) {
    return _localCache.get(householdId);
  }

  /// Clear all cache
  Future<void> clearCache() async {
    _log.warning('Clearing household cache');
    await _localCache.clear();
  }

  /// Refresh household from Firestore (force cache update)
  Future<HouseholdModel?> refreshHousehold(String householdId) async {
    try {
      _log.debug('Refreshing household: $householdId');

      final data = await _firestoreService.getDocument(
        _collectionName,
        householdId,
      );

      if (data == null) {
        await _localCache.delete(householdId);
        return null;
      }

      final household = HouseholdModel.fromFirestoreMap(householdId, data);
      await _localCache.put(householdId, household);

      return household;
    } catch (e) {
      _log.error('Failed to refresh household', e);
      rethrow;
    }
  }
}
