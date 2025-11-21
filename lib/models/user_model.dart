import 'dart:math';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'avatar_model.dart';

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

  // Phase 2 추가 필드
  @HiveField(9)
  List<String> achievements;

  @HiveField(10)
  int currentStreak;

  @HiveField(11)
  int longestStreak;

  @HiveField(12)
  DateTime? lastLoginAt;

  @HiveField(13)
  DateTime? lastActivityAt;

  // Phase 3 추가 필드 - 캐릭터 시스템
  // @HiveField(14)
  // AvatarModel? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.householdId,
    this.xp = 0,
    this.level = 1,
    this.achievements = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLoginAt,
    this.lastActivityAt,
    // AvatarModel? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : // avatar = avatar ?? AvatarModel(),
        createdAt = createdAt ?? DateTime.now(),
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

  // Hive용 직렬화 (기존 호환성 유지)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'householdId': householdId,
      'xp': xp,
      'level': level,
      'achievements': achievements,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      // 'avatar': avatar?.toMap(),
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
      achievements: (map['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'] as String)
          : null,
      // avatar: map['avatar'] != null
      //     ? AvatarModel.fromMap(map['avatar'] as Map<String, dynamic>)
      //     : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Firestore용 직렬화 (Timestamp 사용)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'householdId': householdId,
      'xp': xp,
      'level': level,
      'achievements': achievements,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      // 'avatar': avatar?.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id, // Firestore document ID
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      householdId: data['householdId'] as String?,
      xp: data['xp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      achievements: (data['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      lastActivityAt: data['lastActivityAt'] != null
          ? (data['lastActivityAt'] as Timestamp).toDate()
          : null,
      // avatar: data['avatar'] != null
      //     ? AvatarModel.fromFirestore(data['avatar'] as Map<String, dynamic>)
      //     : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // fromFirestore 대안 (Map에서 직접 생성)
  factory UserModel.fromFirestoreMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      householdId: data['householdId'] as String?,
      xp: data['xp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      achievements: (data['achievements'] as List<dynamic>?)?.cast<String>() ?? [],
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      lastActivityAt: data['lastActivityAt'] != null
          ? (data['lastActivityAt'] as Timestamp).toDate()
          : null,
      // avatar: data['avatar'] != null
      //     ? AvatarModel.fromFirestore(data['avatar'] as Map<String, dynamic>)
      //     : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
