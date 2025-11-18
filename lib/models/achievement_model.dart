import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 5)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // 업적 이름

  @HiveField(2)
  String description; // 업적 설명

  @HiveField(3)
  String iconEmoji; // 아이콘 (이모지로 시작)

  @HiveField(4)
  AchievementTier tier; // 난이도 등급

  @HiveField(5)
  AchievementType type; // 업적 타입

  @HiveField(6)
  int targetCount; // 목표 횟수

  @HiveField(7)
  int rewardXp; // 보상 XP

  @HiveField(8)
  String? rewardAvatarItem; // 보상 아바타 아이템 ID

  @HiveField(9)
  bool isSecret; // 숨겨진 업적 여부

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.tier = AchievementTier.bronze,
    required this.type,
    this.targetCount = 1,
    this.rewardXp = 50,
    this.rewardAvatarItem,
    this.isSecret = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'tier': tier.name,
      'type': type.name,
      'targetCount': targetCount,
      'rewardXp': rewardXp,
      'rewardAvatarItem': rewardAvatarItem,
      'isSecret': isSecret,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconEmoji: map['iconEmoji'] as String,
      tier: AchievementTier.values.firstWhere(
        (e) => e.name == map['tier'],
        orElse: () => AchievementTier.bronze,
      ),
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.choreCount,
      ),
      targetCount: map['targetCount'] as int? ?? 1,
      rewardXp: map['rewardXp'] as int? ?? 50,
      rewardAvatarItem: map['rewardAvatarItem'] as String?,
      isSecret: map['isSecret'] as bool? ?? false,
    );
  }
}

@HiveType(typeId: 6)
enum AchievementTier {
  @HiveField(0)
  bronze, // 초급

  @HiveField(1)
  silver, // 중급

  @HiveField(2)
  gold, // 고급

  @HiveField(3)
  platinum, // 최상급

  @HiveField(4)
  legendary, // 전설
}

@HiveType(typeId: 7)
enum AchievementType {
  @HiveField(0)
  choreCount, // 집안일 총 완료 횟수

  @HiveField(1)
  specificChore, // 특정 집안일 완료 (예: 설거지 50회)

  @HiveField(2)
  streak, // 연속 달성

  @HiveField(3)
  level, // 레벨 달성

  @HiveField(4)
  leaderboard, // 리더보드 순위

  @HiveField(5)
  teamwork, // 팀워크 (가족 협력)

  @HiveField(6)
  seasonal, // 계절/이벤트 특화

  @HiveField(7)
  korean, // 한국 특화 (김장, 명절 등)
}

// 사용자의 업적 진행 상황
@HiveType(typeId: 8)
class UserAchievement extends HiveObject {
  @HiveField(0)
  String achievementId;

  @HiveField(1)
  int currentProgress; // 현재 진행도

  @HiveField(2)
  bool isCompleted; // 완료 여부

  @HiveField(3)
  DateTime? completedAt; // 완료 시각

  @HiveField(4)
  DateTime updatedAt;

  UserAchievement({
    required this.achievementId,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.completedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // 진행도 업데이트
  void updateProgress(int progress, int targetCount) {
    currentProgress = progress;
    updatedAt = DateTime.now();

    if (currentProgress >= targetCount && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }

  // 진행률 (0.0 ~ 1.0)
  double getProgressRate(int targetCount) {
    if (targetCount == 0) return 1.0;
    return (currentProgress / targetCount).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserAchievement.fromFirestore(Map<String, dynamic> data) {
    return UserAchievement(
      achievementId: data['achievementId'] as String,
      currentProgress: data['currentProgress'] as int? ?? 0,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      achievementId: map['achievementId'] as String,
      currentProgress: map['currentProgress'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
