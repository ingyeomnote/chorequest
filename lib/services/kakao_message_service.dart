import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chore_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

/// 카카오톡 메시지 API 서비스
/// 카카오톡으로 집안일 알림, 완료 확인 등을 전송
class KakaoMessageService {
  static final KakaoMessageService _instance = KakaoMessageService._internal();
  factory KakaoMessageService() => _instance;
  KakaoMessageService._internal();

  // 카카오 REST API 키 (환경 변수 또는 Firebase Remote Config에서 로드)
  String? _restApiKey;
  String? _accessToken;

  // Kakao Message API endpoint
  static const String _sendMeUrl = 'https://kapi.kakao.com/v2/api/talk/memo/default/send';
  static const String _sendFriendUrl = 'https://kapi.kakao.com/v1/api/talk/friends/message/default/send';

  // API 키 및 액세스 토큰 설정
  void setCredentials({required String restApiKey, required String accessToken}) {
    _restApiKey = restApiKey;
    _accessToken = accessToken;
  }

  // 나에게 메시지 전송 (테스트용)
  Future<bool> sendToMe(String message) async {
    if (_accessToken == null) {
      logger.e('Kakao access token not set');
      return false;
    }

    try {
      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app',
          'mobile_web_url': 'https://chorequest.app',
        },
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      if (response.statusCode == 200) {
        logger.i('Kakao message sent successfully');
        return true;
      } else {
        logger.e('Kakao API error: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Failed to send Kakao message: $e');
      return false;
    }
  }

  // 오늘의 할 일 전송
  Future<bool> sendDailyChores({
    required UserModel user,
    required List<ChoreModel> todayChores,
  }) async {
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final choreList = todayChores.take(5).map((chore) {
        final difficultyIcon = _getDifficultyIcon(chore.difficulty);
        return '$difficultyIcon ${chore.title}';
      }).join('\n');

      final message = '''
🏠 ChoreQuest - 오늘의 할 일

안녕하세요, ${user.name}님!
오늘 완료해야 할 집안일이 ${todayChores.length}개 있어요.

$choreList

${todayChores.length > 5 ? '\n외 ${todayChores.length - 5}개...' : ''}

💪 오늘도 화이팅!
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app/dashboard',
          'mobile_web_url': 'https://chorequest.app/dashboard',
        },
        'button_title': '앱에서 보기',
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      logger.e('Failed to send daily chores: $e');
      return false;
    }
  }

  // 마감 임박 알림
  Future<bool> sendDueSoonReminder({
    required UserModel user,
    required ChoreModel chore,
    required int hoursRemaining,
  }) async {
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final message = '''
⏰ 마감 임박!

${user.name}님, 집안일 마감이 ${hoursRemaining}시간 남았어요!

📋 ${chore.title}
⏱ 예상 시간: ${chore.estimatedMinutes ?? 30}분
🏆 보상: +${_getXPForDifficulty(chore.difficulty)} XP

지금 바로 완료하고 XP를 받으세요!
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app/chores/${chore.id}',
          'mobile_web_url': 'https://chorequest.app/chores/${chore.id}',
        },
        'button_title': '완료하기',
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
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
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final message = customMessage ??
          '''
👏 칭찬이 도착했어요!

"${choreTitle}" 완료해주셔서 감사해요, ${recipientName}님!

가족 모두가 ${recipientName}님의 노력을 응원합니다! 💕
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app',
          'mobile_web_url': 'https://chorequest.app',
        },
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
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
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final message = '''
🔥 스트릭 위험!

${user.name}님, 오늘 집안일을 완료하지 않으면
${currentStreak}일 연속 기록이 끊깁니다!

💪 지금 바로 간단한 집안일 하나만 완료하고
스트릭을 지켜보세요!

최고 기록: ${user.longestStreak}일
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app/dashboard',
          'mobile_web_url': 'https://chorequest.app/dashboard',
        },
        'button_title': '스트릭 지키기',
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
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
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final itemsList = unlockedItems.take(3).join('\n');

      final message = '''
🎉 레벨 업!

축하합니다, ${user.name}님!
레벨 $newLevel 달성!

🔓 새로운 아이템 해금:
$itemsList
${unlockedItems.length > 3 ? '외 ${unlockedItems.length - 3}개...' : ''}

계속해서 성장하는 ${user.name}님 멋져요! 💪
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': message,
        'link': {
          'web_url': 'https://chorequest.app/avatar',
          'mobile_web_url': 'https://chorequest.app/avatar',
        },
        'button_title': '캐릭터 꾸미기',
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
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
    if (_accessToken == null) {
      throw Exception('Kakao access token not set');
    }

    try {
      final fullMessage = '''
⚠️ 집안일 불균형 감지

$message

ChoreQuest가 공정한 분담을 위한 제안을 준비했어요.
앱에서 확인해보세요!
      ''';

      final templateObject = {
        'object_type': 'text',
        'text': fullMessage,
        'link': {
          'web_url': 'https://chorequest.app/conflict',
          'mobile_web_url': 'https://chorequest.app/conflict',
        },
        'button_title': '제안 보기',
      };

      final response = await http.post(
        Uri.parse(_sendMeUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'template_object': json.encode(templateObject),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      logger.e('Failed to send imbalance warning: $e');
      return false;
    }
  }

  // Helper methods

  String _getDifficultyIcon(ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return '⭐';
      case ChoreDifficulty.medium:
        return '⭐⭐';
      case ChoreDifficulty.hard:
        return '⭐⭐⭐';
    }
  }

  int _getXPForDifficulty(ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return 10;
      case ChoreDifficulty.medium:
        return 25;
      case ChoreDifficulty.hard:
        return 50;
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
