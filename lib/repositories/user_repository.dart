/// User Repository
///
/// Manages user data with Firestore (remote) and Hive (local cache)
library;

import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/logger.dart';

/// User Repository
///
/// Implements Repository pattern with:
/// - Firestore as remote source of truth
/// - Hive as local cache for offline support
/// - Cache-first read strategy
class UserRepository {
  final FirestoreService _firestoreService;
  final Box<UserModel> _localCache;
  final _log = Log.get('UserRepository');

  static const String _collectionName = 'users';

  UserRepository(this._firestoreService, this._localCache);

  // ==================== Create ====================

  /// Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      _log.info('Creating user: ${user.id}');

      // 1. Create in Firestore
      await _firestoreService.setDocument(
        _collectionName,
        user.id,
        user.toFirestore(),
      );

      // 2. Update local cache
      await _localCache.put(user.id, user);

      _log.info('User created successfully');
    } catch (e) {
      _log.error('Failed to create user', e);
      rethrow;
    }
  }

  // ==================== Read ====================

  /// Get user by ID (cache-first strategy)
  Future<UserModel?> getUser(String userId) async {
    try {
      _log.debug('Getting user: $userId');

      // 1. Try local cache first
      final cachedUser = _localCache.get(userId);
      if (cachedUser != null) {
        _log.debug('User found in cache');
        return cachedUser;
      }

      // 2. Fetch from Firestore
      _log.debug('Fetching from Firestore');
      final data = await _firestoreService.getDocument(_collectionName, userId);

      if (data == null) {
        _log.debug('User not found');
        return null;
      }

      // 3. Update cache
      final user = UserModel.fromFirestoreMap(userId, data);
      await _localCache.put(userId, user);

      _log.debug('User fetched and cached');
      return user;
    } catch (e) {
      _log.error('Failed to get user: $userId', e);
      rethrow;
    }
  }

  /// Watch user (real-time updates)
  Stream<UserModel?> watchUser(String userId) {
    _log.debug('Watching user: $userId');

    return _firestoreService
        .watchDocument(_collectionName, userId)
        .map((snapshot) {
      if (!snapshot.exists) return null;

      final user = UserModel.fromFirestore(snapshot);

      // Update cache in background
      _localCache.put(userId, user).catchError((e) {
        _log.warning('Failed to update cache', e);
      });

      return user;
    });
  }

  /// Get users by household ID
  Future<List<UserModel>> getUsersByHousehold(String householdId) async {
    try {
      _log.debug('Getting users for household: $householdId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (ref) =>
            ref.where('householdId', isEqualTo: householdId),
      );

      final userModels = docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Update cache
      for (final user in userModels) {
        await _localCache.put(user.id, user);
      }

      return userModels;
    } catch (e) {
      _log.error('Failed to get users by household', e);
      rethrow;
    }
  }

  /// Get users by household ID (real-time)
  Stream<List<UserModel>> watchUsersByHousehold(String householdId) {
    _log.debug('Watching users for household: $householdId');

    return _firestoreService
        .watchCollection(
          _collectionName,
          queryBuilder: (ref) =>
              ref.where('householdId', isEqualTo: householdId),
        )
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Update cache in background
      for (final user in users) {
        _localCache.put(user.id, user).catchError((e) {
          _log.warning('Failed to update cache', e);
        });
      }

      return users;
    });
  }

  /// Get leaderboard (users sorted by XP)
  Future<List<UserModel>> getLeaderboard(String householdId, {int limit = 10}) async {
    try {
      _log.debug('Getting leaderboard for household: $householdId');

      final docs = await _firestoreService.getCollectionDocs(
        _collectionName,
        queryBuilder: (ref) => ref
            .where('householdId', isEqualTo: householdId)
            .orderBy('xp', descending: true)
            .limit(limit),
      );

      return docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _log.error('Failed to get leaderboard', e);
      rethrow;
    }
  }

  /// Watch leaderboard (real-time)
  Stream<List<UserModel>> watchLeaderboard(String householdId, {int limit = 10}) {
    _log.debug('Watching leaderboard for household: $householdId');

    return _firestoreService
        .watchCollection(
          _collectionName,
          queryBuilder: (ref) => ref
              .where('householdId', isEqualTo: householdId)
              .orderBy('xp', descending: true)
              .limit(limit),
        )
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }

  // ==================== Update ====================

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      _log.debug('Updating user: ${user.id}');

      // 1. Update Firestore
      await _firestoreService.setDocument(
        _collectionName,
        user.id,
        user.toFirestore(),
        merge: true,
      );

      // 2. Update cache
      await _localCache.put(user.id, user);

      _log.debug('User updated successfully');
    } catch (e) {
      _log.error('Failed to update user: ${user.id}', e);
      rethrow;
    }
  }

  /// Update user fields (partial update)
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      _log.debug('Updating user fields: $userId');

      // Add updatedAt timestamp
      final updateData = {
        ...fields,
        'updatedAt': Timestamp.now(),
      };

      // 1. Update Firestore
      await _firestoreService.updateDocument(
        _collectionName,
        userId,
        updateData,
      );

      // 2. Invalidate cache (will be refreshed on next read)
      await _localCache.delete(userId);

      _log.debug('User fields updated successfully');
    } catch (e) {
      _log.error('Failed to update user fields: $userId', e);
      rethrow;
    }
  }

  /// Increment XP (atomic operation)
  Future<void> incrementXp(String userId, int amount) async {
    try {
      _log.debug('Incrementing XP for user: $userId by $amount');

      // Use Firestore transaction for atomic increment
      await _firestoreService.runTransaction((transaction) async {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(userId);

        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('User not found: $userId');
        }

        final user = UserModel.fromFirestore(snapshot);
        user.gainXp(amount);

        transaction.update(docRef, {
          'xp': user.xp,
          'level': user.level,
          'lastActivityAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Update cache
        await _localCache.put(userId, user);
      });

      _log.debug('XP incremented successfully');
    } catch (e) {
      _log.error('Failed to increment XP', e);
      rethrow;
    }
  }

  // ==================== Delete ====================

  /// Delete user (soft delete - mark as deleted)
  Future<void> deleteUser(String userId) async {
    try {
      _log.warning('Deleting user: $userId');

      // Soft delete: update status instead of actual deletion
      await updateUserFields(userId, {
        'deletedAt': Timestamp.now(),
      });

      // Remove from cache
      await _localCache.delete(userId);

      _log.info('User deleted successfully');
    } catch (e) {
      _log.error('Failed to delete user: $userId', e);
      rethrow;
    }
  }

  /// Hard delete user (permanent deletion)
  Future<void> hardDeleteUser(String userId) async {
    try {
      _log.warning('Hard deleting user: $userId');

      // 1. Delete from Firestore
      await _firestoreService.deleteDocument(_collectionName, userId);

      // 2. Remove from cache
      await _localCache.delete(userId);

      _log.info('User hard deleted successfully');
    } catch (e) {
      _log.error('Failed to hard delete user: $userId', e);
      rethrow;
    }
  }

  // ==================== Cache Management ====================

  /// Clear local cache
  Future<void> clearCache() async {
    _log.info('Clearing user cache');
    await _localCache.clear();
  }

  /// Get cached user (no network call)
  UserModel? getCachedUser(String userId) {
    return _localCache.get(userId);
  }

  /// Refresh cache from Firestore
  Future<void> refreshCache(String userId) async {
    _log.debug('Refreshing cache for user: $userId');

    final data = await _firestoreService.getDocument(_collectionName, userId);
    if (data != null) {
      final user = UserModel.fromFirestoreMap(userId, data);
      await _localCache.put(userId, user);
    }
  }
}
