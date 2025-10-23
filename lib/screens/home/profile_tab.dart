import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/household_provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';
import 'package:flutter_app/screens/profile/settings_screen.dart';
import 'package:flutter_app/screens/profile/help_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final householdProvider = context.watch<HouseholdProvider>();
    final choreProvider = context.watch<ChoreProvider>();
    
    final user = authProvider.currentUser!;
    final household = householdProvider.currentHousehold;
    final stats = choreProvider.getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Profile Header
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),

            // Level & XP Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.military_tech,
                      label: '레벨',
                      value: user.level.toString(),
                      color: Colors.amber,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _StatItem(
                      icon: Icons.stars,
                      label: '경험치',
                      value: user.xp.toString(),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Household Info
            if (household != null) ...[
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('가구'),
                  subtitle: Text(household.name),
                  trailing: Chip(
                    label: Text('${householdProvider.members.length}명'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Chore Statistics
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '집안일 통계',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.list_alt,
                          label: '전체',
                          value: stats['total'].toString(),
                          color: Colors.blue,
                        ),
                        _StatItem(
                          icon: Icons.pending_actions,
                          label: '진행중',
                          value: stats['pending'].toString(),
                          color: Colors.orange,
                        ),
                        _StatItem(
                          icon: Icons.check_circle,
                          label: '완료',
                          value: stats['completed'].toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('도움말'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
