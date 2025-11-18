import '../models/user_model.dart';
import '../models/chore_model.dart';
import '../utils/logger.dart';

/// B2B 관리자 서비스
/// 기업, 부동산, 산후조리원 등을 위한 대시보드 및 관리 기능
class B2BAdminService {
  static final B2BAdminService _instance = B2BAdminService._internal();
  factory B2BAdminService() => _instance;
  B2BAdminService._internal();

  // 조직 분석
  OrganizationAnalytics analyzeOrganization({
    required Organization organization,
    required List<Household> households,
    required Map<String, List<ChoreModel>> householdChores,
    required int daysToAnalyze,
  }) {
    logger.i('Analyzing organization: ${organization.name}');

    // 전체 통계
    int totalUsers = 0;
    int totalChores = 0;
    int completedChores = 0;
    double totalEngagement = 0;

    final householdStats = <HouseholdStats>[];

    for (final household in households) {
      final chores = householdChores[household.id] ?? [];
      final completed = chores.where((c) => c.status == ChoreStatus.completed).length;

      final stats = HouseholdStats(
        householdId: household.id,
        householdName: household.name,
        memberCount: household.memberIds.length,
        totalChores: chores.length,
        completedChores: completed,
        completionRate: chores.isEmpty ? 0.0 : (completed / chores.length),
        lastActivityDate: _getLastActivity(chores),
      );

      householdStats.add(stats);

      totalUsers += household.memberIds.length;
      totalChores += chores.length;
      completedChores += completed;
      totalEngagement += stats.completionRate;
    }

    final avgEngagement = households.isEmpty ? 0.0 : totalEngagement / households.length;
    final overallCompletionRate = totalChores == 0 ? 0.0 : completedChores / totalChores;

    // 활동 트렌드 (일별)
    final activityTrend = _calculateDailyTrend(householdChores, daysToAnalyze);

    // 인기 집안일
    final popularChores = _getPopularChores(householdChores);

    return OrganizationAnalytics(
      organizationId: organization.id,
      organizationName: organization.name,
      analysisDate: DateTime.now(),
      daysAnalyzed: daysToAnalyze,
      totalHouseholds: households.length,
      totalUsers: totalUsers,
      totalChores: totalChores,
      completedChores: completedChores,
      completionRate: overallCompletionRate,
      averageEngagement: avgEngagement,
      householdStats: householdStats,
      activityTrend: activityTrend,
      popularChores: popularChores,
    );
  }

  // 구독 관리
  SubscriptionStatus getSubscriptionStatus(Organization organization) {
    final now = DateTime.now();

    if (organization.subscriptionEndDate == null) {
      return SubscriptionStatus(
        isActive: false,
        tier: SubscriptionTier.free,
        seatsUsed: organization.currentSeats,
        seatsTotal: 10, // Free tier 제한
        daysRemaining: 0,
        status: 'Inactive',
      );
    }

    final daysRemaining = organization.subscriptionEndDate!.difference(now).inDays;
    final isActive = daysRemaining > 0;

    return SubscriptionStatus(
      isActive: isActive,
      tier: organization.subscriptionTier,
      seatsUsed: organization.currentSeats,
      seatsTotal: _getSeatsForTier(organization.subscriptionTier),
      daysRemaining: daysRemaining,
      status: isActive ? 'Active' : 'Expired',
    );
  }

  // 구독 업그레이드 시뮬레이션
  UpgradeQuote calculateUpgradeQuote({
    required Organization organization,
    required SubscriptionTier targetTier,
  }) {
    final currentPrice = _getPriceForTier(organization.subscriptionTier);
    final targetPrice = _getPriceForTier(targetTier);

    final currentSeats = _getSeatsForTier(organization.subscriptionTier);
    final targetSeats = _getSeatsForTier(targetTier);

    final monthlyDiff = targetPrice - currentPrice;
    final yearlyDiff = monthlyDiff * 12;

    return UpgradeQuote(
      currentTier: organization.subscriptionTier,
      targetTier: targetTier,
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      monthlyDifference: monthlyDiff,
      yearlyDifference: yearlyDiff,
      currentSeats: currentSeats,
      targetSeats: targetSeats,
      estimatedSavings: _calculateSavings(targetTier, yearlyDiff),
    );
  }

  // 멤버 사용량 추적
  List<UserUsageStats> trackUserUsage({
    required List<UserModel> users,
    required Map<String, List<ChoreModel>> userChores,
    required int daysToAnalyze,
  }) {
    final stats = <UserUsageStats>[];

    for (final user in users) {
      final chores = userChores[user.id] ?? [];
      final completed = chores.where((c) => c.status == ChoreStatus.completed).length;

      final lastActivity = user.lastActivityAt ?? user.createdAt;
      final daysSinceLastActivity = DateTime.now().difference(lastActivity).inDays;

      stats.add(UserUsageStats(
        userId: user.id,
        userName: user.name,
        email: user.email,
        level: user.level,
        xp: user.xp,
        totalChores: chores.length,
        completedChores: completed,
        currentStreak: user.currentStreak,
        lastActivityAt: lastActivity,
        daysSinceLastActivity: daysSinceLastActivity,
        isActive: daysSinceLastActivity <= 7,
      ));
    }

    // 활동 순으로 정렬
    stats.sort((a, b) => a.daysSinceLastActivity.compareTo(b.daysSinceLastActivity));

    return stats;
  }

  // 리텐션 분석
  RetentionAnalysis analyzeRetention({
    required List<UserModel> users,
    required int daysToAnalyze,
  }) {
    final now = DateTime.now();
    int activeUsers = 0;
    int dormantUsers = 0;
    int churnedUsers = 0;

    final cohorts = <String, int>{};

    for (final user in users) {
      final daysSinceLastActivity = user.lastActivityAt == null
          ? 999
          : now.difference(user.lastActivityAt!).inDays;

      if (daysSinceLastActivity <= 7) {
        activeUsers++;
      } else if (daysSinceLastActivity <= 30) {
        dormantUsers++;
      } else {
        churnedUsers++;
      }

      // 코호트 분석 (가입 월별)
      final cohortKey = '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}';
      cohorts[cohortKey] = (cohorts[cohortKey] ?? 0) + 1;
    }

    return RetentionAnalysis(
      totalUsers: users.length,
      activeUsers: activeUsers,
      dormantUsers: dormantUsers,
      churnedUsers: churnedUsers,
      activeRate: users.isEmpty ? 0.0 : activeUsers / users.length,
      churnRate: users.isEmpty ? 0.0 : churnedUsers / users.length,
      cohortData: cohorts,
    );
  }

  // 알림 전송 (조직 전체)
  Future<BroadcastResult> sendOrganizationBroadcast({
    required Organization organization,
    required String message,
    required List<String> targetUserIds,
  }) async {
    logger.i('Broadcasting to ${targetUserIds.length} users in ${organization.name}');

    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    // 실제 구현: Firebase Cloud Messaging 또는 카카오톡 API 사용
    for (final userId in targetUserIds) {
      try {
        // 여기서는 인터페이스만 정의
        // await _sendNotification(userId, message);
        successCount++;
      } catch (e) {
        failureCount++;
        errors.add('User $userId: $e');
      }
    }

    return BroadcastResult(
      totalRecipients: targetUserIds.length,
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  // Private helpers

  DateTime _getLastActivity(List<ChoreModel> chores) {
    if (chores.isEmpty) return DateTime(2000);

    return chores
        .where((c) => c.completedAt != null)
        .fold<DateTime>(DateTime(2000), (latest, chore) {
      return chore.completedAt!.isAfter(latest) ? chore.completedAt! : latest;
    });
  }

  Map<String, int> _calculateDailyTrend(
    Map<String, List<ChoreModel>> householdChores,
    int days,
  ) {
    final trend = <String, int>{};
    final now = DateTime.now();

    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      trend[dateKey] = 0;
    }

    for (final chores in householdChores.values) {
      for (final chore in chores) {
        if (chore.completedAt != null) {
          final dateKey =
              '${chore.completedAt!.year}-${chore.completedAt!.month.toString().padLeft(2, '0')}-${chore.completedAt!.day.toString().padLeft(2, '0')}';
          if (trend.containsKey(dateKey)) {
            trend[dateKey] = trend[dateKey]! + 1;
          }
        }
      }
    }

    return trend;
  }

  List<String> _getPopularChores(Map<String, List<ChoreModel>> householdChores) {
    final choreFrequency = <String, int>{};

    for (final chores in householdChores.values) {
      for (final chore in chores) {
        if (chore.status == ChoreStatus.completed) {
          choreFrequency[chore.title] = (choreFrequency[chore.title] ?? 0) + 1;
        }
      }
    }

    final sorted = choreFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).map((e) => '${e.key} (${e.value}회)').toList();
  }

  int _getSeatsForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.basic:
        return 50;
      case SubscriptionTier.pro:
        return 200;
      case SubscriptionTier.enterprise:
        return 999999;
    }
  }

  int _getPriceForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.basic:
        return 50000; // 월 5만원
      case SubscriptionTier.pro:
        return 150000; // 월 15만원
      case SubscriptionTier.enterprise:
        return 500000; // 월 50만원 (협의)
    }
  }

  String _calculateSavings(SubscriptionTier tier, int yearlyPrice) {
    if (tier == SubscriptionTier.free) return '무료';

    // 연간 구독 시 20% 할인
    final yearlyDiscountedPrice = (yearlyPrice * 0.8).round();
    final savings = yearlyPrice - yearlyDiscountedPrice;

    return '연간 구독 시 ${savings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 절약';
  }
}

// 조직 모델
class Organization {
  final String id;
  final String name;
  final OrganizationType type; // realEstate, postpartumCare, corporate
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionEndDate;
  final int currentSeats;
  final String contactEmail;
  final String? billingInfo;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.subscriptionTier,
    this.subscriptionEndDate,
    required this.currentSeats,
    required this.contactEmail,
    this.billingInfo,
  });
}

enum OrganizationType {
  realEstate, // 부동산 관리
  postpartumCare, // 산후조리원
  corporate, // 기업 복지
}

enum SubscriptionTier {
  free,
  basic,
  pro,
  enterprise,
}

// 가구 모델 (간략화)
class Household {
  final String id;
  final String name;
  final List<String> memberIds;

  Household({
    required this.id,
    required this.name,
    required this.memberIds,
  });
}

// 조직 분석 결과
class OrganizationAnalytics {
  final String organizationId;
  final String organizationName;
  final DateTime analysisDate;
  final int daysAnalyzed;
  final int totalHouseholds;
  final int totalUsers;
  final int totalChores;
  final int completedChores;
  final double completionRate;
  final double averageEngagement;
  final List<HouseholdStats> householdStats;
  final Map<String, int> activityTrend;
  final List<String> popularChores;

  OrganizationAnalytics({
    required this.organizationId,
    required this.organizationName,
    required this.analysisDate,
    required this.daysAnalyzed,
    required this.totalHouseholds,
    required this.totalUsers,
    required this.totalChores,
    required this.completedChores,
    required this.completionRate,
    required this.averageEngagement,
    required this.householdStats,
    required this.activityTrend,
    required this.popularChores,
  });
}

// 가구별 통계
class HouseholdStats {
  final String householdId;
  final String householdName;
  final int memberCount;
  final int totalChores;
  final int completedChores;
  final double completionRate;
  final DateTime lastActivityDate;

  HouseholdStats({
    required this.householdId,
    required this.householdName,
    required this.memberCount,
    required this.totalChores,
    required this.completedChores,
    required this.completionRate,
    required this.lastActivityDate,
  });

  bool get isActive => DateTime.now().difference(lastActivityDate).inDays <= 7;
}

// 구독 상태
class SubscriptionStatus {
  final bool isActive;
  final SubscriptionTier tier;
  final int seatsUsed;
  final int seatsTotal;
  final int daysRemaining;
  final String status;

  SubscriptionStatus({
    required this.isActive,
    required this.tier,
    required this.seatsUsed,
    required this.seatsTotal,
    required this.daysRemaining,
    required this.status,
  });

  double get seatUtilization => seatsUsed / seatsTotal;
  bool get isNearLimit => seatUtilization > 0.8;
}

// 업그레이드 견적
class UpgradeQuote {
  final SubscriptionTier currentTier;
  final SubscriptionTier targetTier;
  final int currentPrice;
  final int targetPrice;
  final int monthlyDifference;
  final int yearlyDifference;
  final int currentSeats;
  final int targetSeats;
  final String estimatedSavings;

  UpgradeQuote({
    required this.currentTier,
    required this.targetTier,
    required this.currentPrice,
    required this.targetPrice,
    required this.monthlyDifference,
    required this.yearlyDifference,
    required this.currentSeats,
    required this.targetSeats,
    required this.estimatedSavings,
  });
}

// 사용자 사용량 통계
class UserUsageStats {
  final String userId;
  final String userName;
  final String email;
  final int level;
  final int xp;
  final int totalChores;
  final int completedChores;
  final int currentStreak;
  final DateTime lastActivityAt;
  final int daysSinceLastActivity;
  final bool isActive;

  UserUsageStats({
    required this.userId,
    required this.userName,
    required this.email,
    required this.level,
    required this.xp,
    required this.totalChores,
    required this.completedChores,
    required this.currentStreak,
    required this.lastActivityAt,
    required this.daysSinceLastActivity,
    required this.isActive,
  });

  double get completionRate =>
      totalChores == 0 ? 0.0 : completedChores / totalChores;
}

// 리텐션 분석
class RetentionAnalysis {
  final int totalUsers;
  final int activeUsers;
  final int dormantUsers;
  final int churnedUsers;
  final double activeRate;
  final double churnRate;
  final Map<String, int> cohortData;

  RetentionAnalysis({
    required this.totalUsers,
    required this.activeUsers,
    required this.dormantUsers,
    required this.churnedUsers,
    required this.activeRate,
    required this.churnRate,
    required this.cohortData,
  });
}

// 브로드캐스트 결과
class BroadcastResult {
  final int totalRecipients;
  final int successCount;
  final int failureCount;
  final List<String> errors;

  BroadcastResult({
    required this.totalRecipients,
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  double get successRate =>
      totalRecipients == 0 ? 0.0 : successCount / totalRecipients;
}
