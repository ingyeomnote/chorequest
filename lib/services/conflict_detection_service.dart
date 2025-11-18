import '../models/user_model.dart';
import '../models/chore_model.dart';
import '../utils/logger.dart';

// 갈등 감지 & 관계 개선 서비스
class ConflictDetectionService {
  static final ConflictDetectionService _instance = ConflictDetectionService._internal();
  factory ConflictDetectionService() => _instance;
  ConflictDetectionService._internal();

  // 불균형 감지
  ConflictReport detectImbalance({
    required List<UserModel> householdMembers,
    required Map<String, List<ChoreModel>> memberChores, // userId -> chores
    required int daysToAnalyze,
  }) {
    logger.i('Detecting imbalance for ${householdMembers.length} members over $daysToAnalyze days');

    // 각 멤버별 부담 계산
    final workloadMap = <String, WorkloadStats>{};
    int totalChores = 0;
    int totalMinutes = 0;
    int totalXP = 0;

    for (final member in householdMembers) {
      final chores = memberChores[member.id] ?? [];
      final completedChores = chores.where((c) => c.status == ChoreStatus.completed).toList();

      final stats = WorkloadStats(
        userId: member.id,
        userName: member.name,
        choreCount: completedChores.length,
        totalMinutes: _calculateTotalMinutes(completedChores),
        totalXP: _calculateTotalXP(completedChores),
        emotionalLaborCount: _calculateEmotionalLabor(member, memberChores),
      );

      workloadMap[member.id] = stats;
      totalChores += stats.choreCount;
      totalMinutes += stats.totalMinutes;
      totalXP += stats.totalXP;
    }

    // 평균 계산
    final avgChores = totalChores / householdMembers.length;
    final avgMinutes = totalMinutes / householdMembers.length;

    // 불균형 감지 (차이가 30% 이상이면 경고)
    final imbalances = <Imbalance>[];

    for (final stats in workloadMap.values) {
      final choreDiff = (stats.choreCount - avgChores) / avgChores;
      final minuteDiff = (stats.totalMinutes - avgMinutes) / avgMinutes;

      if (choreDiff.abs() > 0.3 || minuteDiff.abs() > 0.3) {
        imbalances.add(Imbalance(
          userId: stats.userId,
          userName: stats.userName,
          type: choreDiff > 0 ? ImbalanceType.overworked : ImbalanceType.underworked,
          choreDifference: stats.choreCount - avgChores.toInt(),
          minuteDifference: stats.totalMinutes - avgMinutes.toInt(),
          severity: _calculateSeverity(choreDiff.abs(), minuteDiff.abs()),
        ));
      }
    }

    // 연속 비활동 감지
    final inactivityWarnings = <InactivityWarning>[];
    for (final member in householdMembers) {
      final daysSinceLastActivity = _getDaysSinceLastActivity(member);
      if (daysSinceLastActivity > 3) {
        inactivityWarnings.add(InactivityWarning(
          userId: member.id,
          userName: member.name,
          daysSinceLastActivity: daysSinceLastActivity,
        ));
      }
    }

    // 충돌 위험도 계산
    final conflictRisk = _calculateConflictRisk(imbalances, inactivityWarnings);

    return ConflictReport(
      analysisDate: DateTime.now(),
      daysAnalyzed: daysToAnalyze,
      workloadStats: workloadMap.values.toList(),
      imbalances: imbalances,
      inactivityWarnings: inactivityWarnings,
      conflictRisk: conflictRisk,
      suggestions: _generateSuggestions(imbalances, inactivityWarnings, workloadMap),
    );
  }

  // 감정 노동 계산
  EmotionalLaborReport calculateEmotionalLabor({
    required UserModel user,
    required Map<String, List<ChoreModel>> allMemberChores,
    required int daysToAnalyze,
  }) {
    // 집안일 계획 세우기 (새 집안일 생성 횟수)
    final createdChores = allMemberChores[user.id]
            ?.where((c) =>
                c.createdAt != null &&
                DateTime.now().difference(c.createdAt!).inDays <= daysToAnalyze)
            .length ??
        0;

    // 일정 조율 (집안일 수정 횟수)
    final modifiedChores = allMemberChores[user.id]
            ?.where((c) =>
                c.updatedAt != null &&
                DateTime.now().difference(c.updatedAt).inDays <= daysToAnalyze)
            .length ??
        0;

    // 식단 고민 (요리 관련 집안일 횟수)
    final mealPlanningChores = allMemberChores[user.id]
            ?.where((c) =>
                c.title.contains('요리') ||
                c.title.contains('식사') ||
                c.title.contains('도시락') ||
                c.title.contains('장보기'))
            .length ??
        0;

    // 감정 노동 가치 계산 (시급 1만원 기준)
    final hourlyRate = 10000;
    final planningMinutes = createdChores * 10; // 집안일 1개당 10분
    final coordinationMinutes = modifiedChores * 5; // 수정 1번당 5분
    final mealPlanningMinutes = mealPlanningChores * 30; // 식사 계획 1번당 30분

    final totalMinutes = planningMinutes + coordinationMinutes + mealPlanningMinutes;
    final monetaryValue = (totalMinutes / 60 * hourlyRate).round();

    return EmotionalLaborReport(
      userId: user.id,
      userName: user.name,
      planningCount: createdChores,
      coordinationCount: modifiedChores,
      mealPlanningCount: mealPlanningChores,
      totalMinutes: totalMinutes,
      monetaryValue: monetaryValue,
    );
  }

  // 자동 중재 제안
  List<MediationSuggestion> generateMediationSuggestions(ConflictReport report) {
    final suggestions = <MediationSuggestion>[];

    // 과부하된 사람에게서 집안일 재배정
    final overworked = report.imbalances
        .where((i) => i.type == ImbalanceType.overworked)
        .toList();
    final underworked = report.imbalances
        .where((i) => i.type == ImbalanceType.underworked)
        .toList();

    for (final over in overworked) {
      for (final under in underworked) {
        suggestions.add(MediationSuggestion(
          type: MediationType.reassignChores,
          fromUserId: over.userId,
          toUserId: under.userId,
          message: '${under.userName}님께 일부 집안일을 재배정하면 어떨까요?',
          choreCountToMove: (over.choreDifference / 2).abs().round(),
        ));
      }
    }

    // 비활동 사용자에게 부드러운 알림
    for (final warning in report.inactivityWarnings) {
      suggestions.add(MediationSuggestion(
        type: MediationType.gentleReminder,
        toUserId: warning.userId,
        message: '${warning.userName}님, 요즘 바쁘신가요? 오늘은 간단한 집안일 하나 어떠세요? 😊',
      ));
    }

    // 고위험 갈등의 경우 대화 제안
    if (report.conflictRisk == ConflictRisk.high) {
      suggestions.add(MediationSuggestion(
        type: MediationType.conversationPrompt,
        message: '가족 회의를 통해 집안일 분담을 다시 조정하는 시간을 가져보는 건 어떨까요?',
      ));
    }

    return suggestions;
  }

  // 칭찬 메시지 자동 생성
  PraiseMessage generatePraiseMessage({
    required UserModel user,
    required ChoreModel completedChore,
  }) {
    final templates = [
      '${user.name}님이 "${completedChore.title}" 완료했어요! 수고하셨어요! 👏',
      '와! ${user.name}님 덕분에 집이 깨끗해졌어요! "${completedChore.title}" 감사합니다 ❤️',
      '${user.name}님 최고! "${completedChore.title}" 완료! 🎉',
      '${user.name}님의 노력 덕분에 가족 모두가 편안해졌어요. "${completedChore.title}" 고마워요! 🙏',
      '짝짝짝! 👏 ${user.name}님이 "${completedChore.title}" 해주셨네요!',
    ];

    final random = DateTime.now().millisecond % templates.length;

    return PraiseMessage(
      recipientId: user.id,
      recipientName: user.name,
      choreTitle: completedChore.title,
      message: templates[random],
      suggestedReply: '${user.name}님, 고마워요! ❤️',
    );
  }

  // Private helpers

  int _calculateTotalMinutes(List<ChoreModel> chores) {
    return chores.fold(0, (sum, chore) => sum + (chore.estimatedMinutes ?? 30));
  }

  int _calculateTotalXP(List<ChoreModel> chores) {
    return chores.fold(0, (sum, chore) {
      switch (chore.difficulty) {
        case ChoreDifficulty.easy:
          return sum + 10;
        case ChoreDifficulty.hard:
          return sum + 50;
        default:
          return sum + 25;
      }
    });
  }

  int _calculateEmotionalLabor(UserModel user, Map<String, List<ChoreModel>> memberChores) {
    // 간단 버전: 집안일 생성 및 배정을 한 횟수로 추정
    // 실제로는 별도 추적 필요
    return 0;
  }

  int _getDaysSinceLastActivity(UserModel user) {
    if (user.lastActivityAt == null) return 999;
    return DateTime.now().difference(user.lastActivityAt!).inDays;
  }

  ImbalanceSeverity _calculateSeverity(double choreDiff, double minuteDiff) {
    final avgDiff = (choreDiff + minuteDiff) / 2;

    if (avgDiff > 0.6) return ImbalanceSeverity.critical;
    if (avgDiff > 0.4) return ImbalanceSeverity.high;
    if (avgDiff > 0.3) return ImbalanceSeverity.medium;
    return ImbalanceSeverity.low;
  }

  ConflictRisk _calculateConflictRisk(
    List<Imbalance> imbalances,
    List<InactivityWarning> warnings,
  ) {
    int score = 0;

    // 불균형 점수
    for (final imbalance in imbalances) {
      switch (imbalance.severity) {
        case ImbalanceSeverity.critical:
          score += 30;
          break;
        case ImbalanceSeverity.high:
          score += 20;
          break;
        case ImbalanceSeverity.medium:
          score += 10;
          break;
        case ImbalanceSeverity.low:
          score += 5;
          break;
      }
    }

    // 비활동 점수
    score += warnings.length * 10;

    // 위험도 판정
    if (score > 50) return ConflictRisk.high;
    if (score > 30) return ConflictRisk.medium;
    if (score > 10) return ConflictRisk.low;
    return ConflictRisk.none;
  }

  List<String> _generateSuggestions(
    List<Imbalance> imbalances,
    List<InactivityWarning> warnings,
    Map<String, WorkloadStats> workloadMap,
  ) {
    final suggestions = <String>[];

    if (imbalances.isNotEmpty) {
      suggestions.add('집안일 분담이 불균형합니다. 자동 재배정을 고려해보세요.');
    }

    if (warnings.isNotEmpty) {
      suggestions.add('일부 구성원의 참여가 줄었습니다. 부드러운 알림을 보내보세요.');
    }

    if (imbalances.isEmpty && warnings.isEmpty) {
      suggestions.add('훌륭해요! 집안일이 공정하게 분담되고 있습니다. 👏');
    }

    return suggestions;
  }
}

// 갈등 보고서
class ConflictReport {
  final DateTime analysisDate;
  final int daysAnalyzed;
  final List<WorkloadStats> workloadStats;
  final List<Imbalance> imbalances;
  final List<InactivityWarning> inactivityWarnings;
  final ConflictRisk conflictRisk;
  final List<String> suggestions;

  ConflictReport({
    required this.analysisDate,
    required this.daysAnalyzed,
    required this.workloadStats,
    required this.imbalances,
    required this.inactivityWarnings,
    required this.conflictRisk,
    required this.suggestions,
  });

  bool get hasIssues => imbalances.isNotEmpty || inactivityWarnings.isNotEmpty;
}

// 작업 부하 통계
class WorkloadStats {
  final String userId;
  final String userName;
  final int choreCount;
  final int totalMinutes;
  final int totalXP;
  final int emotionalLaborCount;

  WorkloadStats({
    required this.userId,
    required this.userName,
    required this.choreCount,
    required this.totalMinutes,
    required this.totalXP,
    required this.emotionalLaborCount,
  });

  double getWorkloadPercentage(int totalChores) {
    if (totalChores == 0) return 0.0;
    return (choreCount / totalChores) * 100;
  }
}

// 불균형
class Imbalance {
  final String userId;
  final String userName;
  final ImbalanceType type;
  final int choreDifference;
  final int minuteDifference;
  final ImbalanceSeverity severity;

  Imbalance({
    required this.userId,
    required this.userName,
    required this.type,
    required this.choreDifference,
    required this.minuteDifference,
    required this.severity,
  });
}

enum ImbalanceType { overworked, underworked }

enum ImbalanceSeverity { low, medium, high, critical }

// 비활동 경고
class InactivityWarning {
  final String userId;
  final String userName;
  final int daysSinceLastActivity;

  InactivityWarning({
    required this.userId,
    required this.userName,
    required this.daysSinceLastActivity,
  });
}

// 갈등 위험도
enum ConflictRisk { none, low, medium, high }

// 중재 제안
class MediationSuggestion {
  final MediationType type;
  final String? fromUserId;
  final String? toUserId;
  final String message;
  final int? choreCountToMove;

  MediationSuggestion({
    required this.type,
    this.fromUserId,
    this.toUserId,
    required this.message,
    this.choreCountToMove,
  });
}

enum MediationType { reassignChores, gentleReminder, conversationPrompt }

// 감정 노동 보고서
class EmotionalLaborReport {
  final String userId;
  final String userName;
  final int planningCount; // 계획 세운 횟수
  final int coordinationCount; // 조율한 횟수
  final int mealPlanningCount; // 식단 계획 횟수
  final int totalMinutes; // 총 소요 시간
  final int monetaryValue; // 금전적 가치 (원)

  EmotionalLaborReport({
    required this.userId,
    required this.userName,
    required this.planningCount,
    required this.coordinationCount,
    required this.mealPlanningCount,
    required this.totalMinutes,
    required this.monetaryValue,
  });
}

// 칭찬 메시지
class PraiseMessage {
  final String recipientId;
  final String recipientName;
  final String choreTitle;
  final String message;
  final String suggestedReply;

  PraiseMessage({
    required this.recipientId,
    required this.recipientName,
    required this.choreTitle,
    required this.message,
    required this.suggestedReply,
  });
}
