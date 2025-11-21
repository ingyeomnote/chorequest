import '../models/avatar_model.dart';
import '../models/user_model.dart';
import '../data/avatar_items_data.dart';
import '../utils/logger.dart';

// 아바타/캐릭터 관리 서비스
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  // 레벨업 시 자동으로 의상/액세서리 잠금 해제
  void unlockItemsByLevel(AvatarModel avatar, int level) {
    final items = AvatarItemsData.getUnlockableAtLevel(level);

    for (final item in items) {
      if (item.category == 'outfit' &&
          !avatar.unlockedOutfits.contains(item.id)) {
        avatar.unlockOutfit(item.id);
        logger.i('Unlocked outfit: ${item.name} at level $level');
      } else if (item.category == 'accessory' &&
          !avatar.unlockedAccessories.contains(item.id)) {
        avatar.unlockAccessory(item.id);
        logger.i('Unlocked accessory: ${item.name} at level $level');
      }
    }
  }

  // 업적 달성 시 아이템 잠금 해제
  void unlockItemsByAchievement(AvatarModel avatar, String achievementId) {
    final items = AvatarItemsData.getUnlockableByAchievement(achievementId);

    for (final item in items) {
      if (item.category == 'outfit' &&
          !avatar.unlockedOutfits.contains(item.id)) {
        avatar.unlockOutfit(item.id);
        logger.i('Unlocked outfit: ${item.name} from achievement $achievementId');
      } else if (item.category == 'accessory' &&
          !avatar.unlockedAccessories.contains(item.id)) {
        avatar.unlockAccessory(item.id);
        logger.i('Unlocked accessory: ${item.name} from achievement $achievementId');
      }
    }
  }

  // 아바타 커스터마이징
  void customizeAvatar(AvatarModel avatar, {
    String? bodyType,
    String? hairStyle,
    String? outfit,
    String? accessory,
    String? skinTone,
  }) {
    if (bodyType != null && bodyType != avatar.bodyType) {
      avatar.bodyType = bodyType;
    }
    if (hairStyle != null && hairStyle != avatar.hairStyle) {
      avatar.hairStyle = hairStyle;
    }
    if (outfit != null && outfit != avatar.outfit) {
      // 잠금 해제 확인
      if (avatar.unlockedOutfits.contains(outfit)) {
        avatar.outfit = outfit;
      } else {
        logger.w('Outfit $outfit is locked');
      }
    }
    if (accessory != null) {
      // null이면 액세서리 제거
      if (accessory.isEmpty) {
        avatar.accessory = null;
      } else if (avatar.unlockedAccessories.contains(accessory)) {
        avatar.accessory = accessory;
      } else {
        logger.w('Accessory $accessory is locked');
      }
    }
    if (skinTone != null && skinTone != avatar.skinTone) {
      avatar.skinTone = skinTone;
    }

    avatar.updatedAt = DateTime.now();
  }

  // 사용 가능한 아이템 목록
  List<AvatarItem> getAvailableItems(AvatarModel avatar, int userLevel, List<String> achievements) {
    final allItems = AvatarItemsData.getAllItems();
    final available = <AvatarItem>[];

    for (final item in allItems) {
      // 프리미엄 아이템은 별도 표시
      if (item.isPremium) {
        available.add(item);
        continue;
      }

      // 레벨로 잠금 해제
      if (item.unlockLevel <= userLevel) {
        available.add(item);
        continue;
      }

      // 업적으로 잠금 해제
      if (item.unlockAchievement != null &&
          achievements.contains(item.unlockAchievement)) {
        available.add(item);
        continue;
      }
    }

    return available;
  }

  // 카테고리별 사용 가능한 아이템
  List<AvatarItem> getAvailableItemsByCategory(
    AvatarModel avatar,
    String category,
    int userLevel,
    List<String> achievements,
  ) {
    final available = getAvailableItems(avatar, userLevel, achievements);
    return available.where((item) => item.category == category).toList();
  }

  // 아이템 잠금 여부
  bool isItemUnlocked(AvatarItem item, AvatarModel avatar, int userLevel, List<String> achievements) {
    if (item.isPremium) return false; // 프리미엄은 구매 필요

    if (item.category == 'outfit') {
      return avatar.unlockedOutfits.contains(item.id);
    } else if (item.category == 'accessory') {
      return avatar.unlockedAccessories.contains(item.id);
    }

    // body, hair는 기본 제공
    return true;
  }
}
