import 'package:flutter/material.dart';
import '../models/daily_quest_model.dart';
import '../services/daily_quest_service.dart';

// 일일 퀘스트 카드
class DailyQuestCard extends StatelessWidget {
  final List<DailyQuest> quests;
  final VoidCallback? onTap;

  const DailyQuestCard({
    Key? key,
    required this.quests,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questService = DailyQuestService();
    final completedCount = questService.getCompletedQuestCount(quests);
    final totalXp = questService.getTotalRewardXp(quests);
    final earnedXp = questService.getEarnedXp(quests);
    final allCompleted = questService.areAllQuestsCompleted(quests);
    final completionBonus = questService.calculateCompletionBonus(quests);

    // 만료 시간 계산
    final firstQuest = quests.isNotEmpty ? quests.first : null;
    final hoursRemaining = firstQuest?.getHoursRemaining() ?? 0;

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
              colors: allCompleted
                  ? [Colors.green.shade300, Colors.teal.shade400]
                  : [Colors.indigo.shade300, Colors.blue.shade400],
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
                        '🎯',
                        style: TextStyle(fontSize: 28),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 퀘스트',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '$completedCount/${quests.length} 완료',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!allCompleted && hoursRemaining > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hoursRemaining < 3
                            ? Colors.red.shade700
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${hoursRemaining}시간',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),

              // 퀘스트 목록
              ...quests.map((quest) => _buildQuestItem(quest)),

              // 보상 정보
              SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '보상',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$earnedXp / $totalXp XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // 완료 보너스
              if (allCompleted && completionBonus > 0) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '완료 보너스: +$completionBonus XP!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  Widget _buildQuestItem(DailyQuest quest) {
    final progress = quest.getProgressRate();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: quest.isCompleted
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                quest.iconEmoji ?? '✨',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: quest.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      quest.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (quest.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                )
              else
                Text(
                  '${quest.currentProgress}/${quest.targetCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (!quest.isCompleted) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }
}

// 일일 퀘스트 상세 화면
class DailyQuestDetailScreen extends StatelessWidget {
  final List<DailyQuest> quests;

  const DailyQuestDetailScreen({
    Key? key,
    required this.quests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questService = DailyQuestService();
    final completedCount = questService.getCompletedQuestCount(quests);
    final totalXp = questService.getTotalRewardXp(quests);
    final earnedXp = questService.getEarnedXp(quests);
    final allCompleted = questService.areAllQuestsCompleted(quests);
    final completionBonus = questService.calculateCompletionBonus(quests);

    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 퀘스트'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 진행 상황 요약
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 완료율
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          allCompleted ? '🎉' : '📊',
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allCompleted
                                  ? '모든 퀘스트 완료!'
                                  : '진행 중',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$completedCount / ${quests.length} 완료',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // 진행률 바
                    LinearProgressIndicator(
                      value: completedCount / quests.length,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: 20),

                    // XP 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '획득 XP',
                          '$earnedXp',
                          Icons.stars,
                          Colors.amber,
                        ),
                        _buildStatItem(
                          '총 XP',
                          '$totalXp',
                          Icons.star_border,
                          Colors.grey,
                        ),
                        if (completionBonus > 0)
                          _buildStatItem(
                            '보너스',
                            '+$completionBonus',
                            Icons.celebration,
                            Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // 퀘스트 목록
            Text(
              '퀘스트 목록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...quests.map((quest) => _buildDetailQuestCard(context, quest)),

            // 도움말
            if (!allCompleted) ...[
              SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '모든 퀘스트를 완료하면 보너스 XP를 획득할 수 있어요!',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailQuestCard(BuildContext context, DailyQuest quest) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: quest.isCompleted
                        ? Colors.green.shade100
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quest.iconEmoji ?? '✨',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: quest.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (quest.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
              ],
            ),
            SizedBox(height: 12),

            // 진행 상황
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행도',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${quest.currentProgress} / ${quest.targetCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: quest.getProgressRate(),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: 12),

            // 보상 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '보상: ${quest.rewardXp} XP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                _getDifficultyChip(quest.difficulty),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDifficultyChip(QuestDifficulty difficulty) {
    Color color;
    String label;

    switch (difficulty) {
      case QuestDifficulty.easy:
        color = Colors.green;
        label = '쉬움';
        break;
      case QuestDifficulty.normal:
        color = Colors.blue;
        label = '보통';
        break;
      case QuestDifficulty.hard:
        color = Colors.orange;
        label = '어려움';
        break;
      case QuestDifficulty.special:
        color = Colors.purple;
        label = '특별';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
