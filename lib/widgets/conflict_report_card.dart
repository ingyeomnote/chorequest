import 'package:flutter/material.dart';
import '../services/conflict_detection_service.dart';
import '../utils/logger.dart';

/// 갈등 보고서 카드 위젯
/// 불균형 경고 및 갈등 위험도를 표시
class ConflictReportCard extends StatelessWidget {
  final ConflictReport report;
  final VoidCallback? onViewDetails;

  const ConflictReportCard({
    super.key,
    required this.report,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor(report.conflictRisk);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  _getRiskIcon(report.conflictRisk),
                  color: riskColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '갈등 위험도',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        _getRiskLabel(report.conflictRisk),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 분석 기간
            Text(
              '최근 ${report.daysAnalyzed}일간 분석',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 불균형 목록
            if (report.imbalances.isNotEmpty) ...[
              Text(
                '⚠️ 발견된 불균형',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...report.imbalances.map((imbalance) => _buildImbalanceItem(
                    context,
                    imbalance,
                  )),
              const SizedBox(height: 16),
            ],

            // 비활동 경고
            if (report.inactivityWarnings.isNotEmpty) ...[
              Text(
                '😴 참여 저조 멤버',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...report.inactivityWarnings.map(
                (warning) => _buildInactivityItem(context, warning),
              ),
              const SizedBox(height: 16),
            ],

            // 제안 사항
            if (report.suggestions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          '제안',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...report.suggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $suggestion',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 상세 보기 버튼
            if (onViewDetails != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.analytics),
                  label: const Text('상세 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: riskColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImbalanceItem(BuildContext context, Imbalance imbalance) {
    final theme = Theme.of(context);
    final isOverworked = imbalance.type == ImbalanceType.overworked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverworked ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverworked ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverworked ? Icons.trending_up : Icons.trending_down,
            color: isOverworked ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imbalance.userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isOverworked ? '과부하' : '부담 저조',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverworked ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isOverworked ? '+' : ''}${imbalance.choreDifference} 건',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${isOverworked ? '+' : ''}${imbalance.minuteDifference} 분',
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

  Widget _buildInactivityItem(
    BuildContext context,
    InactivityWarning warning,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              warning.userName,
              style: theme.textTheme.titleSmall,
            ),
          ),
          Text(
            '${warning.daysSinceLastActivity}일 비활동',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(ConflictRisk risk) {
    switch (risk) {
      case ConflictRisk.none:
        return Colors.green;
      case ConflictRisk.low:
        return Colors.lightGreen;
      case ConflictRisk.medium:
        return Colors.orange;
      case ConflictRisk.high:
        return Colors.red;
    }
  }

  IconData _getRiskIcon(ConflictRisk risk) {
    switch (risk) {
      case ConflictRisk.none:
        return Icons.check_circle;
      case ConflictRisk.low:
        return Icons.info;
      case ConflictRisk.medium:
        return Icons.warning;
      case ConflictRisk.high:
        return Icons.error;
    }
  }

  String _getRiskLabel(ConflictRisk risk) {
    switch (risk) {
      case ConflictRisk.none:
        return '안전';
      case ConflictRisk.low:
        return '낮음';
      case ConflictRisk.medium:
        return '보통';
      case ConflictRisk.high:
        return '높음';
    }
  }
}

/// 갈등 보고서 상세 화면
class ConflictReportDetailScreen extends StatelessWidget {
  final ConflictReport report;

  const ConflictReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('갈등 보고서 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작업 부하 통계
            Text(
              '작업 부하 통계',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...report.workloadStats.map(
              (stats) => _buildWorkloadCard(context, stats, report),
            ),
            const SizedBox(height: 24),

            // 분석 결과
            ConflictReportCard(report: report),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadCard(
    BuildContext context,
    WorkloadStats stats,
    ConflictReport report,
  ) {
    final theme = Theme.of(context);
    final totalChores = report.workloadStats.fold<int>(
      0,
      (sum, s) => sum + s.choreCount,
    );
    final percentage = stats.getWorkloadPercentage(totalChores);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    stats.userName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stats.userName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem('완료', '${stats.choreCount}건'),
                const SizedBox(width: 16),
                _buildStatItem('시간', '${stats.totalMinutes}분'),
                const SizedBox(width: 16),
                _buildStatItem('XP', '${stats.totalXP}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
