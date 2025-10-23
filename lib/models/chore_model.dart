import 'package:hive/hive.dart';

part 'chore_model.g.dart';

@HiveType(typeId: 2)
enum ChoreStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  overdue,
}

@HiveType(typeId: 3)
enum ChoreDifficulty {
  @HiveField(0)
  easy,    // 10 XP
  @HiveField(1)
  medium,  // 25 XP
  @HiveField(2)
  hard,    // 50 XP
}

@HiveType(typeId: 4)
class ChoreModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String householdId;

  @HiveField(4)
  String? assignedUserId;

  @HiveField(5)
  ChoreDifficulty difficulty;

  @HiveField(6)
  ChoreStatus status;

  @HiveField(7)
  DateTime dueDate;

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  String? completedByUserId;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  String? recurringPattern; // 'daily', 'weekly', 'monthly'

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  ChoreModel({
    required this.id,
    required this.title,
    this.description,
    required this.householdId,
    this.assignedUserId,
    this.difficulty = ChoreDifficulty.medium,
    this.status = ChoreStatus.pending,
    required this.dueDate,
    this.completedAt,
    this.completedByUserId,
    this.isRecurring = false,
    this.recurringPattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // XP 계산
  int getXpReward() {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return 10;
      case ChoreDifficulty.medium:
        return 25;
      case ChoreDifficulty.hard:
        return 50;
    }
  }

  // 집안일 완료
  void complete(String userId) {
    status = ChoreStatus.completed;
    completedAt = DateTime.now();
    completedByUserId = userId;
    updatedAt = DateTime.now();
  }

  // 마감일 체크
  bool isOverdue() {
    return status == ChoreStatus.pending && DateTime.now().isAfter(dueDate);
  }

  // Copy with
  ChoreModel copyWith({
    String? title,
    String? description,
    String? assignedUserId,
    ChoreDifficulty? difficulty,
    ChoreStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    String? completedByUserId,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? updatedAt,
  }) {
    return ChoreModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      householdId: householdId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      completedByUserId: completedByUserId ?? this.completedByUserId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'householdId': householdId,
      'assignedUserId': assignedUserId,
      'difficulty': difficulty.toString(),
      'status': status.toString(),
      'dueDate': dueDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completedByUserId': completedByUserId,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChoreModel.fromMap(Map<String, dynamic> map) {
    return ChoreModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      householdId: map['householdId'] as String,
      assignedUserId: map['assignedUserId'] as String?,
      difficulty: ChoreDifficulty.values.firstWhere(
        (e) => e.toString() == map['difficulty'],
        orElse: () => ChoreDifficulty.medium,
      ),
      status: ChoreStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ChoreStatus.pending,
      ),
      dueDate: DateTime.parse(map['dueDate'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      completedByUserId: map['completedByUserId'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringPattern: map['recurringPattern'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
