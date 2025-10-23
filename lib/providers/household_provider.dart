import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/models/household_model.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/services/database_service.dart';

class HouseholdProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  HouseholdModel? _currentHousehold;
  List<UserModel> _members = [];

  HouseholdModel? get currentHousehold => _currentHousehold;
  List<UserModel> get members => _members;

  // 가구 생성
  Future<HouseholdModel> createHousehold({
    required String name,
    String? description,
    required String creatorId,
  }) async {
    final household = HouseholdModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      creatorId: creatorId,
    );

    await _db.createHousehold(household);
    _currentHousehold = household;
    await _loadMembers();
    notifyListeners();

    return household;
  }

  // 가구 로드
  Future<void> loadHousehold(String householdId) async {
    _currentHousehold = _db.getHousehold(householdId);
    await _loadMembers();
    notifyListeners();
  }

  // 멤버 로드
  Future<void> _loadMembers() async {
    if (_currentHousehold == null) {
      _members = [];
      return;
    }

    _members = _db.getUsersByHousehold(_currentHousehold!.id);
  }

  // 가구 업데이트
  Future<void> updateHousehold({
    String? name,
    String? description,
  }) async {
    if (_currentHousehold == null) return;

    _currentHousehold = _currentHousehold!.copyWith(
      name: name,
      description: description,
    );

    await _db.updateHousehold(_currentHousehold!);
    notifyListeners();
  }

  // 멤버 추가
  Future<void> addMember(String userId) async {
    if (_currentHousehold == null) return;

    _currentHousehold!.addMember(userId);
    await _db.updateHousehold(_currentHousehold!);

    // Update user's householdId
    final user = _db.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(householdId: _currentHousehold!.id);
      await _db.updateUser(updatedUser);
    }

    await _loadMembers();
    notifyListeners();
  }

  // 멤버 제거
  Future<void> removeMember(String userId) async {
    if (_currentHousehold == null) return;

    _currentHousehold!.removeMember(userId);
    await _db.updateHousehold(_currentHousehold!);

    // Update user's householdId
    final user = _db.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(householdId: '');
      await _db.updateUser(updatedUser);
    }

    await _loadMembers();
    notifyListeners();
  }

  // 가구 삭제
  Future<void> deleteHousehold() async {
    if (_currentHousehold == null) return;

    // Remove household from all members
    for (final userId in _currentHousehold!.memberIds) {
      final user = _db.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(householdId: '');
        await _db.updateUser(updatedUser);
      }
    }

    await _db.deleteHousehold(_currentHousehold!.id);
    _currentHousehold = null;
    _members = [];
    notifyListeners();
  }

  // 리더보드 가져오기
  List<UserModel> getLeaderboard() {
    if (_currentHousehold == null) return [];
    return _db.getLeaderboard(_currentHousehold!.id);
  }

  // 새로고침
  Future<void> refresh() async {
    if (_currentHousehold != null) {
      await loadHousehold(_currentHousehold!.id);
    }
  }

  // 초기화
  void clear() {
    _currentHousehold = null;
    _members = [];
    notifyListeners();
  }
}
