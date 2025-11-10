import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/models/household_model.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/repositories/household_repository.dart';
import 'package:flutter_app/repositories/user_repository.dart';
import 'package:flutter_app/utils/logger.dart';

/// Household Provider
///
/// Manages household state using:
/// - HouseholdRepository for household data (Firestore + Hive cache)
/// - UserRepository for member data
/// - Real-time sync with Firestore listeners
class HouseholdProvider extends ChangeNotifier {
  final HouseholdRepository _householdRepository;
  final UserRepository _userRepository;
  final _log = Log.get('HouseholdProvider');
  final Uuid _uuid = const Uuid();

  StreamSubscription<HouseholdModel?>? _householdSubscription;
  StreamSubscription<List<UserModel>>? _membersSubscription;

  HouseholdModel? _currentHousehold;
  HouseholdModel? get currentHousehold => _currentHousehold;

  List<UserModel> _members = [];
  List<UserModel> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HouseholdProvider({
    required HouseholdRepository householdRepository,
    required UserRepository userRepository,
  })  : _householdRepository = householdRepository,
        _userRepository = userRepository;

  // ==================== Household Management ====================

  /// Create a new household
  Future<HouseholdModel> createHousehold({
    required String name,
    String? description,
    required String creatorId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Creating household: $name');

      final household = HouseholdModel(
        id: _uuid.v4(),
        name: name,
        description: description,
        creatorId: creatorId,
      );

      await _householdRepository.createHousehold(household);

      // Start watching this household
      await watchHousehold(household.id);

      _isLoading = false;
      notifyListeners();

      _log.info('Household created successfully');
      return household;
    } catch (e) {
      _log.error('Failed to create household', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Load and watch a specific household
  Future<void> loadHousehold(String householdId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Loading household: $householdId');

      // Start watching household and members
      await watchHousehold(householdId);

      _isLoading = false;
      notifyListeners();

      _log.info('Household loaded successfully');
    } catch (e) {
      _log.error('Failed to load household', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Watch household for real-time updates
  Future<void> watchHousehold(String householdId) async {
    _log.info('Starting household watch: $householdId');

    // Cancel existing subscriptions
    await _householdSubscription?.cancel();
    await _membersSubscription?.cancel();

    // Watch household
    _householdSubscription = _householdRepository
        .watchHousehold(householdId)
        .listen(
      (household) {
        _log.debug('Household updated: ${household?.id}');
        _currentHousehold = household;
        notifyListeners();
      },
      onError: (error) {
        _log.error('Household watch error', error);
      },
    );

    // Watch members
    _membersSubscription = _userRepository
        .watchUsersByHousehold(householdId)
        .listen(
      (members) {
        _log.debug('Members updated: ${members.length} members');
        _members = members;
        notifyListeners();
      },
      onError: (error) {
        _log.error('Members watch error', error);
      },
    );
  }

  /// Update household information
  Future<void> updateHousehold({
    String? name,
    String? description,
  }) async {
    if (_currentHousehold == null) {
      _log.warning('Cannot update household: no household loaded');
      return;
    }

    try {
      _log.info('Updating household: ${_currentHousehold!.id}');

      final updatedHousehold = _currentHousehold!.copyWith(
        name: name,
        description: description,
      );

      await _householdRepository.updateHousehold(updatedHousehold);

      // Real-time listener will update _currentHousehold automatically
      _log.info('Household updated successfully');
    } catch (e) {
      _log.error('Failed to update household', e);
      rethrow;
    }
  }

  /// Delete the current household
  Future<void> deleteHousehold() async {
    if (_currentHousehold == null) {
      _log.warning('Cannot delete household: no household loaded');
      return;
    }

    try {
      _log.info('Deleting household: ${_currentHousehold!.id}');

      final householdId = _currentHousehold!.id;

      // Repository will handle removing household from all members
      await _householdRepository.deleteHousehold(householdId);

      // Clear local state
      await stopWatching();
      _currentHousehold = null;
      _members = [];
      notifyListeners();

      _log.info('Household deleted successfully');
    } catch (e) {
      _log.error('Failed to delete household', e);
      rethrow;
    }
  }

  // ==================== Member Management ====================

  /// Add a member to the household
  Future<void> addMember(String userId) async {
    if (_currentHousehold == null) {
      _log.warning('Cannot add member: no household loaded');
      return;
    }

    try {
      _log.info('Adding member: $userId to ${_currentHousehold!.id}');

      // Use repository's transaction method
      await _householdRepository.addMember(_currentHousehold!.id, userId);

      // Real-time listeners will update automatically
      _log.info('Member added successfully');
    } catch (e) {
      _log.error('Failed to add member', e);
      rethrow;
    }
  }

  /// Remove a member from the household
  Future<void> removeMember(String userId) async {
    if (_currentHousehold == null) {
      _log.warning('Cannot remove member: no household loaded');
      return;
    }

    try {
      _log.info('Removing member: $userId from ${_currentHousehold!.id}');

      // Use repository's transaction method
      await _householdRepository.removeMember(_currentHousehold!.id, userId);

      // Real-time listeners will update automatically
      _log.info('Member removed successfully');
    } catch (e) {
      _log.error('Failed to remove member', e);
      rethrow;
    }
  }

  // ==================== Leaderboard ====================

  /// Get leaderboard (cached)
  List<UserModel> getLeaderboard() {
    if (_currentHousehold == null) return [];

    // Sort members by level (descending) and XP (descending)
    final sortedMembers = List<UserModel>.from(_members);
    sortedMembers.sort((a, b) {
      if (a.level != b.level) {
        return b.level.compareTo(a.level);
      }
      return b.xp.compareTo(a.xp);
    });

    return sortedMembers;
  }

  /// Watch leaderboard for real-time updates
  Stream<List<UserModel>> watchLeaderboard({int limit = 10}) {
    if (_currentHousehold == null) {
      _log.warning('Cannot watch leaderboard: no household loaded');
      return Stream.value([]);
    }

    return _userRepository.watchLeaderboard(_currentHousehold!.id, limit: limit);
  }

  // ==================== Utility ====================

  /// Refresh household data from Firestore
  Future<void> refresh() async {
    if (_currentHousehold == null) {
      _log.warning('Cannot refresh: no household loaded');
      return;
    }

    try {
      _log.info('Refreshing household: ${_currentHousehold!.id}');

      // Refresh cache from Firestore
      await _householdRepository.refreshHousehold(_currentHousehold!.id);

      // Get updated data
      final refreshedHousehold = await _householdRepository.getHousehold(_currentHousehold!.id);
      if (refreshedHousehold != null) {
        _currentHousehold = refreshedHousehold;
      }

      // Refresh members
      final refreshedMembers = await _userRepository.getUsersByHousehold(_currentHousehold!.id);
      _members = refreshedMembers;

      notifyListeners();

      _log.info('Household refreshed successfully');
    } catch (e) {
      _log.error('Failed to refresh household', e);
      rethrow;
    }
  }

  /// Stop watching household and clear state
  Future<void> stopWatching() async {
    _log.info('Stopping household watch');
    await _householdSubscription?.cancel();
    await _membersSubscription?.cancel();
    _householdSubscription = null;
    _membersSubscription = null;
  }

  /// Clear current household and members
  void clear() {
    _log.info('Clearing household state');
    stopWatching();
    _currentHousehold = null;
    _members = [];
    notifyListeners();
  }

  // ==================== Lifecycle ====================

  @override
  void dispose() {
    _log.info('Disposing HouseholdProvider');
    stopWatching();
    super.dispose();
  }
}
