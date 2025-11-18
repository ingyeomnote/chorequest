import 'package:flutter/material.dart';
import '../services/conflict_detection_service.dart';

/// 중재 제안 다이얼로그
/// 자동 생성된 중재 제안을 표시하고 실행
class MediationSuggestionDialog extends StatelessWidget {
  final List<MediationSuggestion> suggestions;
  final Function(MediationSuggestion)? onAccept;
  final Function(MediationSuggestion)? onDecline;

  const MediationSuggestionDialog({
    super.key,
    required this.suggestions,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '자동 중재 제안',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${suggestions.length}개의 제안',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 제안 목록
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return _buildSuggestionItem(context, suggestion);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    MediationSuggestion suggestion,
  ) {
    final theme = Theme.of(context);
    final icon = _getSuggestionIcon(suggestion.type);
    final color = _getSuggestionColor(suggestion.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제안 타입
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getSuggestionTypeLabel(suggestion.type),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 메시지
          Text(
            suggestion.message,
            style: theme.textTheme.bodyMedium,
          ),

          // 추가 정보
          if (suggestion.choreCountToMove != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '재배정 제안: ${suggestion.choreCountToMove}개 집안일',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 액션 버튼
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  onDecline?.call(suggestion);
                  Navigator.pop(context);
                },
                child: const Text('건너뛰기'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  onAccept?.call(suggestion);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check, size: 18),
                label: Text(_getActionLabel(suggestion.type)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getSuggestionIcon(MediationType type) {
    switch (type) {
      case MediationType.reassignChores:
        return Icons.swap_horiz;
      case MediationType.gentleReminder:
        return Icons.notifications_active;
      case MediationType.conversationPrompt:
        return Icons.chat;
    }
  }

  Color _getSuggestionColor(MediationType type) {
    switch (type) {
      case MediationType.reassignChores:
        return Colors.blue;
      case MediationType.gentleReminder:
        return Colors.orange;
      case MediationType.conversationPrompt:
        return Colors.purple;
    }
  }

  String _getSuggestionTypeLabel(MediationType type) {
    switch (type) {
      case MediationType.reassignChores:
        return '집안일 재배정';
      case MediationType.gentleReminder:
        return '부드러운 알림';
      case MediationType.conversationPrompt:
        return '대화 제안';
    }
  }

  String _getActionLabel(MediationType type) {
    switch (type) {
      case MediationType.reassignChores:
        return '재배정하기';
      case MediationType.gentleReminder:
        return '알림 보내기';
      case MediationType.conversationPrompt:
        return '대화 시작';
    }
  }
}

/// 중재 제안 카드 (요약 버전)
class MediationSuggestionCard extends StatelessWidget {
  final List<MediationSuggestion> suggestions;
  final VoidCallback? onViewAll;

  const MediationSuggestionCard({
    super.key,
    required this.suggestions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_fix_high, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '개선 제안',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${suggestions.length}개의 자동 제안이 있습니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 첫 번째 제안 미리보기
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSuggestionIcon(suggestions.first.type),
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestions.first.message,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            if (suggestions.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                '외 ${suggestions.length - 1}개',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.visibility),
                label: const Text('모든 제안 보기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSuggestionIcon(MediationType type) {
    switch (type) {
      case MediationType.reassignChores:
        return Icons.swap_horiz;
      case MediationType.gentleReminder:
        return Icons.notifications_active;
      case MediationType.conversationPrompt:
        return Icons.chat;
    }
  }
}
