import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Member Invitation Screen
///
/// Part of collaborative onboarding. Allows household creator to:
/// 1. Share invite link via KakaoTalk, SMS, etc.
/// 2. Copy invite code
/// 3. Skip and invite later
///
/// Emphasizes inviting all members NOW to prevent app manager trap.
class InviteMembersScreen extends StatefulWidget {
  final String householdId;
  final String householdName;

  const InviteMembersScreen({
    super.key,
    required this.householdId,
    required this.householdName,
  });

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  late String _inviteCode;
  late String _inviteLink;

  @override
  void initState() {
    super.initState();
    _inviteCode = _generateInviteCode();
    _inviteLink = 'https://chorequest.app/join/$_inviteCode';
  }

  String _generateInviteCode() {
    // Generate 6-character code from householdId
    return widget.householdId.substring(0, 6).toUpperCase();
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('초대 코드가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareInviteLink() {
    final message = '''
🏠 ChoreQuest 초대장

${widget.householdName}에 초대합니다!

함께 집안일을 관리하고, 레벨업하면서 즐겁게 생활해요.

초대 코드: $_inviteCode
링크: $_inviteLink

※ 모두가 함께 설정하면 더 공정하고 지속 가능해요!
''';

    Share.share(message, subject: 'ChoreQuest 초대');
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _next() {
    // Navigate to role assignment (if members joined) or home
    Navigator.pushReplacementNamed(
      context,
      '/onboarding/role-assignment',
      arguments: {'householdId': widget.householdId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('멤버 초대'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('나중에'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                '가족을 초대하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '모두가 함께 설정하면\n더 공정하고 지속 가능해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Invite code card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      '초대 코드',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _inviteCode,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Colors.green[700],
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _copyInviteCode,
                          icon: const Icon(Icons.copy),
                          color: Colors.green[700],
                          tooltip: '코드 복사',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Share buttons
              _buildShareButton(
                icon: Icons.share,
                label: '초대 링크 공유',
                subtitle: 'KakaoTalk, 문자, 이메일 등',
                color: Colors.blue,
                onPressed: _shareInviteLink,
              ),

              const SizedBox(height: 12),

              _buildShareButton(
                icon: Icons.message_outlined,
                label: 'KakaoTalk으로 초대',
                subtitle: '가족 단체 채팅방에 공유',
                color: Colors.amber[700]!,
                onPressed: () {
                  // TODO: KakaoTalk share implementation
                  _shareInviteLink();
                },
              ),

              const Spacer(),

              // Important tip
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '혼자 설정하면 "앱 관리자"가 되어\n정신적 부담이 커질 수 있어요!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('나중에 초대'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '멤버가 합류했어요',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onPressed,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
