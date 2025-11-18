import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

// 업적 배지 위젯
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userAchievement;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.achievement,
    this.userAchievement,
    this.isUnlocked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = userAchievement?.getProgressRate(achievement.targetCount) ?? 0.0;

    return Card(
      elevation: isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isUnlocked
                ? _getTierColor(achievement.tier).withOpacity(0.1)
                : Colors.grey.shade100,
          ),
          child: Column(
            children: [
              // 아이콘
              Text(
                achievement.iconEmoji,
                style: TextStyle(
                  fontSize: 40,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              SizedBox(height: 8),

              // 타이틀
              Text(
                achievement.isSecret && !isUnlocked ? '???' : achievement.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

              // 티어 칩
              _buildTierChip(achievement.tier, isUnlocked),

              // 진행률 (미완료 시)
              if (!isUnlocked && userAchievement != null) ...[
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(_getTierColor(achievement.tier)),
                ),
                SizedBox(height: 4),
                Text(
                  '${userAchievement!.currentProgress}/${achievement.targetCount}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierChip(AchievementTier tier, bool isUnlocked) {
    final color = _getTierColor(tier);
    final label = _getTierLabel(tier);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withOpacity(0.2) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isUnlocked ? color : Colors.grey,
        ),
      ),
    );
  }

  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.brown;
      case AchievementTier.silver:
        return Colors.grey.shade600;
      case AchievementTier.gold:
        return Colors.amber;
      case AchievementTier.platinum:
        return Colors.cyan;
      case AchievementTier.legendary:
        return Colors.purple;
    }
  }

  String _getTierLabel(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return '브론즈';
      case AchievementTier.silver:
        return '실버';
      case AchievementTier.gold:
        return '골드';
      case AchievementTier.platinum:
        return '플래티넘';
      case AchievementTier.legendary:
        return '전설';
    }
  }
}

// 업적 상세 다이얼로그
class AchievementDetailDialog extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userAchievement;
  final bool isUnlocked;

  const AchievementDetailDialog({
    Key? key,
    required this.achievement,
    this.userAchievement,
    this.isUnlocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = userAchievement?.getProgressRate(achievement.targetCount) ?? 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Text(
              achievement.iconEmoji,
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 16),

            // 타이틀
            Text(
              achievement.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),

            // 설명
            Text(
              achievement.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            // 보상 정보
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: Colors.amber.shade700),
                  SizedBox(width: 8),
                  Text(
                    '+${achievement.rewardXp} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // 진행률
            if (!isUnlocked) ...[
              SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('진행도', style: TextStyle(fontSize: 14)),
                      Text(
                        '${userAchievement?.currentProgress ?? 0}/${achievement.targetCount}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],

            // 완료 상태
            if (isUnlocked) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '업적 달성!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
