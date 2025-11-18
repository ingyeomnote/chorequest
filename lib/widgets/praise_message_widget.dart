import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/conflict_detection_service.dart';

/// 칭찬 메시지 위젯
/// 집안일 완료 시 자동 생성된 칭찬을 보내는 위젯
class PraiseMessageWidget extends StatefulWidget {
  final PraiseMessage praiseMessage;
  final VoidCallback? onSend;
  final VoidCallback? onSkip;

  const PraiseMessageWidget({
    super.key,
    required this.praiseMessage,
    this.onSend,
    this.onSkip,
  });

  @override
  State<PraiseMessageWidget> createState() => _PraiseMessageWidgetState();
}

class _PraiseMessageWidgetState extends State<PraiseMessageWidget> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade100,
              Colors.orange.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    color: Colors.orange,
                    size: 24,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      duration: 1000.ms,
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.1, 1.1),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      duration: 1000.ms,
                      begin: const Offset(1.1, 1.1),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '칭찬하기',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        widget.praiseMessage.recipientName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 칭찬 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.praiseMessage.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.praiseMessage.choreTitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 제안된 답장
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '제안된 답장:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          widget.praiseMessage.suggestedReply,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 액션 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSending ? null : _handleSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text('건너뛰기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _handleSend,
                    icon: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSending ? '전송 중...' : '칭찬 보내기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() async {
    setState(() => _isSending = true);

    // 애니메이션 지연
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onSend?.call();

    if (mounted) {
      _showSuccessAnimation(context);
    }
  }

  void _handleSkip() {
    widget.onSkip?.call();
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PraiseSentAnimation(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }
}

/// 칭찬 전송 성공 애니메이션
class PraiseSentAnimation extends StatelessWidget {
  const PraiseSentAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 80,
            )
                .animate()
                .scale(
                  duration: 500.ms,
                  begin: const Offset(0, 0),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  duration: 200.ms,
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                ),
            const SizedBox(height: 24),
            const Text(
              '칭찬을 전송했어요! 💕',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}

/// 칭찬 히스토리 카드
class PraiseHistoryCard extends StatelessWidget {
  final List<PraiseMessage> recentPraises;
  final VoidCallback? onViewAll;

  const PraiseHistoryCard({
    super.key,
    required this.recentPraises,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentPraises.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.sentiment_satisfied,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '아직 주고받은 칭찬이 없어요',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '집안일을 완료하고 칭찬을 나눠보세요!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '최근 칭찬',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('전체보기'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentPraises.take(3).length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final praise = recentPraises[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    praise.recipientName[0],
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
                title: Text(praise.recipientName),
                subtitle: Text(
                  praise.choreTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
