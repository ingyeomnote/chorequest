import 'package:cloud_functions/cloud_functions.dart';
import '../models/chore_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

/// 카카오톡 메시지 API 서비스
/// 보안을 위해 클라이언트에서 직접 카카오 API를 호출하지 않고,
/// Firebase Cloud Functions를 통해 안전하게 전송합니다.
class KakaoMessageService {
  static final KakaoMessageService _instance = KakaoMessageService._internal();
  factory KakaoMessageService() => _instance;
  KakaoMessageService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // 오늘의 할 일 전송
  Future<bool> sendDailyChores({
    required UserModel user,
    required List<ChoreModel> todayChores,
  }) async {
    try {
      // Cloud Function 호출
      final result = await _functions.httpsCallable('sendDailyChores').call({
        'userId': user.id,
        'choreIds': todayChores.map((c) => c.id).toList(),
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send daily chores via Cloud Functions: $e');
      return false;
    }
  }

  // 마감 임박 알림
  Future<bool> sendDueSoonReminder({
    required UserModel user,
    required ChoreModel chore,
    required int hoursRemaining,
  }) async {
    try {
      final result = await _functions.httpsCallable('sendDueSoonReminder').call({
        'userId': user.id,
        'choreId': chore.id,
        'hoursRemaining': hoursRemaining,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send due soon reminder: $e');
      return false;
    }
  }

  // 칭찬 메시지 전송
  Future<bool> sendPraiseMessage({
    required String recipientName,
    required String choreTitle,
    String? customMessage,
  }) async {
    try {
      final result = await _functions.httpsCallable('sendPraiseMessage').call({
        'recipientName': recipientName,
        'choreTitle': choreTitle,
        'customMessage': customMessage,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send praise message: $e');
      return false;
    }
  }

  // 스트릭 위험 경고
  Future<bool> sendStreakAtRiskWarning({
    required UserModel user,
    required int currentStreak,
  }) async {
    try {
      final result = await _functions.httpsCallable('sendStreakAtRiskWarning').call({
        'userId': user.id,
        'currentStreak': currentStreak,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send streak warning: $e');
      return false;
    }
  }

  // 레벨업 축하 메시지
  Future<bool> sendLevelUpCongrats({
    required UserModel user,
    required int newLevel,
    required List<String> unlockedItems,
  }) async {
    try {
      final result = await _functions.httpsCallable('sendLevelUpCongrats').call({
        'userId': user.id,
        'newLevel': newLevel,
        'unlockedItems': unlockedItems,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send level up message: $e');
      return false;
    }
  }

  // 불균형 감지 알림
  Future<bool> sendImbalanceWarning({
    required String userName,
    required String message,
  }) async {
    try {
      final result = await _functions.httpsCallable('sendImbalanceWarning').call({
        'userName': userName,
        'message': message,
      });

      return result.data['success'] ?? false;
    } catch (e) {
      logger.e('Failed to send imbalance warning: $e');
      return false;
    }
  }

  // Helper methods (UI용)
  String getDifficultyIcon(ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return '⭐';
      case ChoreDifficulty.medium:
        return '⭐⭐';
      case ChoreDifficulty.hard:
        return '⭐⭐⭐';
    }
  }
}

/// 카카오톡 빠른 완료 핸들러
/// 카카오톡 버튼 클릭 -> 앱으로 딥링크 -> 집안일 자동 완료
class KakaoQuickCompleteHandler {
  // 딥링크 파싱 및 집안일 완료 처리
  static Future<bool> handleQuickComplete(String choreId) async {
    try {
      logger.i('Quick complete requested for chore: $choreId');

      // 실제 구현: ChoreProvider.completeChore() 호출
      // 여기서는 인터페이스만 정의

      return true;
    } catch (e) {
      logger.e('Failed to quick complete chore: $e');
      return false;
    }
  }
}

/// 카카오톡 봇 대화 플로우
class KakaoBotConversation {
  static String getGreeting(String userName) {
    return '''
안녕하세요, ${userName}님! 👋
ChoreQuest 카카오톡 봇입니다.

다음 명령어를 사용할 수 있어요:
📋 오늘 - 오늘의 할 일 보기
✅ 완료 - 집안일 완료하기
📊 통계 - 내 통계 보기
🏆 랭킹 - 가족 리더보드
💡 도움 - 도움말
    ''';
  }

  static String getTodayChoresList(List<ChoreModel> chores) {
    if (chores.isEmpty) {
      return '오늘 할 집안일이 없어요! 🎉\n여유롭게 쉬세요~';
    }

    final choreList = chores.take(5).map((chore) {
      final icon = _getStatusIcon(chore.status);
      return '$icon ${chore.title}';
    }).join('\n');

    return '''
📋 오늘의 할 일 (${chores.length}개)

$choreList
${chores.length > 5 ? '\n외 ${chores.length - 5}개...' : ''}

✅ "완료 1" 입력으로 첫 번째 집안일 완료!
    ''';
  }

  static String getStatsMessage(UserModel user) {
    return '''
📊 ${user.name}님의 통계

🏅 레벨: ${user.level}
⭐ XP: ${user.xp}/${user.getXpForNextLevel()}
🔥 연속: ${user.currentStreak}일 (최고: ${user.longestStreak}일)
🏆 업적: ${user.achievements.length}개

계속해서 성장 중이에요! 💪
    ''';
  }

  static String _getStatusIcon(ChoreStatus status) {
    switch (status) {
      case ChoreStatus.pending:
        return '⏳';
      case ChoreStatus.completed:
        return '✅';
      case ChoreStatus.overdue:
        return '🚨';
    }
  }
}
