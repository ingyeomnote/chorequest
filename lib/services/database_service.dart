import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/models/household_model.dart';
import 'package:flutter_app/models/chore_model.dart';

class DatabaseService {
  static const String _usersBoxName = 'users';
  static const String _householdsBoxName = 'households';
  static const String _choresBoxName = 'chores';
  static const String _settingsBoxName = 'settings';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool _isInitialized = false;

  // 데이터베이스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(HouseholdModelAdapter());
    Hive.registerAdapter(ChoreModelAdapter());
    Hive.registerAdapter(ChoreStatusAdapter());
    Hive.registerAdapter(ChoreDifficultyAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(_usersBoxName);
    await Hive.openBox<HouseholdModel>(_householdsBoxName);
    await Hive.openBox<ChoreModel>(_choresBoxName);
    await Hive.openBox(_settingsBoxName);

    _isInitialized = true;
  }

  // Boxes getters
  Box<UserModel> get usersBox => Hive.box<UserModel>(_usersBoxName);
  Box<HouseholdModel> get householdsBox => Hive.box<HouseholdModel>(_householdsBoxName);
  Box<ChoreModel> get choresBox => Hive.box<ChoreModel>(_choresBoxName);
  Box get settingsBox => Hive.box(_settingsBoxName);

  // === USER CRUD ===
  
  Future<void> createUser(UserModel user) async {
    await usersBox.put(user.id, user);
  }

  UserModel? getUser(String userId) {
    return usersBox.get(userId);
  }

  List<UserModel> getAllUsers() {
    return usersBox.values.toList();
  }

  Future<void> updateUser(UserModel user) async {
    await usersBox.put(user.id, user);
  }

  Future<void> deleteUser(String userId) async {
    await usersBox.delete(userId);
  }

  // Get users by household
  List<UserModel> getUsersByHousehold(String householdId) {
    return usersBox.values
        .where((user) => user.householdId == householdId)
        .toList();
  }

  // === HOUSEHOLD CRUD ===
  
  Future<void> createHousehold(HouseholdModel household) async {
    await householdsBox.put(household.id, household);
  }

  HouseholdModel? getHousehold(String householdId) {
    return householdsBox.get(householdId);
  }

  List<HouseholdModel> getAllHouseholds() {
    return householdsBox.values.toList();
  }

  Future<void> updateHousehold(HouseholdModel household) async {
    await householdsBox.put(household.id, household);
  }

  Future<void> deleteHousehold(String householdId) async {
    await householdsBox.delete(householdId);
  }

  // === CHORE CRUD ===
  
  Future<void> createChore(ChoreModel chore) async {
    await choresBox.put(chore.id, chore);
  }

  ChoreModel? getChore(String choreId) {
    return choresBox.get(choreId);
  }

  List<ChoreModel> getAllChores() {
    return choresBox.values.toList();
  }

  Future<void> updateChore(ChoreModel chore) async {
    await choresBox.put(chore.id, chore);
  }

  Future<void> deleteChore(String choreId) async {
    await choresBox.delete(choreId);
  }

  // Get chores by household
  List<ChoreModel> getChoresByHousehold(String householdId) {
    return choresBox.values
        .where((chore) => chore.householdId == householdId)
        .toList();
  }

  // Get chores by user
  List<ChoreModel> getChoresByUser(String userId) {
    return choresBox.values
        .where((chore) => chore.assignedUserId == userId)
        .toList();
  }

  // Get chores by status
  List<ChoreModel> getChoresByStatus(String householdId, ChoreStatus status) {
    return choresBox.values
        .where((chore) => 
            chore.householdId == householdId && 
            chore.status == status)
        .toList();
  }

  // Get chores by date range
  List<ChoreModel> getChoresByDateRange(
    String householdId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return choresBox.values
        .where((chore) =>
            chore.householdId == householdId &&
            chore.dueDate.isAfter(startDate) &&
            chore.dueDate.isBefore(endDate))
        .toList();
  }

  // === SETTINGS ===
  
  Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  String? getCurrentUserId() {
    return settingsBox.get('currentUserId') as String?;
  }

  Future<void> setCurrentUserId(String userId) async {
    await settingsBox.put('currentUserId', userId);
  }

  Future<void> clearCurrentUser() async {
    await settingsBox.delete('currentUserId');
  }

  // === LEADERBOARD ===
  
  List<UserModel> getLeaderboard(String householdId) {
    final users = getUsersByHousehold(householdId);
    users.sort((a, b) => b.xp.compareTo(a.xp));
    return users;
  }

  // === COMPLETE CHORE WITH XP ===
  
  Future<void> completeChoreWithXp(String choreId, String userId) async {
    final chore = getChore(choreId);
    final user = getUser(userId);

    if (chore == null || user == null) return;

    // Complete chore
    chore.complete(userId);
    await updateChore(chore);

    // Gain XP
    final xpReward = chore.getXpReward();
    user.gainXp(xpReward);
    await updateUser(user);
  }

  // === DATABASE MANAGEMENT ===
  
  Future<void> clearAllData() async {
    await usersBox.clear();
    await householdsBox.clear();
    await choresBox.clear();
    await settingsBox.clear();
  }

  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}
