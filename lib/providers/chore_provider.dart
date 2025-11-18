import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chore_model.dart';
import '../repositories/chore_repository.dart';

/// ChoreProvider - State management for chores
///
/// Manages chore list state and operations using ChoreRepository
/// Migrated from DatabaseService to ChoreRepository (Phase 2)
class ChoreProvider extends ChangeNotifier {
  final ChoreRepository _choreRepository;
  final Uuid _uuid = const Uuid();

  List<ChoreModel> _chores = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _currentHouseholdId;

  ChoreProvider({required ChoreRepository choreRepository})
      : _choreRepository = choreRepository;

  List<ChoreModel> get chores => _chores;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get currentHouseholdId => _currentHouseholdId;

  // ==================== DATE FILTERING ====================

  /// Get chores for a specific date
  List<ChoreModel> getChoresForDate(DateTime date) {
    return _chores.where((chore) {
      return chore.dueDate.year == date.year &&
          chore.dueDate.month == date.month &&
          chore.dueDate.day == date.day;
    }).toList();
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // ==================== LOAD OPERATIONS ====================

  /// Load all chores for a household
  Future<void> loadChores(String householdId) async {
    _isLoading = true;
    _currentHouseholdId = householdId;
    notifyListeners();

    try {
      _chores = await _choreRepository.getChoresByHousehold(householdId);
      _sortChores();
    } catch (e) {
      debugPrint('Error loading chores: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load chores assigned to a specific user
  Future<void> loadUserChores(String householdId, String userId) async {
    _isLoading = true;
    _currentHouseholdId = householdId;
    notifyListeners();

    try {
      _chores = await _choreRepository.getChoresByUser(householdId, userId);
      _sortChores();
    } catch (e) {
      debugPrint('Error loading user chores: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load chores by date range
  Future<void> loadChoresByDateRange(
    String householdId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _currentHouseholdId = householdId;
    notifyListeners();

    try {
      _chores = await _choreRepository.getChoresByDateRange(
        householdId,
        startDate,
        endDate,
      );
      _sortChores();
    } catch (e) {
      debugPrint('Error loading chores by date range: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load pending chores for a household
  Future<void> loadPendingChores(String householdId) async {
    _isLoading = true;
    _currentHouseholdId = householdId;
    notifyListeners();

    try {
      _chores = await _choreRepository.getPendingChores(householdId);
      _sortChores();
    } catch (e) {
      debugPrint('Error loading pending chores: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Create a new chore
  Future<ChoreModel> createChore({
    required String title,
    String? description,
    required String householdId,
    String? assignedUserId,
    ChoreDifficulty difficulty = ChoreDifficulty.medium,
    required DateTime dueDate,
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    final chore = ChoreModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      householdId: householdId,
      assignedUserId: assignedUserId,
      difficulty: difficulty,
      dueDate: dueDate,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
    );

    try {
      await _choreRepository.createChore(chore);
      _chores.add(chore);
      _sortChores();
      notifyListeners();
      return chore;
    } catch (e) {
      debugPrint('Error creating chore: $e');
      rethrow;
    }
  }

  /// Update an existing chore
  Future<void> updateChore(ChoreModel chore) async {
    try {
      await _choreRepository.updateChore(chore);
      final index = _chores.indexWhere((c) => c.id == chore.id);
      if (index != -1) {
        _chores[index] = chore;
        _sortChores();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating chore: $e');
      rethrow;
    }
  }

  /// Complete a chore and return XP reward
  ///
  /// Note: XP is actually awarded by the Cloud Function trigger
  /// This method just completes the chore and returns the theoretical XP
  Future<int> completeChore(String choreId, String userId) async {
    try {
      // Find chore first to get XP reward before completion
      final choreIndex = _chores.indexWhere((c) => c.id == choreId);
      if (choreIndex == -1) {
        // Try to fetch from repository
        final chore = await _choreRepository.getChore(choreId);
        if (chore == null) {
          throw Exception('Chore not found: $choreId');
        }
        final xpReward = chore.getXpReward();

        // Complete chore
        await _choreRepository.completeChore(choreId, userId);

        // Refresh to get updated state
        if (_currentHouseholdId != null) {
          await loadChores(_currentHouseholdId!);
        }

        return xpReward;
      }

      final chore = _chores[choreIndex];
      final xpReward = chore.getXpReward();

      // Complete chore in repository
      await _choreRepository.completeChore(choreId, userId);

      // Update local state
      final updatedChore = await _choreRepository.getChore(choreId);
      if (updatedChore != null) {
        _chores[choreIndex] = updatedChore;
        notifyListeners();
      }

      return xpReward;
    } catch (e) {
      debugPrint('Error completing chore: $e');
      rethrow;
    }
  }

  /// Delete a chore
  Future<void> deleteChore(String choreId) async {
    try {
      await _choreRepository.deleteChore(choreId);
      _chores.removeWhere((c) => c.id == choreId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting chore: $e');
      rethrow;
    }
  }

  // ==================== FILTERING & SORTING ====================

  /// Sort chores by due date (ascending)
  void _sortChores() {
    _chores.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Get today's chores
  List<ChoreModel> getTodayChores() {
    final today = DateTime.now();
    return getChoresForDate(today);
  }

  /// Get pending chores (from local cache)
  List<ChoreModel> getPendingChores() {
    return _chores.where((c) => c.status == ChoreStatus.pending).toList();
  }

  /// Get completed chores (from local cache)
  List<ChoreModel> getCompletedChores() {
    return _chores.where((c) => c.status == ChoreStatus.completed).toList();
  }

  /// Get overdue chores (from local cache)
  List<ChoreModel> getOverdueChores() {
    return _chores.where((c) => c.isOverdue()).toList();
  }

  // ==================== STATISTICS ====================

  /// Get chore statistics
  Map<String, int> getStatistics() {
    return {
      'total': _chores.length,
      'pending': getPendingChores().length,
      'completed': getCompletedChores().length,
      'overdue': getOverdueChores().length,
    };
  }

  // ==================== REFRESH & CLEAR ====================

  /// Refresh chores for current household
  Future<void> refresh(String householdId) async {
    await loadChores(householdId);
  }

  /// Clear all local state
  void clear() {
    _chores = [];
    _selectedDate = DateTime.now();
    _currentHouseholdId = null;
    notifyListeners();
  }
}
