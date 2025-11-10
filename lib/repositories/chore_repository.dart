/// Chore Repository
library;

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chore_model.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';

/// Chore Repository
///
/// Implements Repository pattern for Chore data
/// with cache-first strategy:
/// - Read: Hive cache first, then Firestore
/// - Write: Firestore first, then Hive cache
/// - Real-time: Firestore listeners update cache
class ChoreRepository {
  final FirestoreService _firestoreService;
  final Box<ChoreModel> _localCache;
  final _log = Log.get('ChoreRepository');

  static const String _collectionName = 'chores';

  ChoreRepository({
    required FirestoreService firestoreService,
    required Box<ChoreModel> localCache,
  })  : _firestoreService = firestoreService,
        _localCache = localCache;

  // ==================== CREATE ====================

  /// Create new chore
  Future<ChoreModel> createChore(ChoreModel chore) async {
    try {
      _log.info('Creating chore: ${chore.id}');

      // 1. Save to Firestore
      await _firestoreService.setDocument(
        _collectionName,
        chore.id,
        chore.toFirestore(),
      );

      // 2. Update local cache
      await _localCache.put(chore.id, chore);

      _log.info('Chore created successfully');
      return chore;
    } catch (e) {
      _log.error('Failed to create chore', e);
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get chore by ID (cache-first)
  Future<ChoreModel?> getChore(String choreId) async {
    try {
      _log.debug('Getting chore: $choreId');

      // 1. Try cache first
      final cachedChore = _localCache.get(choreId);
      if (cachedChore != null) {
        _log.debug('Chore found in cache');
        return cachedChore;
      }

      // 2. Fetch from Firestore
      final data = await _firestoreService.getDocument(
        _collectionName,
        choreId,
      );

      if (data == null) {
        _log.debug('Chore not found');
        return null;
      }

      // 3. Update cache
      final chore = ChoreModel.fromFirestoreMap(choreId, data);
      await _localCache.put(choreId, chore);

      return chore;
    } catch (e) {
      _log.error('Failed to get chore', e);
      rethrow;
    }
  }

  /// Get all chores for a household
  Future<List<ChoreModel>> getChoresByHousehold(String householdId) async {
    try {
      _log.debug('Getting chores for household: $householdId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (query) => query
            .where('householdId', isEqualTo: householdId)
            .orderBy('dueDate', descending: false),
      );

      final chores = docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        // Update cache
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();

      _log.debug('Found ${chores.length} chores');
      return chores;
    } catch (e) {
      _log.error('Failed to get chores by household', e);
      rethrow;
    }
  }

  /// Get pending chores for a household
  Future<List<ChoreModel>> getPendingChores(String householdId) async {
    try {
      _log.debug('Getting pending chores for household: $householdId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (query) => query
            .where('householdId', isEqualTo: householdId)
            .where('status', isEqualTo: 'pending')
            .orderBy('dueDate', descending: false),
      );

      final chores = docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();

      _log.debug('Found ${chores.length} pending chores');
      return chores;
    } catch (e) {
      _log.error('Failed to get pending chores', e);
      rethrow;
    }
  }

  /// Get chores assigned to a user
  Future<List<ChoreModel>> getChoresByUser(
    String householdId,
    String userId,
  ) async {
    try {
      _log.debug('Getting chores for user: $userId in household: $householdId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (query) => query
            .where('householdId', isEqualTo: householdId)
            .where('assignedUserId', isEqualTo: userId)
            .orderBy('dueDate', descending: false),
      );

      final chores = docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();

      _log.debug('Found ${chores.length} chores for user');
      return chores;
    } catch (e) {
      _log.error('Failed to get chores by user', e);
      rethrow;
    }
  }

  /// Get chores due today for a household
  Future<List<ChoreModel>> getChoresDueToday(String householdId) async {
    try {
      _log.debug('Getting chores due today for household: $householdId');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (query) => query
            .where('householdId', isEqualTo: householdId)
            .where('status', isEqualTo: 'pending')
            .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .orderBy('dueDate', descending: false),
      );

      final chores = docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();

      _log.debug('Found ${chores.length} chores due today');
      return chores;
    } catch (e) {
      _log.error('Failed to get chores due today', e);
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update chore
  Future<void> updateChore(ChoreModel chore) async {
    try {
      _log.info('Updating chore: ${chore.id}');

      // 1. Update Firestore
      await _firestoreService.setDocument(
        _collectionName,
        chore.id,
        chore.toFirestore(),
        merge: true,
      );

      // 2. Update cache
      await _localCache.put(chore.id, chore);

      _log.info('Chore updated successfully');
    } catch (e) {
      _log.error('Failed to update chore', e);
      rethrow;
    }
  }

  /// Complete chore (atomic operation with XP reward)
  Future<void> completeChore(String choreId, String userId) async {
    try {
      _log.info('Completing chore $choreId by user $userId');

      await _firestoreService.runTransaction((transaction) async {
        final docRef = _firestoreService.firestore
            .collection(_collectionName)
            .doc(choreId);

        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Chore not found');
        }

        final chore = ChoreModel.fromFirestore(snapshot);

        // Complete chore (updates status, completedAt, completedByUserId)
        chore.complete(userId);

        transaction.update(docRef, {
          'status': chore.status.name,
          'completedAt': Timestamp.fromDate(chore.completedAt!),
          'completedByUserId': chore.completedByUserId,
          'updatedAt': Timestamp.fromDate(chore.updatedAt),
        });

        // Update cache
        await _localCache.put(choreId, chore);
      });

      _log.info('Chore completed successfully');
    } catch (e) {
      _log.error('Failed to complete chore', e);
      rethrow;
    }
  }

  /// Assign chore to a user
  Future<void> assignChore(String choreId, String userId) async {
    try {
      _log.info('Assigning chore $choreId to user $userId');

      await _firestoreService.updateDocument(
        _collectionName,
        choreId,
        {
          'assignedUserId': userId,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      // Update cache
      final chore = await getChore(choreId);
      if (chore != null) {
        final updatedChore = chore.copyWith(
          assignedUserId: userId,
          updatedAt: DateTime.now(),
        );
        await _localCache.put(choreId, updatedChore);
      }

      _log.info('Chore assigned successfully');
    } catch (e) {
      _log.error('Failed to assign chore', e);
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete chore
  Future<void> deleteChore(String choreId) async {
    try {
      _log.warning('Deleting chore: $choreId');

      // 1. Delete from Firestore
      await _firestoreService.deleteDocument(_collectionName, choreId);

      // 2. Remove from cache
      await _localCache.delete(choreId);

      _log.info('Chore deleted successfully');
    } catch (e) {
      _log.error('Failed to delete chore', e);
      rethrow;
    }
  }

  // ==================== REAL-TIME ====================

  /// Watch chore (real-time updates)
  Stream<ChoreModel?> watchChore(String choreId) {
    _log.debug('Watching chore: $choreId');

    return _firestoreService
        .watchDocument(_collectionName, choreId)
        .map((snapshot) {
      if (!snapshot.exists) {
        // Remove from cache if deleted
        _localCache.delete(choreId);
        return null;
      }

      final chore = ChoreModel.fromFirestore(snapshot);

      // Update cache on every change
      _localCache.put(choreId, chore);

      return chore;
    });
  }

  /// Watch chores for a household (real-time)
  Stream<List<ChoreModel>> watchChoresByHousehold(String householdId) {
    _log.debug('Watching chores for household: $householdId');

    return _firestoreService.watchCollection(
      _collectionName,
      queryBuilder: (query) => query
          .where('householdId', isEqualTo: householdId)
          .orderBy('dueDate', descending: false),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);

        // Update cache on every change
        _localCache.put(chore.id, chore);

        return chore;
      }).toList();
    });
  }

  /// Watch pending chores for a household (real-time)
  Stream<List<ChoreModel>> watchPendingChores(String householdId) {
    _log.debug('Watching pending chores for household: $householdId');

    return _firestoreService.watchCollection(
      _collectionName,
      queryBuilder: (query) => query
          .where('householdId', isEqualTo: householdId)
          .where('status', isEqualTo: 'pending')
          .orderBy('dueDate', descending: false),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();
    });
  }

  /// Watch chores assigned to a user (real-time)
  Stream<List<ChoreModel>> watchChoresByUser(
    String householdId,
    String userId,
  ) {
    _log.debug('Watching chores for user: $userId in household: $householdId');

    return _firestoreService.watchCollection(
      _collectionName,
      queryBuilder: (query) => query
          .where('householdId', isEqualTo: householdId)
          .where('assignedUserId', isEqualTo: userId)
          .orderBy('dueDate', descending: false),
    ).map((snapshot) {
      return snapshot.docs.map((doc) {
        final chore = ChoreModel.fromFirestore(doc);
        _localCache.put(chore.id, chore);
        return chore;
      }).toList();
    });
  }

  // ==================== CACHE ====================

  /// Get chore from cache only
  ChoreModel? getFromCache(String choreId) {
    return _localCache.get(choreId);
  }

  /// Clear all cache
  Future<void> clearCache() async {
    _log.warning('Clearing chore cache');
    await _localCache.clear();
  }

  /// Refresh chore from Firestore (force cache update)
  Future<ChoreModel?> refreshChore(String choreId) async {
    try {
      _log.debug('Refreshing chore: $choreId');

      final data = await _firestoreService.getDocument(
        _collectionName,
        choreId,
      );

      if (data == null) {
        await _localCache.delete(choreId);
        return null;
      }

      final chore = ChoreModel.fromFirestoreMap(choreId, data);
      await _localCache.put(choreId, chore);

      return chore;
    } catch (e) {
      _log.error('Failed to refresh chore', e);
      rethrow;
    }
  }
}
