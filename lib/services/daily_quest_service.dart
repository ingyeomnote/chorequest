import 'dart:math';
import '../models/daily_quest_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

// 일일 퀘스트 생성 및 관리 서비스
class DailyQuestService {
  static final DailyQuestService _instance = DailyQuestService._internal();
  factory DailyQuestService() => _instance;
  DailyQuestService._internal();

  final Random _random = Random();

  // 오늘의 일일 퀘스트 생성
  List<DailyQuest> generateDailyQuests({
    required int userLevel,
    int questCount = 3,
  }) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=월, 7=일

    final quests = <DailyQuest>[];

    // 1. 기본 퀘스트 (집안일 N개 완료)
    quests.add(_generateChoreCountQuest(userLevel, weekday));

    // 2. 난이도 기반 퀘스트 (주말에 더 어려운 퀘스트)
    if (questCount >= 2) {
      quests.add(_generateDifficultyQuest(userLevel, weekday));
    }

    // 3. 특별 퀘스트 (요일별, 주말, 이벤트 등)
    if (questCount >= 3) {
      quests.add(_generateSpecialQuest(userLevel, weekday));
    }

    logger.i('Generated ${quests.length} daily quests for level $userLevel');
    return quests;
  }

  // 기본 퀘스트: 집안일 N개 완료
  DailyQuest _generateChoreCountQuest(int userLevel, int weekday) {
    final isWeekend = weekday >= 6; // 토, 일

    // 레벨에 따라 목표 조정
    int targetCount;
    int rewardXp;

    if (userLevel < 5) {
      targetCount = isWeekend ? 3 : 2;
      rewardXp = 30;
    } else if (userLevel < 15) {
      targetCount = isWeekend ? 4 : 3;
      rewardXp = 50;
    } else {
      targetCount = isWeekend ? 5 : 4;
      rewardXp = 70;
    }

    return DailyQuest(
      id: 'daily_${DateTime.now().millisecondsSinceEpoch}_chore_count',
      title: '오늘의 미션',
      description: '집안일 $targetCount개 완료하기',
      type: QuestType.choreCount,
      targetCount: targetCount,
      rewardXp: rewardXp,
      difficulty: QuestDifficulty.normal,
      iconEmoji: '✅',
    );
  }

  // 난이도 기반 퀘스트
  DailyQuest _generateDifficultyQuest(int userLevel, int weekday) {
    final isWeekend = weekday >= 6;

    String difficultyName;
    String emoji;
    int targetCount;
    int rewardXp;

    if (isWeekend || _random.nextBool()) {
      // 주말 또는 랜덤으로 어려운 퀘스트
      difficultyName = '어려움';
      emoji = '💪';
      targetCount = userLevel < 10 ? 1 : 2;
      rewardXp = 60;
    } else {
      // 평일 또는 보통 퀘스트
      difficultyName = '보통';
      emoji = '👍';
      targetCount = userLevel < 10 ? 2 : 3;
      rewardXp = 40;
    }

    return DailyQuest(
      id: 'daily_${DateTime.now().millisecondsSinceEpoch}_difficulty',
      title: '$emoji 도전 과제',
      description: '\'$difficultyName\' 난이도 집안일 $targetCount개 완료',
      type: QuestType.difficultyBased,
      targetCount: targetCount,
      rewardXp: rewardXp,
      difficulty: isWeekend ? QuestDifficulty.hard : QuestDifficulty.normal,
      iconEmoji: emoji,
    );
  }

  // 특별 퀘스트 (요일별, 주말, 팀워크 등)
  DailyQuest _generateSpecialQuest(int userLevel, int weekday) {
    final isWeekend = weekday >= 6;

    if (isWeekend) {
      return _generateWeekendQuest(userLevel);
    }

    // 평일: 요일별 특별 퀘스트
    final specialQuests = [
      // 월요일: 월요병 극복
      DailyQuest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_monday',
        title: '월요병 극복!',
        description: '쉬운 집안일 1개로 시작하기',
        type: QuestType.difficultyBased,
        targetCount: 1,
        rewardXp: 20,
        difficulty: QuestDifficulty.easy,
        iconEmoji: '☕',
      ),
      // 화-목: 팀워크 퀘스트 (가족 협력)
      DailyQuest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_teamwork',
        title: '함께하는 집안일',
        description: '가족 구성원과 함께 집안일 완료',
        type: QuestType.teamwork,
        targetCount: 1,
        rewardXp: 50,
        difficulty: QuestDifficulty.normal,
        iconEmoji: '🤝',
      ),
      // 금요일: 불금 준비
      DailyQuest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_friday',
        title: '불금 준비!',
        description: '거실 청소 관련 집안일 완료',
        type: QuestType.categoryBased,
        targetCount: 1,
        rewardXp: 35,
        difficulty: QuestDifficulty.normal,
        iconEmoji: '🎉',
      ),
    ];

    // 월요일이면 첫 번째, 금요일이면 마지막, 나머지는 팀워크
    if (weekday == 1) {
      return specialQuests[0];
    } else if (weekday == 5) {
      return specialQuests[2];
    } else {
      return specialQuests[1];
    }
  }

  // 주말 특별 퀘스트
  DailyQuest _generateWeekendQuest(int userLevel) {
    final weekendQuests = [
      DailyQuest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_weekend_1',
        title: '주말 대청소',
        description: '\'어려움\' 난이도 집안일 2개 완료',
        type: QuestType.difficultyBased,
        targetCount: 2,
        rewardXp: 100,
        difficulty: QuestDifficulty.special,
        iconEmoji: '🧹',
      ),
      DailyQuest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_weekend_2',
        title: '주말 가족 활동',
        description: '가족 모두 집안일 1개 이상 완료',
        type: QuestType.teamwork,
        targetCount: 1,
        rewardXp: 80,
        difficulty: QuestDifficulty.special,
        iconEmoji: '👨‍👩‍👧‍👦',
      ),
    ];

    return weekendQuests[_random.nextInt(weekendQuests.length)];
  }

  // 계절/이벤트 특별 퀘스트 생성
  DailyQuest? generateSeasonalQuest() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // 봄 (3-5월): 환절기 옷 정리
    if (month >= 3 && month <= 5) {
      if (_random.nextDouble() < 0.1) {
        // 10% 확률
        return DailyQuest(
          id: 'seasonal_${now.millisecondsSinceEpoch}_spring',
          title: '봄맞이 정리',
          description: '옷장 정리 또는 환절기 청소',
          type: QuestType.seasonal,
          targetCount: 1,
          rewardXp: 100,
          difficulty: QuestDifficulty.special,
          iconEmoji: '🌸',
        );
      }
    }

    // 가을 (9-11월): 김장 준비
    if (month == 11) {
      if (_random.nextDouble() < 0.2) {
        // 11월에 20% 확률
        return DailyQuest(
          id: 'seasonal_${now.millisecondsSinceEpoch}_kimjang',
          title: '김장 준비',
          description: '김장 관련 집안일 또는 주방 정리',
          type: QuestType.seasonal,
          targetCount: 1,
          rewardXp: 150,
          difficulty: QuestDifficulty.special,
          iconEmoji: '🥬',
        );
      }
    }

    // 명절 전날 (설날, 추석 근처)
    // TODO: 실제 음력 날짜 계산 필요

    return null;
  }

  // 퀘스트 진행도 업데이트
  void updateQuestProgress(DailyQuest quest, int progress) {
    quest.updateProgress(progress);
    logger.d('Quest ${quest.id} progress updated: $progress/${quest.targetCount}');

    if (quest.isCompleted) {
      logger.i('Quest ${quest.id} completed! Reward: ${quest.rewardXp} XP');
    }
  }

  // 모든 퀘스트가 완료되었는지 체크
  bool areAllQuestsCompleted(List<DailyQuest> quests) {
    return quests.every((quest) => quest.isCompleted);
  }

  // 완료된 퀘스트 개수
  int getCompletedQuestCount(List<DailyQuest> quests) {
    return quests.where((quest) => quest.isCompleted).length;
  }

  // 총 획득 가능 XP
  int getTotalRewardXp(List<DailyQuest> quests) {
    return quests.fold(0, (sum, quest) => sum + quest.rewardXp);
  }

  // 획득한 XP
  int getEarnedXp(List<DailyQuest> quests) {
    return quests
        .where((quest) => quest.isCompleted)
        .fold(0, (sum, quest) => sum + quest.rewardXp);
  }

  // 오늘 날짜인지 체크
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 퀘스트가 오늘 것인지 체크
  bool isTodayQuest(DailyQuest quest) {
    return isToday(quest.startDate);
  }

  // 만료된 퀘스트 필터링
  List<DailyQuest> filterExpiredQuests(List<DailyQuest> quests) {
    return quests.where((quest) => !quest.isExpired()).toList();
  }

  // 보너스 XP 계산 (모든 퀘스트 완료 시)
  int calculateCompletionBonus(List<DailyQuest> quests) {
    if (areAllQuestsCompleted(quests)) {
      // 모든 퀘스트 완료 시 총 XP의 50% 보너스
      final totalXp = getTotalRewardXp(quests);
      return (totalXp * 0.5).round();
    }
    return 0;
  }
}
