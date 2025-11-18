import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Daily Quest Screen
///
/// Shows daily quests that reset every 24 hours.
/// Completing daily quests gives bonus XP and rewards.
class DailyQuestScreen extends StatelessWidget {
  const DailyQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Mock daily quests
    final quests = [
      _DailyQuest(
        title: '집안일 3개 완료',
        description: '오늘 집안일을 3개 완료하세요',
        progress: 2,
        target: 3,
        reward: 50,
        icon: Icons.task_alt,
      ),
      _DailyQuest(
        title: '어려운 집안일 완료',
        description: '어려운 난이도의 집안일을 완료하세요',
        progress: 0,
        target: 1,
        reward: 100,
        icon: Icons.star,
      ),
      _DailyQuest(
        title: '가족 칭찬하기',
        description: '가족에게 칭찬 메시지를 보내세요',
        progress: 1,
        target: 1,
        reward: 25,
        icon: Icons.favorite,
        isCompleted: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 퀘스트'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _buildHeader(quests),
          const SizedBox(height: 24),

          // Quest list
          ...quests.map((quest) => _buildQuestCard(quest)),
        ],
      ),
    );
  }

  Widget _buildHeader(List<_DailyQuest> quests) {
    final completed = quests.where((q) => q.isCompleted).length;
    final total = quests.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            '오늘의 퀘스트',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completed / $total 완료',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(_DailyQuest quest) {
    final isCompleted = quest.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[100] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              quest.icon,
              color: isCompleted ? Colors.green : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                if (!isCompleted)
                  LinearProgressIndicator(
                    value: quest.progress / quest.target,
                    backgroundColor: Colors.grey[300],
                    color: Colors.purple,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 32)
              else
                Text(
                  '${quest.progress}/${quest.target}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 4),
              Text(
                '+${quest.reward} XP',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyQuest {
  final String title;
  final String description;
  final int progress;
  final int target;
  final int reward;
  final IconData icon;
  final bool isCompleted;

  _DailyQuest({
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.reward,
    required this.icon,
    this.isCompleted = false,
  });
}
