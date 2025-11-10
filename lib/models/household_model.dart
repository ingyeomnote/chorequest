import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Phase 2 추가 필드
  @HiveField(7)
  String? avatarUrl;

  @HiveField(8)
  int memberCount;

  @HiveField(9)
  List<String> adminIds;

  HouseholdModel({
    required this.id,
    required this.name,
    this.description,
    List<String>? memberIds,
    required this.creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.avatarUrl,
    int? memberCount,
    List<String>? adminIds,
  })  : memberIds = memberIds ?? [creatorId],
        memberCount = memberCount ?? (memberIds?.length ?? 1),
        adminIds = adminIds ?? [creatorId],
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

  // Hive용 직렬화 (기존 호환성 유지)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'memberCount': memberCount,
      'adminIds': adminIds,
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
      avatarUrl: map['avatarUrl'] as String?,
      memberCount: map['memberCount'] as int?,
      adminIds: (map['adminIds'] as List<dynamic>?)?.cast<String>(),
    );
  }

  // Firestore용 직렬화 (Timestamp 사용)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'avatarUrl': avatarUrl,
      'memberCount': memberCount,
      'adminIds': adminIds,
    };
  }

  factory HouseholdModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HouseholdModel(
      id: doc.id, // Firestore document ID
      name: data['name'] as String,
      description: data['description'] as String?,
      memberIds: List<String>.from(data['memberIds'] as List),
      creatorId: data['creatorId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      memberCount: data['memberCount'] as int?,
      adminIds: (data['adminIds'] as List<dynamic>?)?.cast<String>(),
    );
  }

  // fromFirestore 대안 (Map에서 직접 생성)
  factory HouseholdModel.fromFirestoreMap(String id, Map<String, dynamic> data) {
    return HouseholdModel(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String?,
      memberIds: List<String>.from(data['memberIds'] as List),
      creatorId: data['creatorId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      memberCount: data['memberCount'] as int?,
      adminIds: (data['adminIds'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
