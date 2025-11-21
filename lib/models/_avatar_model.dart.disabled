import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'avatar_model.g.dart';

@HiveType(typeId: 4)
class AvatarModel extends HiveObject {
  @HiveField(0)
  String bodyType; // 'cute', 'cool', 'funny'

  @HiveField(1)
  String hairStyle; // 'short', 'long', 'bun', 'ponytail', 'curly'

  @HiveField(2)
  String outfit; // 기본: 'casual', 레벨별 잠금 해제

  @HiveField(3)
  String? accessory; // 배지, 왕관 등

  @HiveField(4)
  String skinTone; // 'light', 'medium', 'dark'

  @HiveField(5)
  List<String> unlockedOutfits; // 잠금 해제된 의상 목록

  @HiveField(6)
  List<String> unlockedAccessories; // 잠금 해제된 액세서리 목록

  @HiveField(7)
  DateTime updatedAt;

  AvatarModel({
    this.bodyType = 'cute',
    this.hairStyle = 'short',
    this.outfit = 'casual',
    this.accessory,
    this.skinTone = 'medium',
    List<String>? unlockedOutfits,
    List<String>? unlockedAccessories,
    DateTime? updatedAt,
  })  : unlockedOutfits = unlockedOutfits ?? ['casual'],
        unlockedAccessories = unlockedAccessories ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  // 의상 잠금 해제
  void unlockOutfit(String outfitId) {
    if (!unlockedOutfits.contains(outfitId)) {
      unlockedOutfits.add(outfitId);
      updatedAt = DateTime.now();
    }
  }

  // 액세서리 잠금 해제
  void unlockAccessory(String accessoryId) {
    if (!unlockedAccessories.contains(accessoryId)) {
      unlockedAccessories.add(accessoryId);
      updatedAt = DateTime.now();
    }
  }

  // 아바타 업데이트
  AvatarModel copyWith({
    String? bodyType,
    String? hairStyle,
    String? outfit,
    String? accessory,
    String? skinTone,
  }) {
    return AvatarModel(
      bodyType: bodyType ?? this.bodyType,
      hairStyle: hairStyle ?? this.hairStyle,
      outfit: outfit ?? this.outfit,
      accessory: accessory ?? this.accessory,
      skinTone: skinTone ?? this.skinTone,
      unlockedOutfits: List.from(unlockedOutfits),
      unlockedAccessories: List.from(unlockedAccessories),
      updatedAt: DateTime.now(),
    );
  }

  // Firestore 직렬화
  Map<String, dynamic> toFirestore() {
    return {
      'bodyType': bodyType,
      'hairStyle': hairStyle,
      'outfit': outfit,
      'accessory': accessory,
      'skinTone': skinTone,
      'unlockedOutfits': unlockedOutfits,
      'unlockedAccessories': unlockedAccessories,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AvatarModel.fromFirestore(Map<String, dynamic> data) {
    return AvatarModel(
      bodyType: data['bodyType'] as String? ?? 'cute',
      hairStyle: data['hairStyle'] as String? ?? 'short',
      outfit: data['outfit'] as String? ?? 'casual',
      accessory: data['accessory'] as String?,
      skinTone: data['skinTone'] as String? ?? 'medium',
      unlockedOutfits: (data['unlockedOutfits'] as List<dynamic>?)?.cast<String>() ?? ['casual'],
      unlockedAccessories: (data['unlockedAccessories'] as List<dynamic>?)?.cast<String>() ?? [],
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Hive/Map 직렬화
  Map<String, dynamic> toMap() {
    return {
      'bodyType': bodyType,
      'hairStyle': hairStyle,
      'outfit': outfit,
      'accessory': accessory,
      'skinTone': skinTone,
      'unlockedOutfits': unlockedOutfits,
      'unlockedAccessories': unlockedAccessories,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AvatarModel.fromMap(Map<String, dynamic> map) {
    return AvatarModel(
      bodyType: map['bodyType'] as String? ?? 'cute',
      hairStyle: map['hairStyle'] as String? ?? 'short',
      outfit: map['outfit'] as String? ?? 'casual',
      accessory: map['accessory'] as String?,
      skinTone: map['skinTone'] as String? ?? 'medium',
      unlockedOutfits: (map['unlockedOutfits'] as List<dynamic>?)?.cast<String>() ?? ['casual'],
      unlockedAccessories: (map['unlockedAccessories'] as List<dynamic>?)?.cast<String>() ?? [],
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

// 아바타 아이템 정의
class AvatarItem {
  final String id;
  final String name;
  final String category; // 'body', 'hair', 'outfit', 'accessory'
  final String description;
  final int unlockLevel; // 잠금 해제 레벨
  final String? unlockAchievement; // 또는 업적으로 해제
  final bool isPremium; // 프리미엄 아이템 여부

  const AvatarItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.unlockLevel = 1,
    this.unlockAchievement,
    this.isPremium = false,
  });
}
