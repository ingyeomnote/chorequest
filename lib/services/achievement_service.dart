import '../models/achievement_model.dart';
import '../models/user_model.dart';
import '../data/achievements_data.dart';
import '../utils/logger.dart';

// 업적 관리 서비스
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  // 사용자의 업적 진행 상황 업데이트
  List<Achievement> checkAndUpdateAchievements({
    required UserModel user,
    required Map<String, UserAchievement> userAchievements,
    required Map<String, int> choreStats, // choreCount, specificChore counts 등
  }) {
    final newlyCompleted = <Achievement>[];
    final allAchievements = AchievementsData.getAllAchievements();

    for (final achievement in allAchievements) {
      // 이미 완료한 업적은 스킵
      final userAchievement = userAchievements[achievement.id];
      if (userAchievement != null && userAchievement.isCompleted) {
        continue;
      }

      // 업적 타입별 진행도 계산
      final currentProgress = _calculateProgress(achievement, user, choreStats);

      // 진행도 업데이트
      if (userAchievement == null) {
        // 새로운 업적
        final newUserAchievement = UserAchievement(
          achievementId: achievement.id,
          currentProgress: currentProgress,
        );
        newUserAchievement.updateProgress(currentProgress, achievement.targetCount);
        userAchievements[achievement.id] = newUserAchievement;

        if (newUserAchievement.isCompleted) {
          newlyCompleted.add(achievement);
          logger.i('Achievement unlocked: ${achievement.title}');
        }
      } else {
        // 기존 업적 업데이트
        final oldProgress = userAchievement.currentProgress;
        userAchievement.updateProgress(currentProgress, achievement.targetCount);

        if (userAchievement.isCompleted && oldProgress < achievement.targetCount) {
          newlyCompleted.add(achievement);
          logger.i('Achievement unlocked: ${achievement.title}');
        }
      }
    }

    return newlyCompleted;
  }

  // 진행도 계산
  int _calculateProgress(
    Achievement achievement,
    UserModel user,
    Map<String, int> choreStats,
  ) {
    switch (achievement.type) {
      case AchievementType.choreCount:
        // 총 집안일 완료 횟수
        return choreStats['totalChores'] ?? 0;

      case AchievementType.specificChore:
        // 특정 집안일 (예: 설거지, 청소 등)
        final specificKey = 'specific_${achievement.id}';
        return choreStats[specificKey] ?? 0;

      case AchievementType.streak:
        // 연속 달성 (최고 기록 기준)
        return user.longestStreak;

      case AchievementType.level:
        // 레벨 달성
        return user.level;

      case AchievementType.leaderboard:
        // 리더보드 순위 달성 횟수
        return choreStats['leaderboard_${achievement.id}'] ?? 0;

      case AchievementType.teamwork:
        // 팀워크 목표 달성 횟수
        return choreStats['teamwork_goals'] ?? 0;

      case AchievementType.seasonal:
      case AchievementType.korean:
        // 계절/한국 특화 업적
        final key = 'seasonal_${achievement.id}';
        return choreStats[key] ?? 0;

      default:
        return 0;
    }
  }

  // 특정 업적 달성 여부 확인
  bool isAchievementUnlocked(
    String achievementId,
    Map<String, UserAchievement> userAchievements,
  ) {
    final userAchievement = userAchievements[achievementId];
    return userAchievement != null && userAchievement.isCompleted;
  }

  // 완료한 업적 목록
  List<Achievement> getCompletedAchievements(
    Map<String, UserAchievement> userAchievements,
  ) {
    final completed = <Achievement>[];
    final allAchievements = AchievementsData.getAllAchievements();

    for (final achievement in allAchievements) {
      if (isAchievementUnlocked(achievement.id, userAchievements)) {
        completed.add(achievement);
      }
    }

    return completed;
  }

  // 진행 중인 업적 목록
  List<Map<String, dynamic>> getInProgressAchievements(
    Map<String, UserAchievement> userAchievements,
  ) {
    final inProgress = <Map<String, dynamic>>[];
    final allAchievements = AchievementsData.getAllAchievements();

    for (final achievement in allAchievements) {
      final userAchievement = userAchievements[achievement.id];

      if (achievement.isSecret && userAchievement == null) {
        // 숨겨진 업적은 진행 전에는 표시 안 함
        continue;
      }

      if (userAchievement != null && !userAchievement.isCompleted) {
        inProgress.add({
          'achievement': achievement,
          'userAchievement': userAchievement,
          'progress': userAchievement.getProgressRate(achievement.targetCount),
        });
      } else if (userAchievement == null && !achievement.isSecret) {
        // 아직 시작 안 한 업적
        inProgress.add({
          'achievement': achievement,
          'userAchievement': null,
          'progress': 0.0,
        });
      }
    }

    // 진행도 순으로 정렬 (진행도 높은 것부터)
    inProgress.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));

    return inProgress;
  }

  // 티어별 완료 개수
  Map<AchievementTier, int> getCompletedCountByTier(
    Map<String, UserAchievement> userAchievements,
  ) {
    final counts = <AchievementTier, int>{};
    final completed = getCompletedAchievements(userAchievements);

    for (final achievement in completed) {
      counts[achievement.tier] = (counts[achievement.tier] ?? 0) + 1;
    }

    return counts;
  }

  // 총 획득 XP (업적으로부터)
  int getTotalAchievementXp(Map<String, UserAchievement> userAchievements) {
    final completed = getCompletedAchievements(userAchievements);
    return completed.fold(0, (sum, achievement) => sum + achievement.rewardXp);
  }

  // 업적 통계
  Map<String, dynamic> getAchievementStats(
    Map<String, UserAchievement> userAchievements,
  ) {
    final allAchievements = AchievementsData.getAllAchievements();
    final completed = getCompletedAchievements(userAchievements);
    final tierCounts = getCompletedCountByTier(userAchievements);

    return {
      'total': allAchievements.length,
      'completed': completed.length,
      'completionRate': completed.length / allAchievements.length,
      'tierCounts': tierCounts,
      'totalXp': getTotalAchievementXp(userAchievements),
    };
  }
}
