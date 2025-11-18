import '../models/achievement_model.dart';

// 업적 정의 데이터
class AchievementsData {
  // 모든 업적 목록
  static List<Achievement> getAllAchievements() {
    return [
      ...getStarterAchievements(),
      ...getChoreCountAchievements(),
      ...getSpecificChoreAchievements(),
      ...getStreakAchievements(),
      ...getLevelAchievements(),
      ...getLeaderboardAchievements(),
      ...getTeamworkAchievements(),
      ...getKoreanSpecialAchievements(),
    ];
  }

  // 초급 업적 (시작)
  static List<Achievement> getStarterAchievements() {
    return [
      Achievement(
        id: 'first_step',
        title: '첫 걸음',
        description: '첫 집안일 완료하기',
        iconEmoji: '🌱',
        tier: AchievementTier.bronze,
        type: AchievementType.choreCount,
        targetCount: 1,
        rewardXp: 10,
      ),
      Achievement(
        id: 'getting_started',
        title: '시작이 반',
        description: '집안일 5개 완료하기',
        iconEmoji: '👍',
        tier: AchievementTier.bronze,
        type: AchievementType.choreCount,
        targetCount: 5,
        rewardXp: 25,
      ),
      Achievement(
        id: 'newcomer',
        title: '새내기',
        description: '집안일 10개 완료하기',
        iconEmoji: '⭐',
        tier: AchievementTier.bronze,
        type: AchievementType.choreCount,
        targetCount: 10,
        rewardXp: 50,
      ),
    ];
  }

  // 집안일 총 횟수 업적
  static List<Achievement> getChoreCountAchievements() {
    return [
      Achievement(
        id: 'dedicated_worker',
        title: '성실한 일꾼',
        description: '집안일 25개 완료',
        iconEmoji: '💪',
        tier: AchievementTier.silver,
        type: AchievementType.choreCount,
        targetCount: 25,
        rewardXp: 100,
      ),
      Achievement(
        id: 'hard_worker',
        title: '부지런한 일꾼',
        description: '집안일 50개 완료',
        iconEmoji: '🔥',
        tier: AchievementTier.silver,
        type: AchievementType.choreCount,
        targetCount: 50,
        rewardXp: 200,
      ),
      Achievement(
        id: 'century',
        title: '백전백승',
        description: '집안일 100개 완료',
        iconEmoji: '💯',
        tier: AchievementTier.gold,
        type: AchievementType.choreCount,
        targetCount: 100,
        rewardXp: 500,
        rewardAvatarItem: 'outfit_centurion',
      ),
      Achievement(
        id: 'master',
        title: '집안일 마스터',
        description: '집안일 250개 완료',
        iconEmoji: '👑',
        tier: AchievementTier.gold,
        type: AchievementType.choreCount,
        targetCount: 250,
        rewardXp: 1000,
        rewardAvatarItem: 'accessory_crown',
      ),
      Achievement(
        id: 'legend',
        title: '전설의 가사왕',
        description: '집안일 500개 완료',
        iconEmoji: '🏆',
        tier: AchievementTier.legendary,
        type: AchievementType.choreCount,
        targetCount: 500,
        rewardXp: 2500,
        rewardAvatarItem: 'outfit_legend',
      ),
    ];
  }

  // 특정 집안일 업적
  static List<Achievement> getSpecificChoreAchievements() {
    return [
      Achievement(
        id: 'dishwasher_apprentice',
        title: '설거지 견습생',
        description: '설거지 20회 완료',
        iconEmoji: '🍽️',
        tier: AchievementTier.bronze,
        type: AchievementType.specificChore,
        targetCount: 20,
        rewardXp: 50,
      ),
      Achievement(
        id: 'dishwasher_master',
        title: '설거지 마스터',
        description: '설거지 50회 완료',
        iconEmoji: '🍚',
        tier: AchievementTier.silver,
        type: AchievementType.specificChore,
        targetCount: 50,
        rewardXp: 150,
        rewardAvatarItem: 'accessory_dish_badge',
      ),
      Achievement(
        id: 'cleaning_expert',
        title: '청소의 달인',
        description: '청소 관련 집안일 100회 완료',
        iconEmoji: '🧹',
        tier: AchievementTier.gold,
        type: AchievementType.specificChore,
        targetCount: 100,
        rewardXp: 300,
        rewardAvatarItem: 'accessory_golden_broom',
      ),
      Achievement(
        id: 'laundry_pro',
        title: '세탁의 고수',
        description: '빨래 관련 집안일 75회 완료',
        iconEmoji: '👕',
        tier: AchievementTier.silver,
        type: AchievementType.specificChore,
        targetCount: 75,
        rewardXp: 200,
      ),
      Achievement(
        id: 'cooking_master',
        title: '주방의 신',
        description: '요리/주방 관련 집안일 100회 완료',
        iconEmoji: '👨‍🍳',
        tier: AchievementTier.gold,
        type: AchievementType.specificChore,
        targetCount: 100,
        rewardXp: 350,
        rewardAvatarItem: 'accessory_chef_hat',
      ),
    ];
  }

  // 연속 달성 업적
  static List<Achievement> getStreakAchievements() {
    return [
      Achievement(
        id: 'streak_3',
        title: '3일 연속',
        description: '3일 연속 집안일 완료',
        iconEmoji: '🔥',
        tier: AchievementTier.bronze,
        type: AchievementType.streak,
        targetCount: 3,
        rewardXp: 30,
      ),
      Achievement(
        id: 'streak_7',
        title: '일주일 챌린저',
        description: '7일 연속 집안일 완료',
        iconEmoji: '⭐',
        tier: AchievementTier.silver,
        type: AchievementType.streak,
        targetCount: 7,
        rewardXp: 100,
      ),
      Achievement(
        id: 'streak_30',
        title: '한 달 연속',
        description: '30일 연속 집안일 완료',
        iconEmoji: '🌟',
        tier: AchievementTier.gold,
        type: AchievementType.streak,
        targetCount: 30,
        rewardXp: 500,
        rewardAvatarItem: 'outfit_streak_master',
      ),
      Achievement(
        id: 'streak_100',
        title: '백일 기념',
        description: '100일 연속 집안일 완료',
        iconEmoji: '💎',
        tier: AchievementTier.platinum,
        type: AchievementType.streak,
        targetCount: 100,
        rewardXp: 1500,
        rewardAvatarItem: 'accessory_diamond_badge',
      ),
      Achievement(
        id: 'streak_365',
        title: '1년 연속',
        description: '365일 연속 집안일 완료',
        iconEmoji: '🏅',
        tier: AchievementTier.legendary,
        type: AchievementType.streak,
        targetCount: 365,
        rewardXp: 5000,
        rewardAvatarItem: 'outfit_year_champion',
      ),
    ];
  }

  // 레벨 달성 업적
  static List<Achievement> getLevelAchievements() {
    return [
      Achievement(
        id: 'level_5',
        title: '레벨 5 달성',
        description: '레벨 5에 도달하기',
        iconEmoji: '📈',
        tier: AchievementTier.bronze,
        type: AchievementType.level,
        targetCount: 5,
        rewardXp: 50,
        rewardAvatarItem: 'hair_premium_1',
      ),
      Achievement(
        id: 'level_10',
        title: '레벨 10 달성',
        description: '레벨 10에 도달하기',
        iconEmoji: '🎯',
        tier: AchievementTier.silver,
        type: AchievementType.level,
        targetCount: 10,
        rewardXp: 150,
        rewardAvatarItem: 'outfit_cleaning_master',
      ),
      Achievement(
        id: 'level_20',
        title: '레벨 20 달성',
        description: '레벨 20에 도달하기',
        iconEmoji: '🚀',
        tier: AchievementTier.gold,
        type: AchievementType.level,
        targetCount: 20,
        rewardXp: 400,
        rewardAvatarItem: 'outfit_space_hero',
      ),
      Achievement(
        id: 'level_50',
        title: '레벨 50 달성',
        description: '레벨 50에 도달하기',
        iconEmoji: '💫',
        tier: AchievementTier.platinum,
        type: AchievementType.level,
        targetCount: 50,
        rewardXp: 1000,
        rewardAvatarItem: 'accessory_platinum_star',
      ),
    ];
  }

  // 리더보드 업적
  static List<Achievement> getLeaderboardAchievements() {
    return [
      Achievement(
        id: 'weekly_mvp',
        title: '주간 MVP',
        description: '주간 리더보드 1등 달성',
        iconEmoji: '👑',
        tier: AchievementTier.silver,
        type: AchievementType.leaderboard,
        targetCount: 1,
        rewardXp: 100,
      ),
      Achievement(
        id: 'weekly_mvp_3',
        title: 'MVP 3회',
        description: '주간 리더보드 1등 3회 달성',
        iconEmoji: '🏆',
        tier: AchievementTier.gold,
        type: AchievementType.leaderboard,
        targetCount: 3,
        rewardXp: 300,
        rewardAvatarItem: 'accessory_mvp_crown',
      ),
      Achievement(
        id: 'consistent_performer',
        title: '꾸준한 성과',
        description: '주간 리더보드 상위 3위 10회 달성',
        iconEmoji: '📊',
        tier: AchievementTier.silver,
        type: AchievementType.leaderboard,
        targetCount: 10,
        rewardXp: 250,
      ),
    ];
  }

  // 팀워크 업적
  static List<Achievement> getTeamworkAchievements() {
    return [
      Achievement(
        id: 'team_player',
        title: '팀플레이어',
        description: '가족 협력 목표 5회 달성',
        iconEmoji: '🤝',
        tier: AchievementTier.silver,
        type: AchievementType.teamwork,
        targetCount: 5,
        rewardXp: 150,
      ),
      Achievement(
        id: 'team_champion',
        title: '팀워크 챔피언',
        description: '가족 협력 목표 20회 달성',
        iconEmoji: '👨‍👩‍👧‍👦',
        tier: AchievementTier.gold,
        type: AchievementType.teamwork,
        targetCount: 20,
        rewardXp: 500,
        rewardAvatarItem: 'accessory_family_badge',
      ),
      Achievement(
        id: 'harmony',
        title: '화목한 가정',
        description: '한 주 동안 모든 가족 구성원이 집안일 완료',
        iconEmoji: '💖',
        tier: AchievementTier.gold,
        type: AchievementType.teamwork,
        targetCount: 1,
        rewardXp: 200,
      ),
    ];
  }

  // 한국 특화 업적
  static List<Achievement> getKoreanSpecialAchievements() {
    return [
      Achievement(
        id: 'kimchi_lover',
        title: '김치 마스터',
        description: '김치냉장고 정리 10회 완료',
        iconEmoji: '🥬',
        tier: AchievementTier.silver,
        type: AchievementType.korean,
        targetCount: 10,
        rewardXp: 100,
        rewardAvatarItem: 'accessory_kimchi_badge',
      ),
      Achievement(
        id: 'kimjang_hero',
        title: '김장철 영웅',
        description: '김장 관련 집안일 10회 완료',
        iconEmoji: '🏮',
        tier: AchievementTier.gold,
        type: AchievementType.korean,
        targetCount: 10,
        rewardXp: 300,
      ),
      Achievement(
        id: 'holiday_master',
        title: '명절의 신',
        description: '명절 준비 체크리스트 완료',
        iconEmoji: '🎊',
        tier: AchievementTier.gold,
        type: AchievementType.korean,
        targetCount: 1,
        rewardXp: 250,
        rewardAvatarItem: 'outfit_hanbok',
      ),
      Achievement(
        id: 'recycling_expert',
        title: '분리수거 전문가',
        description: '분리수거 30회 완료',
        iconEmoji: '♻️',
        tier: AchievementTier.silver,
        type: AchievementType.korean,
        targetCount: 30,
        rewardXp: 150,
        rewardAvatarItem: 'accessory_eco_badge',
      ),
      Achievement(
        id: 'spring_cleaner',
        title: '봄맞이 대청소 완료',
        description: '봄맞이 대청소 완료하기',
        iconEmoji: '🌸',
        tier: AchievementTier.silver,
        type: AchievementType.seasonal,
        targetCount: 1,
        rewardXp: 200,
      ),
      Achievement(
        id: 'season_master',
        title: '환절기 챔피언',
        description: '계절 옷 정리 4회 완료',
        iconEmoji: '🍂',
        tier: AchievementTier.gold,
        type: AchievementType.seasonal,
        targetCount: 4,
        rewardXp: 300,
      ),
      Achievement(
        id: 'shoe_organizer',
        title: '신발장 정리의 달인',
        description: '현관 신발장 정리 20회 완료',
        iconEmoji: '👞',
        tier: AchievementTier.bronze,
        type: AchievementType.korean,
        targetCount: 20,
        rewardXp: 100,
      ),
    ];
  }

  // 숨겨진 업적 (시크릿 업적)
  static List<Achievement> getSecretAchievements() {
    return [
      Achievement(
        id: 'midnight_warrior',
        title: '자정의 전사',
        description: '자정(00:00~01:00)에 집안일 완료',
        iconEmoji: '🌙',
        tier: AchievementTier.gold,
        type: AchievementType.choreCount,
        targetCount: 1,
        rewardXp: 100,
        isSecret: true,
      ),
      Achievement(
        id: 'early_bird',
        title: '일찍 일어나는 새',
        description: '새벽 5시~6시에 집안일 완료',
        iconEmoji: '🐦',
        tier: AchievementTier.silver,
        type: AchievementType.choreCount,
        targetCount: 10,
        rewardXp: 150,
        isSecret: true,
      ),
      Achievement(
        id: 'perfectionist',
        title: '완벽주의자',
        description: '한 주 동안 모든 예정된 집안일 100% 완료',
        iconEmoji: '💎',
        tier: AchievementTier.platinum,
        type: AchievementType.choreCount,
        targetCount: 1,
        rewardXp: 500,
        isSecret: true,
      ),
    ];
  }

  // ID로 업적 찾기
  static Achievement? findById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // 타입별 업적 가져오기
  static List<Achievement> getByType(AchievementType type) {
    return getAllAchievements().where((a) => a.type == type).toList();
  }

  // 티어별 업적 가져오기
  static List<Achievement> getByTier(AchievementTier tier) {
    return getAllAchievements().where((a) => a.tier == tier).toList();
  }
}
