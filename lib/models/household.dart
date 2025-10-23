import 'package:hive/hive.dart';

part 'household.g.dart';

/// 가구(가족) 모델
/// Habitica의 Party 개념과 유사
@HiveType(typeId: 0)
class Household {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  List<String> memberIds; // 구성원 ID 목록

  @HiveField(6)
  String? inviteCode; // 초대 코드

  Household({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    List<String>? memberIds,
    this.inviteCode,
  }) : memberIds = memberIds ?? [];

  // JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'memberIds': memberIds,
      'inviteCode': inviteCode,
    };
  }

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      memberIds: (json['memberIds'] as List?)?.cast<String>() ?? [],
      inviteCode: json['inviteCode'] as String?,
    );
  }

  // 복사본 생성
  Household copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
    List<String>? memberIds,
    String? inviteCode,
  }) {
    return Household(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberIds: memberIds ?? List<String>.from(this.memberIds),
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}
