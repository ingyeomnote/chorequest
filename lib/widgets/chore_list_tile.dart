import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/models/chore_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/chore_provider.dart';
import 'package:flutter_app/providers/household_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ChoreListTile extends StatelessWidget {
  final ChoreModel chore;

  const ChoreListTile({super.key, required this.chore});

  Color _getDifficultyColor(BuildContext context, ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return Colors.green;
      case ChoreDifficulty.medium:
        return Colors.orange;
      case ChoreDifficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyText(ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return '쉬움';
      case ChoreDifficulty.medium:
        return '보통';
      case ChoreDifficulty.hard:
        return '어려움';
    }
  }

  IconData _getDifficultyIcon(ChoreDifficulty difficulty) {
    switch (difficulty) {
      case ChoreDifficulty.easy:
        return Icons.sentiment_satisfied;
      case ChoreDifficulty.medium:
        return Icons.sentiment_neutral;
      case ChoreDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Future<void> _completeChore(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final choreProvider = context.read<ChoreProvider>();
    final householdProvider = context.read<HouseholdProvider>();

    // Calculate XP reward based on difficulty
    final xpReward = chore.difficulty == ChoreDifficulty.easy
        ? 10
        : chore.difficulty == ChoreDifficulty.medium
            ? 20
            : 30;

    await choreProvider.completeChore(
      chore.id,
      authProvider.currentUser!.id,
    );

    authProvider.refreshCurrentUser();
    householdProvider.refresh();

    if (!context.mounted) return;

    // Show animated XP gain
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '집안일 완료! +$xpReward XP 획득',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = chore.status.toString().contains('completed');
    final isOverdue = chore.isOverdue();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getDifficultyColor(context, chore.difficulty).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDifficultyIcon(chore.difficulty),
            color: _getDifficultyColor(context, chore.difficulty),
            size: 28,
          ),
        ),
        title: Text(
          chore.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chore.description != null) ...[
              const SizedBox(height: 4),
              Text(
                chore.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isOverdue ? Colors.red : null,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('M/d HH:mm').format(chore.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(context, chore.difficulty).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getDifficultyText(chore.difficulty)} (+${chore.getXpReward()} XP)',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getDifficultyColor(context, chore.difficulty),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 32),
                onPressed: () => _completeChore(context),
              ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }
}
