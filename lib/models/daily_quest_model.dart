import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'daily_quest_model.g.dart';

@HiveType(typeId: 9)
class DailyQuest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // 퀘스트 제목

  @HiveField(2)
  String description; // 퀘스트 설명

  @HiveField(3)
  QuestType type; // 퀘스트 타입

  @HiveField(4)
  int targetCount; // 목표 횟수

  @HiveField(5)
  int currentProgress; // 현재 진행도

  @HiveField(6)
  int rewardXp; // 보상 XP

  @HiveField(7)
  DateTime startDate; // 시작 날짜

  @HiveField(8)
  DateTime expiresAt; // 만료 시각 (23:59:59)

  @HiveField(9)
  bool isCompleted; // 완료 여부

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  QuestDifficulty difficulty; // 난이도

  @HiveField(12)
  String? iconEmoji; // 아이콘 이모지

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.targetCount = 1,
    this.currentProgress = 0,
    this.rewardXp = 30,
    DateTime? startDate,
    DateTime? expiresAt,
    this.isCompleted = false,
    this.completedAt,
    this.difficulty = QuestDifficulty.normal,
    this.iconEmoji,
  })  : startDate = startDate ?? DateTime.now(),
        expiresAt = expiresAt ?? _getEndOfDay(DateTime.now());

  // 오늘 23:59:59 계산
  static DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // 진행도 업데이트
  void updateProgress(int progress) {
    currentProgress = progress;
    if (currentProgress >= targetCount && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }

  // 진행률 (0.0 ~ 1.0)
  double getProgressRate() {
    if (targetCount == 0) return 1.0;
    return (currentProgress / targetCount).clamp(0.0, 1.0);
  }

  // 만료 여부
  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }

  // 남은 시간 (시간 단위)
  int getHoursRemaining() {
    if (isExpired()) return 0;
    return expiresAt.difference(DateTime.now()).inHours;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'targetCount': targetCount,
      'currentProgress': currentProgress,
      'rewardXp': rewardXp,
      'startDate': Timestamp.fromDate(startDate),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'difficulty': difficulty.name,
      'iconEmoji': iconEmoji,
    };
  }

  factory DailyQuest.fromFirestore(String id, Map<String, dynamic> data) {
    return DailyQuest(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      type: QuestType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => QuestType.choreCount,
      ),
      targetCount: data['targetCount'] as int? ?? 1,
      currentProgress: data['currentProgress'] as int? ?? 0,
      rewardXp: data['rewardXp'] as int? ?? 30,
      startDate: (data['startDate'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => QuestDifficulty.normal,
      ),
      iconEmoji: data['iconEmoji'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'targetCount': targetCount,
      'currentProgress': currentProgress,
      'rewardXp': rewardXp,
      'startDate': startDate.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'difficulty': difficulty.name,
      'iconEmoji': iconEmoji,
    };
  }

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    return DailyQuest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: QuestType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestType.choreCount,
      ),
      targetCount: map['targetCount'] as int? ?? 1,
      currentProgress: map['currentProgress'] as int? ?? 0,
      rewardXp: map['rewardXp'] as int? ?? 30,
      startDate: DateTime.parse(map['startDate'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuestDifficulty.normal,
      ),
      iconEmoji: map['iconEmoji'] as String?,
    );
  }
}

@HiveType(typeId: 10)
enum QuestType {
  @HiveField(0)
  choreCount, // 집안일 N개 완료

  @HiveField(1)
  difficultyBased, // 특정 난이도 집안일 완료

  @HiveField(2)
  categoryBased, // 특정 카테고리 집안일 완료 (청소, 요리 등)

  @HiveField(3)
  teamwork, // 가족 전원 참여

  @HiveField(4)
  streak, // 연속 달성 유지

  @HiveField(5)
  weekend, // 주말 특별 퀘스트

  @HiveField(6)
  seasonal, // 계절/이벤트 퀘스트
}

@HiveType(typeId: 11)
enum QuestDifficulty {
  @HiveField(0)
  easy, // 쉬움

  @HiveField(1)
  normal, // 보통

  @HiveField(2)
  hard, // 어려움

  @HiveField(3)
  special, // 특별 (주말, 이벤트)
}
