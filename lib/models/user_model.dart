import 'dart:math';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? avatarUrl;

  @HiveField(4)
  String? householdId;

  @HiveField(5)
  int xp;

  @HiveField(6)
  int level;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.householdId,
    this.xp = 0,
    this.level = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // XP 획득 로직
  void gainXp(int amount) {
    xp += amount;
    updatedAt = DateTime.now();
    _checkLevelUp();
  }

  // 레벨업 체크 (exponential growth)
  void _checkLevelUp() {
    int requiredXp = _getRequiredXpForLevel(level + 1);
    while (xp >= requiredXp) {
      level++;
      requiredXp = _getRequiredXpForLevel(level + 1);
    }
  }

  // 다음 레벨까지 필요한 XP 계산 (Habitica 스타일)
  static int _getRequiredXpForLevel(int targetLevel) {
    // Formula: 100 * (level^1.5)
    return (100 * pow(targetLevel, 1.5)).round();
  }

  // 현재 레벨의 진행률 (0.0 ~ 1.0)
  double getLevelProgress() {
    int currentLevelXp = _getRequiredXpForLevel(level);
    int nextLevelXp = _getRequiredXpForLevel(level + 1);
    int xpInCurrentLevel = xp - currentLevelXp;
    int xpNeededForNextLevel = nextLevelXp - currentLevelXp;
    return xpInCurrentLevel / xpNeededForNextLevel;
  }

  // 다음 레벨까지 남은 XP
  int getXpToNextLevel() {
    int nextLevelXp = _getRequiredXpForLevel(level + 1);
    return nextLevelXp - xp;
  }

  // Copy with
  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? householdId,
    int? xp,
    int? level,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      householdId: householdId ?? this.householdId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'householdId': householdId,
      'xp': xp,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      householdId: map['householdId'] as String?,
      xp: map['xp'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
