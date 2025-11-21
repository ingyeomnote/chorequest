import '../models/avatar_model.dart';

// 아바타 아이템 정의
class AvatarItemsData {
  // 모든 아바타 아이템
  static List<AvatarItem> getAllItems() {
    return [
      ...getBodyTypes(),
      ...getHairStyles(),
      ...getOutfits(),
      ...getAccessories(),
    ];
  }

  // 바디 타입 (캐릭터 기본 체형)
  static List<AvatarItem> getBodyTypes() {
    return [
      const AvatarItem(
        id: 'cute',
        name: '귀여운 스타일',
        category: 'body',
        description: '귀엽고 사랑스러운 캐릭터',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'cool',
        name: '멋진 스타일',
        category: 'body',
        description: '시크하고 멋진 캐릭터',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'funny',
        name: '재미있는 스타일',
        category: 'body',
        description: '유쾌하고 재미있는 캐릭터',
        unlockLevel: 1,
      ),
    ];
  }

  // 헤어스타일
  static List<AvatarItem> getHairStyles() {
    return [
      // 기본 (무료)
      const AvatarItem(
        id: 'short',
        name: '숏컷',
        category: 'hair',
        description: '단정한 숏컷 헤어',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'long',
        name: '긴 머리',
        category: 'hair',
        description: '자연스러운 긴 머리',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'ponytail',
        name: '포니테일',
        category: 'hair',
        description: '활동적인 포니테일',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'bun',
        name: '업스타일',
        category: 'hair',
        description: '단정한 업스타일',
        unlockLevel: 1,
      ),
      const AvatarItem(
        id: 'curly',
        name: '웨이브',
        category: 'hair',
        description: '자연스러운 웨이브',
        unlockLevel: 1,
      ),

      // 프리미엄 (레벨 해제)
      const AvatarItem(
        id: 'hair_premium_1',
        name: '염색 헤어 (레드)',
        category: 'hair',
        description: '화려한 레드 염색',
        unlockLevel: 5,
      ),
      const AvatarItem(
        id: 'hair_premium_2',
        name: '염색 헤어 (블루)',
        category: 'hair',
        description: '시크한 블루 염색',
        unlockLevel: 10,
      ),
      const AvatarItem(
        id: 'hair_premium_3',
        name: '트윈테일',
        category: 'hair',
        description: '귀여운 트윈테일',
        unlockLevel: 15,
      ),
    ];
  }

  // 의상
  static List<AvatarItem> getOutfits() {
    return [
      // 기본 의상 (무료)
      const AvatarItem(
        id: 'casual',
        name: '캐주얼 의상',
        category: 'outfit',
        description: '편안한 일상복',
        unlockLevel: 1,
      ),

      // 레벨 해제 의상
      const AvatarItem(
        id: 'outfit_cleaning_master',
        name: '청소 마스터 유니폼',
        category: 'outfit',
        description: '전문 청소부 유니폼',
        unlockLevel: 10,
      ),
      const AvatarItem(
        id: 'outfit_centurion',
        name: '백전백승 의상',
        category: 'outfit',
        description: '100개 완료 기념 의상',
        unlockLevel: 1,
        unlockAchievement: 'century',
      ),
      const AvatarItem(
        id: 'outfit_space_hero',
        name: '우주 영웅 의상',
        category: 'outfit',
        description: '레벨 20 달성 기념',
        unlockLevel: 20,
      ),
      const AvatarItem(
        id: 'outfit_streak_master',
        name: '연속 달성 의상',
        category: 'outfit',
        description: '30일 연속 달성 기념',
        unlockLevel: 1,
        unlockAchievement: 'streak_30',
      ),

      // 한국 특화 의상
      const AvatarItem(
        id: 'outfit_hanbok',
        name: '한복',
        category: 'outfit',
        description: '명절 특별 한복',
        unlockLevel: 1,
        unlockAchievement: 'holiday_master',
      ),
      const AvatarItem(
        id: 'outfit_apron',
        name: '요리사 앞치마',
        category: 'outfit',
        description: '주방의 신 전용 앞치마',
        unlockLevel: 1,
        unlockAchievement: 'cooking_master',
      ),

      // 전설 의상
      const AvatarItem(
        id: 'outfit_legend',
        name: '전설의 가사왕',
        category: 'outfit',
        description: '500개 완료 전설 의상',
        unlockLevel: 1,
        unlockAchievement: 'legend',
      ),
      const AvatarItem(
        id: 'outfit_year_champion',
        name: '1년 챔피언',
        category: 'outfit',
        description: '365일 연속 달성 전설 의상',
        unlockLevel: 1,
        unlockAchievement: 'streak_365',
      ),

      // 프리미엄 의상 (IAP)
      const AvatarItem(
        id: 'outfit_premium_suit',
        name: '프리미엄 정장',
        category: 'outfit',
        description: '고급 정장',
        unlockLevel: 1,
        isPremium: true,
      ),
      const AvatarItem(
        id: 'outfit_premium_dress',
        name: '프리미엄 드레스',
        category: 'outfit',
        description: '우아한 드레스',
        unlockLevel: 1,
        isPremium: true,
      ),
    ];
  }

  // 액세서리
  static List<AvatarItem> getAccessories() {
    return [
      // 레벨 해제 액세서리
      const AvatarItem(
        id: 'accessory_crown',
        name: '왕관',
        category: 'accessory',
        description: '250개 완료 기념 왕관',
        unlockLevel: 1,
        unlockAchievement: 'master',
      ),
      const AvatarItem(
        id: 'accessory_platinum_star',
        name: '플래티넘 스타',
        category: 'accessory',
        description: '레벨 50 달성 기념',
        unlockLevel: 50,
      ),

      // 업적 해제 액세서리
      const AvatarItem(
        id: 'accessory_dish_badge',
        name: '설거지 배지',
        category: 'accessory',
        description: '설거지 마스터 배지',
        unlockLevel: 1,
        unlockAchievement: 'dishwasher_master',
      ),
      const AvatarItem(
        id: 'accessory_golden_broom',
        name: '황금 빗자루',
        category: 'accessory',
        description: '청소의 달인 황금 빗자루',
        unlockLevel: 1,
        unlockAchievement: 'cleaning_expert',
      ),
      const AvatarItem(
        id: 'accessory_chef_hat',
        name: '요리사 모자',
        category: 'accessory',
        description: '주방의 신 요리사 모자',
        unlockLevel: 1,
        unlockAchievement: 'cooking_master',
      ),
      const AvatarItem(
        id: 'accessory_mvp_crown',
        name: 'MVP 왕관',
        category: 'accessory',
        description: '주간 MVP 3회 달성',
        unlockLevel: 1,
        unlockAchievement: 'weekly_mvp_3',
      ),
      const AvatarItem(
        id: 'accessory_family_badge',
        name: '가족 배지',
        category: 'accessory',
        description: '팀워크 챔피언 배지',
        unlockLevel: 1,
        unlockAchievement: 'team_champion',
      ),
      const AvatarItem(
        id: 'accessory_diamond_badge',
        name: '다이아몬드 배지',
        category: 'accessory',
        description: '100일 연속 달성 배지',
        unlockLevel: 1,
        unlockAchievement: 'streak_100',
      ),

      // 한국 특화 액세서리
      const AvatarItem(
        id: 'accessory_kimchi_badge',
        name: '김치 배지',
        category: 'accessory',
        description: '김치 마스터 배지',
        unlockLevel: 1,
        unlockAchievement: 'kimchi_lover',
      ),
      const AvatarItem(
        id: 'accessory_eco_badge',
        name: '에코 배지',
        category: 'accessory',
        description: '분리수거 전문가 배지',
        unlockLevel: 1,
        unlockAchievement: 'recycling_expert',
      ),

      // 프리미엄 액세서리 (IAP)
      const AvatarItem(
        id: 'accessory_sunglasses',
        name: '선글라스',
        category: 'accessory',
        description: '멋진 선글라스',
        unlockLevel: 1,
        isPremium: true,
      ),
      const AvatarItem(
        id: 'accessory_headphones',
        name: '헤드폰',
        category: 'accessory',
        description: '음악을 즐기는 헤드폰',
        unlockLevel: 1,
        isPremium: true,
      ),
    ];
  }

  // 카테고리별 아이템 가져오기
  static List<AvatarItem> getByCategory(String category) {
    return getAllItems().where((item) => item.category == category).toList();
  }

  // ID로 아이템 찾기
  static AvatarItem? findById(String id) {
    try {
      return getAllItems().firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // 현재 레벨에서 해제 가능한 아이템
  static List<AvatarItem> getUnlockableAtLevel(int level) {
    return getAllItems()
        .where((item) =>
            item.unlockLevel <= level &&
            item.unlockAchievement == null &&
            !item.isPremium)
        .toList();
  }

  // 업적으로 해제 가능한 아이템
  static List<AvatarItem> getUnlockableByAchievement(String achievementId) {
    return getAllItems()
        .where((item) => item.unlockAchievement == achievementId)
        .toList();
  }

  // 프리미엄 아이템
  static List<AvatarItem> getPremiumItems() {
    return getAllItems().where((item) => item.isPremium).toList();
  }
}
