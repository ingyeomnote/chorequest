import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Achievement Gallery Screen
///
/// Displays all achievements with:
/// - Progress tracking
/// - Tier system (Bronze → Silver → Gold → Platinum → Legendary)
/// - Secret achievements (hidden until unlocked)
/// - Visual rewards (icons, colors)
///
/// Gamification feature from Phase 2 (P1).
class AchievementGalleryScreen extends StatefulWidget {
  const AchievementGalleryScreen({super.key});

  @override
  State<AchievementGalleryScreen> createState() =>
      _AchievementGalleryScreenState();
}

class _AchievementGalleryScreenState extends State<AchievementGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = ['전체', '집안일', '레벨', '스트릭', '팀워크'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('업적')),
        body: const Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    // Mock data (replace with actual achievement service)
    final totalAchievements = 30;
    final unlockedCount = user.achievements.length;
    final progress = unlockedCount / totalAchievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('업적'),
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.purple[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '달성한 업적',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$unlockedCount / $totalAchievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% 완료',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Category tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ),

          // Achievement list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildAchievementList(_getMockAchievements(category));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<_Achievement> achievements) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(_Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? _getTierColor(achievement.tier)
              : Colors.grey[300]!,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _getTierColor(achievement.tier).withOpacity(0.1)
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              size: 32,
              color: isUnlocked
                  ? _getTierColor(achievement.tier)
                  : Colors.grey[400],
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tier badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTierColor(achievement.tier),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.tier,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (achievement.isSecret) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '비밀',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                // Title
                Text(
                  isUnlocked || !achievement.isSecret
                      ? achievement.title
                      : '???',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black87 : Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  isUnlocked || !achievement.isSecret
                      ? achievement.description
                      : '비밀 업적 - 달성하면 공개됩니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),

                // Progress bar (if not unlocked)
                if (!isUnlocked && achievement.progress != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: achievement.progress! / achievement.target!,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTierColor(achievement.tier),
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${achievement.progress} / ${achievement.target}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Checkmark
          if (isUnlocked)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getTierColor(achievement.tier),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Bronze':
        return const Color(0xFFCD7F32);
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Platinum':
        return const Color(0xFFE5E4E2);
      case 'Legendary':
        return Colors.purple[700]!;
      default:
        return Colors.grey;
    }
  }

  List<_Achievement> _getMockAchievements(String category) {
    // Mock data - replace with actual achievement service
    final all = [
      _Achievement(
        icon: Icons.emoji_events,
        tier: 'Bronze',
        title: '첫 걸음',
        description: '첫 집안일을 완료하세요',
        isUnlocked: true,
      ),
      _Achievement(
        icon: Icons.local_fire_department,
        tier: 'Silver',
        title: '연속 달성 3일',
        description: '3일 연속으로 집안일을 완료하세요',
        isUnlocked: true,
      ),
      _Achievement(
        icon: Icons.star,
        tier: 'Gold',
        title: '레벨 10 달성',
        description: '레벨 10에 도달하세요',
        isUnlocked: false,
        progress: 5,
        target: 10,
      ),
      _Achievement(
        icon: Icons.people,
        tier: 'Gold',
        title: '팀워크의 힘',
        description: '한 달간 가족 모두가 집안일을 완료하세요',
        isUnlocked: false,
        progress: 15,
        target: 30,
      ),
      _Achievement(
        icon: Icons.workspace_premium,
        tier: 'Platinum',
        title: '청소의 달인',
        description: '어려운 집안일 50개를 완료하세요',
        isUnlocked: false,
        progress: 23,
        target: 50,
      ),
      _Achievement(
        icon: Icons.auto_awesome,
        tier: 'Legendary',
        title: '집안일 영웅',
        description: '총 500개의 집안일을 완료하세요',
        isUnlocked: false,
        progress: 147,
        target: 500,
        isSecret: true,
      ),
    ];

    if (category == '전체') {
      return all;
    }

    // Filter by category (simplified)
    return all.take(3).toList();
  }
}

class _Achievement {
  final IconData icon;
  final String tier;
  final String title;
  final String description;
  final bool isUnlocked;
  final int? progress;
  final int? target;
  final bool isSecret;

  _Achievement({
    required this.icon,
    required this.tier,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    this.progress,
    this.target,
    this.isSecret = false,
  });
}
