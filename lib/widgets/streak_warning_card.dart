import 'package:flutter/material.dart';

/// Streak Warning Card
///
/// Displays warning when user's streak is about to break.
/// Shows on dashboard if user hasn't completed a chore today.
class StreakWarningCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final VoidCallback? onTap;

  const StreakWarningCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedAt,
    this.onTap,
  });

  bool get _shouldShowWarning {
    if (lastCompletedAt == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );

    // Show warning if last completion was not today
    return today.isAfter(lastDate);
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowWarning && currentStreak == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _shouldShowWarning
                  ? [Colors.orange[400]!, Colors.deepOrange[500]!]
                  : [Colors.green[400]!, Colors.teal[500]!],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _shouldShowWarning ? Icons.warning_amber : Icons.local_fire_department,
                  color: _shouldShowWarning ? Colors.orange : Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shouldShowWarning
                          ? '스트릭이 끊어질 위험!'
                          : '🔥 $currentStreak일 연속 달성!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _shouldShowWarning
                          ? '오늘 집안일을 완료해서\n$currentStreak일 연속 기록을 유지하세요!'
                          : '최고 기록: $longestStreak일\n계속 이어가세요!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (_shouldShowWarning)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
