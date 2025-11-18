import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/streak_service.dart';

// 스트릭 카드 위젯
class StreakCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const StreakCard({
    Key? key,
    required this.user,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streakService = StreakService();
    final isAtRisk = streakService.isStreakAtRisk(user);
    final nextMilestone = streakService.getNextMilestone(user.currentStreak);
    final daysToMilestone = nextMilestone != null
        ? nextMilestone.days - user.currentStreak
        : 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isAtRisk
                  ? [Colors.orange.shade300, Colors.deepOrange.shade400]
                  : [Colors.blue.shade300, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔥',
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '연속 달성',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isAtRisk)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '위험!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),

              // 현재 스트릭
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.currentStreak}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '일 연속',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // 최고 기록
              Text(
                '최고 기록: ${user.longestStreak}일',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),

              // 다음 마일스톤
              if (nextMilestone != null) ...[
                Divider(color: Colors.white.withOpacity(0.3)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      nextMilestone.emoji,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '다음 목표: ${nextMilestone.title}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$daysToMilestone일 남음 (+${nextMilestone.rewardXp} XP)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 진행률 바
                LinearProgressIndicator(
                  value: user.currentStreak / nextMilestone.days,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],

              // 위험 경고 메시지
              if (isAtRisk) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '오늘 집안일을 완료하지 않으면\n스트릭이 끊깁니다!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 스트릭 상세 다이얼로그
class StreakDetailDialog extends StatelessWidget {
  final UserModel user;

  const StreakDetailDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streakService = StreakService();
    final milestones = _getMilestonesList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: 12),
                Text(
                  '연속 달성 기록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 현재 스트릭 & 최고 기록
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    '현재 연속',
                    '${user.currentStreak}일',
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    '최고 기록',
                    '${user.longestStreak}일',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 마일스톤 목록
            Text(
              '마일스톤 달성 현황',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: milestones.length,
                itemBuilder: (context, index) {
                  final milestone = milestones[index];
                  final isAchieved = user.longestStreak >= milestone['days'];
                  final isCurrent = user.currentStreak >= milestone['days'];

                  return ListTile(
                    leading: Text(
                      milestone['emoji'],
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      milestone['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isAchieved ? Colors.black : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      '+${milestone['xp']} XP',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: isAchieved
                        ? Icon(
                            isCurrent
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isCurrent ? Colors.green : Colors.grey,
                          )
                        : Text(
                            '${milestone['days']}일',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMilestonesList() {
    return [
      {'days': 3, 'title': '3일 연속', 'emoji': '🔥', 'xp': 30},
      {'days': 7, 'title': '일주일 연속', 'emoji': '⭐', 'xp': 100},
      {'days': 14, 'title': '2주 연속', 'emoji': '💫', 'xp': 200},
      {'days': 30, 'title': '한 달 연속', 'emoji': '🌟', 'xp': 500},
      {'days': 50, 'title': '50일 연속', 'emoji': '✨', 'xp': 800},
      {'days': 100, 'title': '백일 기념', 'emoji': '💎', 'xp': 1500},
      {'days': 365, 'title': '1년 연속', 'emoji': '🏅', 'xp': 5000},
    ];
  }
}

// 스트릭 마일스톤 축하 다이얼로그
class StreakMilestoneDialog extends StatelessWidget {
  final StreakMilestone milestone;

  const StreakMilestoneDialog({
    Key? key,
    required this.milestone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.amber.shade300, Colors.orange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이모지 애니메이션
            Text(
              milestone.emoji,
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 16),

            // 축하 메시지
            Text(
              '축하합니다!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              milestone.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '연속 달성을 완료했습니다!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),

            // 보상
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+${milestone.rewardXp} XP 획득!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
