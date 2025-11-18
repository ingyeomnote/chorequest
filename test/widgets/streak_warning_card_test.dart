import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/widgets/streak_warning_card.dart';

void main() {
  group('StreakWarningCard Widget Tests', () {
    testWidgets('Shows warning when user has not completed chore today',
        (WidgetTester tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakWarningCard(
              currentStreak: 5,
              longestStreak: 10,
              lastCompletedAt: yesterday,
            ),
          ),
        ),
      );

      expect(find.text('스트릭이 끊어질 위험!'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('Shows success when user has active streak',
        (WidgetTester tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakWarningCard(
              currentStreak: 7,
              longestStreak: 10,
              lastCompletedAt: today,
            ),
          ),
        ),
      );

      expect(find.textContaining('7일 연속 달성!'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('Does not show when streak is 0 and no warning needed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreakWarningCard(
              currentStreak: 0,
              longestStreak: 0,
              lastCompletedAt: DateTime.now(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });
  });
}
