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
    final isAnonymous = authProvider.isAnonymous;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '계정 정보',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (isAnonymous)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '게스트',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: isAnonymous
                              ? Icon(
                                  Icons.person_outline,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                )
                              : Text(
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
                                isAnonymous ? '게스트 사용자' : (user?.name ?? '사용자'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAnonymous ? '로그인하지 않은 상태' : (user?.email ?? ''),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isAnonymous) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '게스트 모드로 사용 중입니다. 계정을 만들면 데이터를 영구적으로 저장할 수 있습니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLinkAccountDialog(context),
                          icon: const Icon(Icons.person_add),
                          label: const Text('계정 만들기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
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

  void _showLinkAccountDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 만들기'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '게스트 계정을 정식 계정으로 전환합니다.\n현재까지의 모든 데이터가 보존됩니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    hintText: '홍길동',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    hintText: '6자 이상',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 최소 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력하세요',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해주세요';
                    }
                    if (value != passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(context); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final authProvider = context.read<AuthProvider>();
                await authProvider.linkAnonymousAccountWithEmail(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
                );

                if (!context.mounted) return;
                Navigator.pop(context); // Close loading

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('계정이 성공적으로 생성되었습니다! 🎉'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context); // Close loading

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('계정 생성 실패: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('계정 만들기'),
          ),
        ],
      ),
    );
  }
}
