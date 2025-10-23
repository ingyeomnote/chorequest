import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // User Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '계정 정보',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '사용자',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Notifications Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '알림 설정',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('알림 받기'),
            subtitle: const Text('집안일 마감 알림 및 업데이트'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('소리'),
            subtitle: const Text('알림 소리 켜기/끄기'),
            value: _soundEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _soundEnabled = value);
                  }
                : null,
            secondary: const Icon(Icons.volume_up),
          ),
          SwitchListTile(
            title: const Text('진동'),
            subtitle: const Text('알림 진동 켜기/끄기'),
            value: _vibrationEnabled,
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _vibrationEnabled = value);
                  }
                : null,
            secondary: const Icon(Icons.vibration),
          ),

          const Divider(height: 32),

          // Display Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '화면 설정',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('테마'),
            subtitle: const Text('시스템 설정 따르기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Theme selection dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('테마 설정은 곧 지원될 예정입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어'),
            subtitle: const Text('한국어'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Language selection dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('언어 설정은 곧 지원될 예정입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // App Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '앱 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('버전'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('이용약관'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTextDialog(
                context,
                '이용약관',
                '''ChoreQuest 이용약관

1. 서비스 소개
ChoreQuest는 가족 구성원들이 집안일을 관리하고 게임화된 경험을 통해 동기부여를 받을 수 있는 서비스입니다.

2. 개인정보 보호
- 모든 데이터는 로컬 기기에 저장됩니다
- 서버에 개인정보를 전송하지 않습니다
- 사용자의 동의 없이 데이터를 공유하지 않습니다

3. 사용자 책임
- 정확한 정보를 입력해야 합니다
- 서비스를 올바르게 사용해야 합니다
- 부적절한 콘텐츠를 생성하지 말아야 합니다

4. 서비스 변경
- 서비스는 예고 없이 변경될 수 있습니다
- 중요한 변경사항은 사전 공지됩니다

최종 업데이트: 2024년 1월
''',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보처리방침'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTextDialog(
                context,
                '개인정보처리방침',
                '''ChoreQuest 개인정보처리방침

1. 수집하는 정보
- 이름, 이메일 (계정 생성용)
- 집안일 데이터 (앱 기능 제공용)
- 사용 통계 (앱 개선용)

2. 정보의 저장
- 모든 데이터는 사용자 기기에 로컬 저장됩니다
- 외부 서버로 전송되지 않습니다
- 사용자가 직접 데이터를 관리합니다

3. 정보의 사용
- 앱 기능 제공
- 사용자 경험 개선
- 통계 및 분석

4. 정보의 삭제
- 앱 삭제시 모든 데이터가 삭제됩니다
- 사용자가 직접 계정 삭제 가능

5. 보안
- 로컬 데이터베이스 암호화
- 안전한 인증 시스템

문의: support@chorequest.com
최종 업데이트: 2024년 1월
''',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('오픈소스 라이선스'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'ChoreQuest',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 ChoreQuest. All rights reserved.',
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
