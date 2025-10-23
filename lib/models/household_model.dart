import 'package:hive/hive.dart';

part 'household_model.g.dart';

@HiveType(typeId: 1)
class HouseholdModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> memberIds;

  @HiveField(4)
  String creatorId;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  HouseholdModel({
    required this.id,
    required this.name,
    this.description,
    List<String>? memberIds,
    required this.creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : memberIds = memberIds ?? [creatorId],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // 멤버 추가
  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
      updatedAt = DateTime.now();
    }
  }

  // 멤버 제거
  void removeMember(String userId) {
    memberIds.remove(userId);
    updatedAt = DateTime.now();
  }

  // Copy with
  HouseholdModel copyWith({
    String? name,
    String? description,
    List<String>? memberIds,
    DateTime? updatedAt,
  }) {
    return HouseholdModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      creatorId: creatorId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HouseholdModel.fromMap(Map<String, dynamic> map) {
    return HouseholdModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      memberIds: List<String>.from(map['memberIds'] as List),
      creatorId: map['creatorId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
