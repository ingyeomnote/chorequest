import 'package:flutter/material.dart';

/// Role Assignment Screen
///
/// Final step of collaborative onboarding.
/// Prevents "app manager trap" by:
/// 1. Showing all members are equal
/// 2. Explaining automatic role rotation
/// 3. No single "admin" role
///
/// This screen educates users about ChoreQuest's philosophy:
/// everyone shares responsibility equally.
class RoleAssignmentScreen extends StatelessWidget {
  final String householdId;

  const RoleAssignmentScreen({
    super.key,
    required this.householdId,
  });

  void _finish(BuildContext context) {
    // Complete onboarding
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('역할 안내'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              const Text(
                '모두가 평등해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ChoreQuest에는 "관리자"가 없어요\n모두가 함께 관리하고 책임집니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Feature cards
              _buildFeatureCard(
                icon: Icons.sync_outlined,
                title: '자동 순환 시스템',
                description: '집안일 담당자가 자동으로 돌아가며 배정돼요',
                color: Colors.blue,
              ),

              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.balance_outlined,
                title: '공평한 부담 분배',
                description: 'XP 시스템으로 각자의 기여도를 객관적으로 측정해요',
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              _buildFeatureCard(
                icon: Icons.people_outline,
                title: '공동 책임',
                description: '누구나 집안일을 추가하고 수정할 수 있어요',
                color: Colors.orange,
              ),

              const Spacer(),

              // Anti-admin trap message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.celebration, color: Colors.purple[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '앱 관리자 함정을 피했어요!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '한 사람이 모든 것을 관리하면 정신적 부담이 커져요. '
                      'ChoreQuest는 모두가 평등하게 참여하도록 설계되었어요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.purple[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Finish button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _finish(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
