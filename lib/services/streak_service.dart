import '../models/user_model.dart';
import '../utils/logger.dart';

// 스트릭 관리 서비스
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  // 스트릭 업데이트 (집안일 완료 시 호출)
  Future<StreakUpdateResult> updateStreak(UserModel user) async {
    try {
      final now = DateTime.now();
      final lastActivity = user.lastActivityAt;

      if (lastActivity == null) {
        // 첫 활동
        user.currentStreak = 1;
        user.longestStreak = 1;
        user.lastActivityAt = now;

        logger.i('First streak activity for user ${user.id}');
        return StreakUpdateResult(
          newStreak: 1,
          isIncreased: true,
          isBroken: false,
          achievedMilestone: null,
        );
      }

      final lastActivityDate = DateTime(
        lastActivity.year,
        lastActivity.month,
        lastActivity.day,
      );
      final todayDate = DateTime(now.year, now.month, now.day);
      final daysDifference = todayDate.difference(lastActivityDate).inDays;

      if (daysDifference == 0) {
        // 오늘 이미 활동함 - 스트릭 유지
        logger.d('User ${user.id} already active today, streak maintained at ${user.currentStreak}');
        return StreakUpdateResult(
          newStreak: user.currentStreak,
          isIncreased: false,
          isBroken: false,
          achievedMilestone: null,
        );
      } else if (daysDifference == 1) {
        // 어제 활동 → 오늘 활동 = 스트릭 증가
        user.currentStreak++;
        user.lastActivityAt = now;

        // 최고 기록 갱신
        if (user.currentStreak > user.longestStreak) {
          user.longestStreak = user.currentStreak;
        }

        // 마일스톤 체크
        final milestone = _checkMilestone(user.currentStreak);

        logger.i('User ${user.id} streak increased to ${user.currentStreak}');
        return StreakUpdateResult(
          newStreak: user.currentStreak,
          isIncreased: true,
          isBroken: false,
          achievedMilestone: milestone,
        );
      } else {
        // 하루 이상 건너뜀 → 스트릭 깨짐
        final oldStreak = user.currentStreak;
        user.currentStreak = 1; // 오늘부터 다시 시작
        user.lastActivityAt = now;

        logger.w('User ${user.id} streak broken! Old: $oldStreak, New: 1');
        return StreakUpdateResult(
          newStreak: 1,
          isIncreased: false,
          isBroken: true,
          oldStreak: oldStreak,
          achievedMilestone: null,
        );
      }
    } catch (e) {
      logger.e('Error updating streak: $e');
      rethrow;
    }
  }

  // 스트릭 마일스톤 체크 (3, 7, 14, 30, 50, 100, 365일)
  StreakMilestone? _checkMilestone(int streak) {
    const milestones = [3, 7, 14, 30, 50, 100, 365];

    if (milestones.contains(streak)) {
      return StreakMilestone(
        days: streak,
        title: _getMilestoneTitle(streak),
        emoji: _getMilestoneEmoji(streak),
        rewardXp: _getMilestoneRewardXp(streak),
      );
    }
    return null;
  }

  String _getMilestoneTitle(int days) {
    switch (days) {
      case 3:
        return '3일 연속!';
      case 7:
        return '일주일 연속!';
      case 14:
        return '2주 연속!';
      case 30:
        return '한 달 연속!';
      case 50:
        return '50일 연속!';
      case 100:
        return '백일 기념!';
      case 365:
        return '1년 연속!';
      default:
        return '$days일 연속!';
    }
  }

  String _getMilestoneEmoji(int days) {
    switch (days) {
      case 3:
        return '🔥';
      case 7:
        return '⭐';
      case 14:
        return '💫';
      case 30:
        return '🌟';
      case 50:
        return '✨';
      case 100:
        return '💎';
      case 365:
        return '🏅';
      default:
        return '🎉';
    }
  }

  int _getMilestoneRewardXp(int days) {
    switch (days) {
      case 3:
        return 30;
      case 7:
        return 100;
      case 14:
        return 200;
      case 30:
        return 500;
      case 50:
        return 800;
      case 100:
        return 1500;
      case 365:
        return 5000;
      default:
        return days * 10;
    }
  }

  // 스트릭이 위험한지 체크 (마지막 활동이 어제가 아닌 경우)
  bool isStreakAtRisk(UserModel user) {
    if (user.lastActivityAt == null || user.currentStreak == 0) {
      return false;
    }

    final lastActivityDate = DateTime(
      user.lastActivityAt!.year,
      user.lastActivityAt!.month,
      user.lastActivityAt!.day,
    );
    final todayDate = DateTime.now();
    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);

    final daysDifference = today.difference(lastActivityDate).inDays;

    // 오늘 활동하지 않았으면 위험
    return daysDifference > 0;
  }

  // 다음 마일스톤까지 남은 일수
  int getDaysToNextMilestone(int currentStreak) {
    const milestones = [3, 7, 14, 30, 50, 100, 365];

    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone - currentStreak;
      }
    }

    // 365일 이상이면 다음 100의 배수까지
    final next = ((currentStreak ~/ 100) + 1) * 100;
    return next - currentStreak;
  }

  // 다음 마일스톤 정보
  StreakMilestone? getNextMilestone(int currentStreak) {
    const milestones = [3, 7, 14, 30, 50, 100, 365];

    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return StreakMilestone(
          days: milestone,
          title: _getMilestoneTitle(milestone),
          emoji: _getMilestoneEmoji(milestone),
          rewardXp: _getMilestoneRewardXp(milestone),
        );
      }
    }

    return null;
  }

  // 스트릭 프리징 (프리미엄 기능)
  Future<bool> freezeStreak(UserModel user) async {
    // TODO: 프리미엄 사용자 체크
    // TODO: 이번 달 프리징 사용 횟수 체크 (월 1회 제한)

    try {
      // 마지막 활동 날짜를 오늘로 업데이트
      user.lastActivityAt = DateTime.now();

      logger.i('User ${user.id} used streak freeze. Current streak: ${user.currentStreak}');
      return true;
    } catch (e) {
      logger.e('Error freezing streak: $e');
      return false;
    }
  }
}

// 스트릭 업데이트 결과
class StreakUpdateResult {
  final int newStreak;
  final bool isIncreased; // 스트릭이 증가했는지
  final bool isBroken; // 스트릭이 깨졌는지
  final int? oldStreak; // 깨졌을 때 이전 스트릭
  final StreakMilestone? achievedMilestone; // 달성한 마일스톤

  StreakUpdateResult({
    required this.newStreak,
    required this.isIncreased,
    required this.isBroken,
    this.oldStreak,
    this.achievedMilestone,
  });

  bool get hasAchievedMilestone => achievedMilestone != null;
}

// 스트릭 마일스톤
class StreakMilestone {
  final int days;
  final String title;
  final String emoji;
  final int rewardXp;

  StreakMilestone({
    required this.days,
    required this.title,
    required this.emoji,
    required this.rewardXp,
  });
}
