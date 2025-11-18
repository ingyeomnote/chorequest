import 'package:flutter/material.dart';
import '../services/conflict_detection_service.dart';
import 'package:intl/intl.dart';

/// 감정 노동 카드 위젯
/// 보이지 않는 노동(계획, 조율, 식단)을 가시화
class EmotionalLaborCard extends StatelessWidget {
  final EmotionalLaborReport report;
  final VoidCallback? onLearnMore;

  const EmotionalLaborCard({
    super.key,
    required this.report,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '감정 노동',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          report.userName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 설명
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '집안일 계획, 조율, 식단 고민 등 보이지 않는 노동을 측정합니다',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 활동 통계
              _buildLaborItem(
                context,
                icon: Icons.edit_calendar,
                label: '계획 세우기',
                count: report.planningCount,
                minutes: report.planningCount * 10,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildLaborItem(
                context,
                icon: Icons.swap_horiz,
                label: '일정 조율',
                count: report.coordinationCount,
                minutes: report.coordinationCount * 5,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildLaborItem(
                context,
                icon: Icons.restaurant,
                label: '식단 고민',
                count: report.mealPlanningCount,
                minutes: report.mealPlanningCount * 30,
                color: Colors.green,
              ),
              const SizedBox(height: 20),

              // 총계
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총 소요 시간',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${report.totalMinutes}분',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white54, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '금전적 가치',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(시급 ₩10,000 기준)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          currencyFormat.format(report.monetaryValue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 더 알아보기 버튼
              if (onLearnMore != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLearnMore,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('감정 노동이란?'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple.shade700,
                      side: BorderSide(color: Colors.purple.shade700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaborItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required int minutes,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '$count회',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$minutes분',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '약 ${(minutes / 60).toStringAsFixed(1)}시간',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 감정 노동 설명 다이얼로그
class EmotionalLaborExplanationDialog extends StatelessWidget {
  const EmotionalLaborExplanationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.psychology, color: Colors.purple),
          SizedBox(width: 12),
          Text('감정 노동이란?'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '감정 노동(Emotional Labor)은 집안일을 실제로 수행하는 것 외에, '
              '계획하고 조율하고 관리하는 보이지 않는 노동입니다.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildExampleItem(
              context,
              icon: Icons.edit_calendar,
              title: '계획 세우기',
              examples: [
                '무슨 집안일을 해야 하는지 파악',
                '누가 언제 할지 계획',
                '우선순위 결정',
              ],
            ),
            const SizedBox(height: 12),
            _buildExampleItem(
              context,
              icon: Icons.swap_horiz,
              title: '일정 조율',
              examples: [
                '가족 일정 확인 및 조정',
                '갑작스런 변경 대응',
                '리마인더 보내기',
              ],
            ),
            const SizedBox(height: 12),
            _buildExampleItem(
              context,
              icon: Icons.restaurant,
              title: '식단 고민',
              examples: [
                '냉장고 재료 체크',
                '메뉴 결정',
                '장보기 목록 작성',
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 ChoreQuest는 이런 보이지 않는 노동을 측정하고 가시화하여, '
                '가족 간의 공정한 분담을 돕습니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildExampleItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> examples,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.purple),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(
              '• $example',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
