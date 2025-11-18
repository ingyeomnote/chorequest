import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/models/chore_model.dart';

void main() {
  group('ChoreModel Tests', () {
    late ChoreModel testChore;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final yesterday = now.subtract(const Duration(days: 1));

    setUp(() {
      testChore = ChoreModel(
        id: 'test-chore-1',
        title: 'Test Chore',
        description: 'This is a test chore',
        householdId: 'household-1',
        assignedUserId: 'user-1',
        difficulty: ChoreDifficulty.medium,
        status: ChoreStatus.pending,
        dueDate: tomorrow,
      );
    });

    group('XP Reward Calculation', () {
      test('Easy chores reward 10 XP', () {
        final easyChore = ChoreModel(
          id: 'easy-chore',
          title: 'Easy Task',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.easy,
          dueDate: tomorrow,
        );
        expect(easyChore.getXpReward(), equals(10));
      });

      test('Medium chores reward 25 XP', () {
        final mediumChore = ChoreModel(
          id: 'medium-chore',
          title: 'Medium Task',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.medium,
          dueDate: tomorrow,
        );
        expect(mediumChore.getXpReward(), equals(25));
      });

      test('Hard chores reward 50 XP', () {
        final hardChore = ChoreModel(
          id: 'hard-chore',
          title: 'Hard Task',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.hard,
          dueDate: tomorrow,
        );
        expect(hardChore.getXpReward(), equals(50));
      });

      test('XP rewards follow 1:2.5:5 ratio', () {
        final easy = ChoreModel(
          id: 'easy',
          title: 'Easy',
          householdId: 'h1',
          difficulty: ChoreDifficulty.easy,
          dueDate: tomorrow,
        ).getXpReward();

        final medium = ChoreModel(
          id: 'medium',
          title: 'Medium',
          householdId: 'h1',
          difficulty: ChoreDifficulty.medium,
          dueDate: tomorrow,
        ).getXpReward();

        final hard = ChoreModel(
          id: 'hard',
          title: 'Hard',
          householdId: 'h1',
          difficulty: ChoreDifficulty.hard,
          dueDate: tomorrow,
        ).getXpReward();

        expect(medium / easy, equals(2.5));
        expect(hard / easy, equals(5.0));
        expect(hard / medium, equals(2.0));
      });
    });

    group('Chore Completion', () {
      test('Completing chore sets status to completed', () {
        testChore.complete('user-1');
        expect(testChore.status, equals(ChoreStatus.completed));
      });

      test('Completing chore sets completedAt timestamp', () {
        final beforeComplete = DateTime.now();
        testChore.complete('user-1');
        final afterComplete = DateTime.now();

        expect(testChore.completedAt, isNotNull);
        expect(
          testChore.completedAt!.isAfter(beforeComplete) ||
              testChore.completedAt!.isAtSameMomentAs(beforeComplete),
          isTrue,
        );
        expect(
          testChore.completedAt!.isBefore(afterComplete) ||
              testChore.completedAt!.isAtSameMomentAs(afterComplete),
          isTrue,
        );
      });

      test('Completing chore sets completedByUserId', () {
        testChore.complete('user-123');
        expect(testChore.completedByUserId, equals('user-123'));
      });

      test('Completing chore updates updatedAt timestamp', () {
        final oldUpdatedAt = testChore.updatedAt;
        Future.delayed(const Duration(milliseconds: 10), () {
          testChore.complete('user-1');
          expect(testChore.updatedAt.isAfter(oldUpdatedAt), isTrue);
        });
      });

      test('Different users can complete different chores', () {
        final chore1 = ChoreModel(
          id: 'chore-1',
          title: 'Chore 1',
          householdId: 'household-1',
          dueDate: tomorrow,
        );
        final chore2 = ChoreModel(
          id: 'chore-2',
          title: 'Chore 2',
          householdId: 'household-1',
          dueDate: tomorrow,
        );

        chore1.complete('user-1');
        chore2.complete('user-2');

        expect(chore1.completedByUserId, equals('user-1'));
        expect(chore2.completedByUserId, equals('user-2'));
      });

      test('Chore can be completed by someone other than assignedUser', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Assigned Chore',
          householdId: 'household-1',
          assignedUserId: 'user-1',
          dueDate: tomorrow,
        );

        testChore.complete('user-2'); // Different user completes it
        expect(testChore.assignedUserId, equals('user-1'));
        expect(testChore.completedByUserId, equals('user-2'));
      });

      test('Completed chore maintains its difficulty and XP reward', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Hard Chore',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.hard,
          dueDate: tomorrow,
        );

        final xpBefore = testChore.getXpReward();
        testChore.complete('user-1');
        final xpAfter = testChore.getXpReward();

        expect(xpBefore, equals(xpAfter));
        expect(xpAfter, equals(50));
      });
    });

    group('Overdue Detection', () {
      test('Chore due tomorrow is not overdue', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Future Chore',
          householdId: 'household-1',
          dueDate: tomorrow,
          status: ChoreStatus.pending,
        );
        expect(testChore.isOverdue(), isFalse);
      });

      test('Chore due yesterday is overdue', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Past Chore',
          householdId: 'household-1',
          dueDate: yesterday,
          status: ChoreStatus.pending,
        );
        expect(testChore.isOverdue(), isTrue);
      });

      test('Completed chore is never overdue', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Completed Chore',
          householdId: 'household-1',
          dueDate: yesterday,
          status: ChoreStatus.completed,
        );
        expect(testChore.isOverdue(), isFalse);
      });

      test('Chore due today but not completed yet', () {
        final today = DateTime.now();
        final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

        testChore = ChoreModel(
          id: 'chore',
          title: 'Today Chore',
          householdId: 'household-1',
          dueDate: endOfToday,
          status: ChoreStatus.pending,
        );

        // Should not be overdue if due time hasn't passed
        expect(testChore.isOverdue(), isFalse);
      });

      test('Chore due 1 week ago is overdue', () {
        final lastWeek = now.subtract(const Duration(days: 7));
        testChore = ChoreModel(
          id: 'chore',
          title: 'Old Chore',
          householdId: 'household-1',
          dueDate: lastWeek,
          status: ChoreStatus.pending,
        );
        expect(testChore.isOverdue(), isTrue);
      });

      test('Overdue chore becomes not overdue when completed', () {
        testChore = ChoreModel(
          id: 'chore',
          title: 'Late Chore',
          householdId: 'household-1',
          dueDate: yesterday,
          status: ChoreStatus.pending,
        );

        expect(testChore.isOverdue(), isTrue);

        testChore.complete('user-1');
        expect(testChore.isOverdue(), isFalse);
      });
    });

    group('ChoreStatus Enum', () {
      test('Chore starts as pending by default', () {
        final chore = ChoreModel(
          id: 'chore',
          title: 'New Chore',
          householdId: 'household-1',
          dueDate: tomorrow,
        );
        expect(chore.status, equals(ChoreStatus.pending));
      });

      test('ChoreStatus has all expected values', () {
        expect(ChoreStatus.values.length, equals(3));
        expect(ChoreStatus.values.contains(ChoreStatus.pending), isTrue);
        expect(ChoreStatus.values.contains(ChoreStatus.completed), isTrue);
        expect(ChoreStatus.values.contains(ChoreStatus.overdue), isTrue);
      });
    });

    group('ChoreDifficulty Enum', () {
      test('Chore difficulty defaults to medium', () {
        final chore = ChoreModel(
          id: 'chore',
          title: 'Default Chore',
          householdId: 'household-1',
          dueDate: tomorrow,
        );
        expect(chore.difficulty, equals(ChoreDifficulty.medium));
      });

      test('ChoreDifficulty has all expected values', () {
        expect(ChoreDifficulty.values.length, equals(3));
        expect(ChoreDifficulty.values.contains(ChoreDifficulty.easy), isTrue);
        expect(ChoreDifficulty.values.contains(ChoreDifficulty.medium), isTrue);
        expect(ChoreDifficulty.values.contains(ChoreDifficulty.hard), isTrue);
      });
    });

    group('Recurring Chores', () {
      test('Chore is not recurring by default', () {
        expect(testChore.isRecurring, isFalse);
        expect(testChore.recurringPattern, isNull);
      });

      test('Daily recurring chore has correct pattern', () {
        final dailyChore = ChoreModel(
          id: 'daily-chore',
          title: 'Daily Task',
          householdId: 'household-1',
          dueDate: tomorrow,
          isRecurring: true,
          recurringPattern: 'daily',
        );
        expect(dailyChore.isRecurring, isTrue);
        expect(dailyChore.recurringPattern, equals('daily'));
      });

      test('Weekly recurring chore has correct pattern', () {
        final weeklyChore = ChoreModel(
          id: 'weekly-chore',
          title: 'Weekly Task',
          householdId: 'household-1',
          dueDate: tomorrow,
          isRecurring: true,
          recurringPattern: 'weekly',
        );
        expect(weeklyChore.isRecurring, isTrue);
        expect(weeklyChore.recurringPattern, equals('weekly'));
      });

      test('Monthly recurring chore has correct pattern', () {
        final monthlyChore = ChoreModel(
          id: 'monthly-chore',
          title: 'Monthly Task',
          householdId: 'household-1',
          dueDate: tomorrow,
          isRecurring: true,
          recurringPattern: 'monthly',
        );
        expect(monthlyChore.isRecurring, isTrue);
        expect(monthlyChore.recurringPattern, equals('monthly'));
      });
    });

    group('Edge Cases', () {
      test('Chore with empty optional fields', () {
        final minimalChore = ChoreModel(
          id: 'minimal',
          title: 'Minimal Chore',
          householdId: 'household-1',
          dueDate: tomorrow,
        );

        expect(minimalChore.description, isNull);
        expect(minimalChore.assignedUserId, isNull);
        expect(minimalChore.completedAt, isNull);
        expect(minimalChore.completedByUserId, isNull);
      });

      test('Chore can be completed multiple times (updates timestamp)', () {
        testChore.complete('user-1');
        final firstCompletedAt = testChore.completedAt;

        Future.delayed(const Duration(milliseconds: 10), () {
          testChore.complete('user-2');
          expect(testChore.completedAt!.isAfter(firstCompletedAt!), isTrue);
          expect(testChore.completedByUserId, equals('user-2'));
        });
      });

      test('Chore with very long description', () {
        final longDescription = 'A' * 1000;
        final chore = ChoreModel(
          id: 'long-chore',
          title: 'Chore with long description',
          description: longDescription,
          householdId: 'household-1',
          dueDate: tomorrow,
        );
        expect(chore.description, equals(longDescription));
        expect(chore.description!.length, equals(1000));
      });
    });

    group('Realistic Scenarios', () {
      test('Scenario: User completes an easy chore on time', () {
        final chore = ChoreModel(
          id: 'easy-task',
          title: '설거지',
          description: '저녁 식사 후 설거지하기',
          householdId: 'household-1',
          assignedUserId: 'user-1',
          difficulty: ChoreDifficulty.easy,
          dueDate: tomorrow,
        );

        expect(chore.isOverdue(), isFalse);
        chore.complete('user-1');
        expect(chore.status, equals(ChoreStatus.completed));
        expect(chore.getXpReward(), equals(10));
      });

      test('Scenario: User completes a hard chore late', () {
        final chore = ChoreModel(
          id: 'hard-task',
          title: '욕실 청소',
          description: '화장실 전체 청소 및 소독',
          householdId: 'household-1',
          assignedUserId: 'user-2',
          difficulty: ChoreDifficulty.hard,
          dueDate: yesterday,
        );

        expect(chore.isOverdue(), isTrue);
        chore.complete('user-2');
        expect(chore.status, equals(ChoreStatus.completed));
        expect(chore.isOverdue(), isFalse); // Not overdue after completion
        expect(chore.getXpReward(), equals(50)); // Still gets full XP
      });

      test('Scenario: Partner helps complete assigned chore', () {
        final chore = ChoreModel(
          id: 'team-task',
          title: '빨래 널기',
          householdId: 'household-1',
          assignedUserId: 'user-1',
          difficulty: ChoreDifficulty.medium,
          dueDate: tomorrow,
        );

        // Partner (user-2) helps and completes it
        chore.complete('user-2');

        expect(chore.assignedUserId, equals('user-1')); // Still assigned to user-1
        expect(chore.completedByUserId, equals('user-2')); // But completed by user-2
        expect(chore.status, equals(ChoreStatus.completed));
      });

      test('Scenario: Daily recurring chore completion', () {
        final dailyChore = ChoreModel(
          id: 'daily-dishes',
          title: '설거지',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.easy,
          dueDate: now,
          isRecurring: true,
          recurringPattern: 'daily',
        );

        dailyChore.complete('user-1');
        expect(dailyChore.status, equals(ChoreStatus.completed));
        expect(dailyChore.isRecurring, isTrue);
        expect(dailyChore.getXpReward(), equals(10));
      });
    });
  });
}
