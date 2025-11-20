import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/models/chore_model.dart';
import 'package:flutter_app/repositories/chore_repository.dart';

class ChoreProvider extends ChangeNotifier {
  final ChoreRepository _choreRepository;
  final Uuid _uuid = const Uuid();

  ChoreProvider({required ChoreRepository choreRepository})
      : _choreRepository = choreRepository;

  List<ChoreModel> _chores = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<ChoreModel> get chores => _chores;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // 날짜별 집안일 가져오기
  List<ChoreModel> getChoresForDate(DateTime date) {
    return _chores.where((chore) {
      return chore.dueDate.year == date.year &&
          chore.dueDate.month == date.month &&
          chore.dueDate.day == date.day;
    }).toList();
  }

  // 선택된 날짜 변경
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // 가구의 모든 집안일 로드
  Future<void> loadChores(String householdId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _chores = await _choreRepository.getChoresByHousehold(householdId);
      _sortChores();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자별 집안일 로드
  Future<void> loadUserChores(String householdId, String userId) async {
    _chores = await _choreRepository.getChoresByUser(householdId, userId);
    _sortChores();
    notifyListeners();
  }

  // 집안일 생성
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

    await _choreRepository.createChore(chore);
    _chores.add(chore);
    _sortChores();
    notifyListeners();

    return chore;
  }

  // 집안일 업데이트
  Future<void> updateChore(ChoreModel chore) async {
    await _choreRepository.updateChore(chore);
    final index = _chores.indexWhere((c) => c.id == chore.id);
    if (index != -1) {
      _chores[index] = chore;
      _sortChores();
      notifyListeners();
    }
  }

  // 집안일 완료 (XP 지급 포함)
  Future<void> completeChore(String choreId, String userId) async {
    await _choreRepository.completeChore(choreId, userId);
    
    // Repository에서 최신 상태를 다시 가져오거나 로컬 상태 업데이트
    final updatedChore = await _choreRepository.getChore(choreId);
    if (updatedChore != null) {
      final index = _chores.indexWhere((c) => c.id == choreId);
      if (index != -1) {
        _chores[index] = updatedChore;
        notifyListeners();
      }
    }
  }

  // 집안일 삭제
  Future<void> deleteChore(String choreId) async {
    await _choreRepository.deleteChore(choreId);
    _chores.removeWhere((c) => c.id == choreId);
    notifyListeners();
  }

  // 집안일 정렬 (마감일순)
  void _sortChores() {
    _chores.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // 오늘의 집안일
  List<ChoreModel> getTodayChores() {
    final today = DateTime.now();
    return getChoresForDate(today);
  }

  // 진행 중인 집안일
  List<ChoreModel> getPendingChores() {
    return _chores.where((c) => c.status == ChoreStatus.pending).toList();
  }

  // 완료된 집안일
  List<ChoreModel> getCompletedChores() {
    return _chores.where((c) => c.status == ChoreStatus.completed).toList();
  }

  // 마감일 지난 집안일
  List<ChoreModel> getOverdueChores() {
    return _chores.where((c) => c.isOverdue()).toList();
  }

  // 통계
  Map<String, int> getStatistics() {
    return {
      'total': _chores.length,
      'pending': getPendingChores().length,
      'completed': getCompletedChores().length,
      'overdue': getOverdueChores().length,
    };
  }

  // 새로고침
  Future<void> refresh(String householdId) async {
    await loadChores(householdId);
  }

  // 초기화
  void clear() {
    _chores = [];
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
