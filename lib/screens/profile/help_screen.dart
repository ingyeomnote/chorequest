import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ChoreQuest 사용 가이드',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '집안일을 게임처럼 재미있게! ChoreQuest와 함께 가족 모두가 즐겁게 집안일에 참여하세요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Getting Started
          _HelpSection(
            title: '🚀 시작하기',
            items: [
              _HelpItem(
                question: '가구(Household)란?',
                answer: '가족 구성원들이 함께 사용하는 공간입니다. 가구를 만들고 가족들을 초대하여 함께 집안일을 관리할 수 있습니다.',
              ),
              _HelpItem(
                question: '집안일은 어떻게 추가하나요?',
                answer: '1. 집안일 탭으로 이동\n2. 우측 하단 + 버튼 클릭\n3. 제목, 설명, 난이도, 마감일 입력\n4. 추가하기 버튼 클릭',
              ),
              _HelpItem(
                question: '집안일을 완료하려면?',
                answer: '집안일 목록에서 해당 항목을 탭하고 "완료하기" 버튼을 누르세요. 완료하면 설정된 XP를 받게 됩니다!',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // XP System
          _HelpSection(
            title: '⭐ XP 시스템',
            items: [
              _HelpItem(
                question: 'XP란 무엇인가요?',
                answer: '경험치(Experience Points)입니다. 집안일을 완료하면 난이도에 따라 XP를 받게 되며, 일정량의 XP를 모으면 레벨이 올라갑니다.',
              ),
              _HelpItem(
                question: '난이도별 XP는?',
                answer: '• 쉬움: +10 XP\n• 보통: +25 XP\n• 어려움: +50 XP\n\n난이도가 높을수록 더 많은 XP를 얻을 수 있습니다!',
              ),
              _HelpItem(
                question: '레벨업은 어떻게 하나요?',
                answer: '집안일을 완료하여 XP를 모으면 자동으로 레벨이 올라갑니다. 필요 XP는 레벨이 높아질수록 증가합니다.\n\n공식: 100 × 레벨^1.5',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Leaderboard
          _HelpSection(
            title: '🏆 리더보드',
            items: [
              _HelpItem(
                question: '리더보드는 어떻게 작동하나요?',
                answer: '가구 내 모든 구성원의 XP를 기준으로 순위가 매겨집니다. 집안일을 열심히 하여 1등을 차지해보세요!',
              ),
              _HelpItem(
                question: '순위가 업데이트되는 시점은?',
                answer: '집안일을 완료하여 XP를 획득하면 실시간으로 순위가 업데이트됩니다.',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dashboard
          _HelpSection(
            title: '📊 대시보드',
            items: [
              _HelpItem(
                question: '대시보드에서 무엇을 볼 수 있나요?',
                answer: '• XP 진행률 및 다음 레벨까지의 진행 상황\n• 오늘의 집안일 통계\n• 캘린더로 예정된 집안일 확인\n• 날짜별 집안일 목록',
              ),
              _HelpItem(
                question: '캘린더는 어떻게 사용하나요?',
                answer: '캘린더에서 날짜를 탭하면 해당 날짜의 집안일을 확인할 수 있습니다. 점으로 표시된 날짜는 예정된 집안일이 있다는 의미입니다.',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tips
          _HelpSection(
            title: '💡 유용한 팁',
            items: [
              _HelpItem(
                question: '효과적인 사용 방법',
                answer: '• 매일 아침 대시보드에서 오늘의 할 일을 확인하세요\n• 어려운 집안일부터 완료하여 높은 XP를 획득하세요\n• 가족들과 경쟁하며 동기부여를 받으세요\n• 정기적인 집안일은 반복 패턴으로 설정하세요',
              ),
              _HelpItem(
                question: '동기부여 유지하기',
                answer: '• 리더보드에서 가족과 순위 경쟁\n• 레벨업 목표 설정\n• 완료한 집안일 수 기록하기\n• 작은 성취에도 스스로 보상하기',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Contact Section
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '추가 지원이 필요하신가요?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '문의사항이나 제안사항이 있으시면 언제든지 연락주세요!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Open email client
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이메일: support@chorequest.com'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('문의하기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final List<_HelpItem> items;

  const _HelpSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    item.question,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item.answer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _HelpItem {
  final String question;
  final String answer;

  const _HelpItem({
    required this.question,
    required this.answer,
  });
}
