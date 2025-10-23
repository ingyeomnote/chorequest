import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // 초기화 (앱 시작시 저장된 사용자 로드)
  Future<void> initialize() async {
    final currentUserId = _db.getCurrentUserId();
    if (currentUserId != null) {
      _currentUser = _db.getUser(currentUserId);
      notifyListeners();
    }
  }

  // 회원가입 (로컬)
  Future<UserModel> register(String name, String email) async {
    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
    );

    await _db.createUser(user);
    await _db.setCurrentUserId(user.id);
    _currentUser = user;
    notifyListeners();

    return user;
  }

  // 로그인 (이메일로 검색)
  Future<UserModel?> login(String email) async {
    final users = _db.getAllUsers();
    final user = users.cast<UserModel?>().firstWhere(
      (u) => u?.email == email,
      orElse: () => null,
    );

    if (user != null) {
      await _db.setCurrentUserId(user.id);
      _currentUser = user;
      notifyListeners();
    }

    return user;
  }

  // 로그아웃
  Future<void> logout() async {
    await _db.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  // 사용자 프로필 업데이트
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      avatarUrl: avatarUrl,
    );

    await _db.updateUser(_currentUser!);
    notifyListeners();
  }

  // 가구 참가
  Future<void> joinHousehold(String householdId) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(householdId: householdId);
    await _db.updateUser(_currentUser!);
    notifyListeners();
  }

  // 가구 탈퇴
  Future<void> leaveHousehold() async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(householdId: '');
    await _db.updateUser(_currentUser!);
    notifyListeners();
  }

  // XP 획득 (외부에서 호출 가능)
  Future<void> gainXp(int amount) async {
    if (_currentUser == null) return;

    _currentUser!.gainXp(amount);
    await _db.updateUser(_currentUser!);
    notifyListeners();
  }

  // 현재 사용자 새로고침
  void refreshCurrentUser() {
    if (_currentUser != null) {
      _currentUser = _db.getUser(_currentUser!.id);
      notifyListeners();
    }
  }
}
