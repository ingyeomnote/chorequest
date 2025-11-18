import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/models/user_model.dart';
import 'package:chorequest/models/chore_model.dart';

/// 통합 테스트: 집안일 완료 플로우
///
/// 테스트 시나리오:
/// 1. 사용자가 집안일을 완료한다
/// 2. 난이도에 따라 XP를 획득한다
/// 3. XP 누적으로 레벨업이 발생한다
/// 4. 여러 집안일을 연속 완료하면서 레벨 진행을 확인한다
void main() {
  group('Chore Completion Flow Integration Tests', () {
    late UserModel user;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    setUp(() {
      user = UserModel(
        id: 'user-1',
        name: '김철수',
        email: 'chulsoo@chorequest.app',
        xp: 0,
        level: 1,
      );
    });

    group('Single Chore Completion Flow', () {
      test('Complete easy chore → Gain 10 XP → Stay at level 1', () {
        final chore = ChoreModel(
          id: 'chore-1',
          title: '설거지',
          householdId: 'household-1',
          assignedUserId: user.id,
          difficulty: ChoreDifficulty.easy,
          dueDate: tomorrow,
        );

        // 1. 집안일 완료
        chore.complete(user.id);

        // 2. XP 획득
        final xpReward = chore.getXpReward();
        user.gainXp(xpReward);

        // 3. 검증
        expect(chore.status, equals(ChoreStatus.completed));
        expect(chore.completedByUserId, equals(user.id));
        expect(xpReward, equals(10));
        expect(user.xp, equals(10));
        expect(user.level, equals(1)); // Not enough to level up
      });

      test('Complete medium chore → Gain 25 XP → Stay at level 1', () {
        final chore = ChoreModel(
          id: 'chore-2',
          title: '빨래 개기',
          householdId: 'household-1',
          assignedUserId: user.id,
          difficulty: ChoreDifficulty.medium,
          dueDate: tomorrow,
        );

        chore.complete(user.id);
        user.gainXp(chore.getXpReward());

        expect(user.xp, equals(25));
        expect(user.level, equals(1));
      });

      test('Complete hard chore → Gain 50 XP → Stay at level 1', () {
        final chore = ChoreModel(
          id: 'chore-3',
          title: '욕실 청소',
          householdId: 'household-1',
          assignedUserId: user.id,
          difficulty: ChoreDifficulty.hard,
          dueDate: tomorrow,
        );

        chore.complete(user.id);
        user.gainXp(chore.getXpReward());

        expect(user.xp, equals(50));
        expect(user.level, equals(1));
      });
    });

    group('Multiple Chores → Level Up Flow', () {
      test('Complete 12 easy chores → 120 XP → Stay at level 1', () {
        for (int i = 0; i < 12; i++) {
          final chore = ChoreModel(
            id: 'chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.easy,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }

        expect(user.xp, equals(120));
        expect(user.level, equals(1)); // 283 XP needed for level 2
      });

      test('Complete 29 easy chores → 290 XP → Level up to 2', () {
        for (int i = 0; i < 29; i++) {
          final chore = ChoreModel(
            id: 'chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.easy,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }

        expect(user.xp, equals(290));
        expect(user.level, equals(2)); // 283 XP needed, got 290
      });

      test('Complete 12 medium chores → 300 XP → Level up to 2', () {
        for (int i = 0; i < 12; i++) {
          final chore = ChoreModel(
            id: 'chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.medium,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }

        expect(user.xp, equals(300));
        expect(user.level, equals(2));
      });

      test('Complete 6 hard chores → 300 XP → Level up to 2', () {
        for (int i = 0; i < 6; i++) {
          final chore = ChoreModel(
            id: 'chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.hard,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }

        expect(user.xp, equals(300));
        expect(user.level, equals(2));
      });
    });

    group('Mixed Difficulty Chores Flow', () {
      test('Mix of easy, medium, hard → Realistic progression', () {
        final chores = [
          // Morning routine (2 easy)
          ChoreModel(
            id: 'morning-1',
            title: '아침 설거지',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.easy,
            dueDate: tomorrow,
          ),
          ChoreModel(
            id: 'morning-2',
            title: '침대 정리',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.easy,
            dueDate: tomorrow,
          ),
          // Afternoon tasks (2 medium)
          ChoreModel(
            id: 'afternoon-1',
            title: '빨래 개기',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.medium,
            dueDate: tomorrow,
          ),
          ChoreModel(
            id: 'afternoon-2',
            title: '청소기 돌리기',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.medium,
            dueDate: tomorrow,
          ),
          // Evening deep cleaning (1 hard)
          ChoreModel(
            id: 'evening-1',
            title: '화장실 청소',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.hard,
            dueDate: tomorrow,
          ),
        ];

        int totalXp = 0;
        for (final chore in chores) {
          chore.complete(user.id);
          final xp = chore.getXpReward();
          user.gainXp(xp);
          totalXp += xp;
        }

        // Total: 2*10 + 2*25 + 1*50 = 20 + 50 + 50 = 120 XP
        expect(totalXp, equals(120));
        expect(user.xp, equals(120));
        expect(user.level, equals(1)); // Not enough for level 2
      });

      test('Week of daily chores → Level progression', () {
        // 7 days, 3 chores per day (1 easy, 1 medium, 1 hard)
        for (int day = 0; day < 7; day++) {
          final dayChores = [
            ChoreModel(
              id: 'day-$day-easy',
              title: '설거지',
              householdId: 'household-1',
              difficulty: ChoreDifficulty.easy,
              dueDate: tomorrow,
            ),
            ChoreModel(
              id: 'day-$day-medium',
              title: '빨래',
              householdId: 'household-1',
              difficulty: ChoreDifficulty.medium,
              dueDate: tomorrow,
            ),
            ChoreModel(
              id: 'day-$day-hard',
              title: '청소',
              householdId: 'household-1',
              difficulty: ChoreDifficulty.hard,
              dueDate: tomorrow,
            ),
          ];

          for (final chore in dayChores) {
            chore.complete(user.id);
            user.gainXp(chore.getXpReward());
          }
        }

        // Total: 7 days * (10 + 25 + 50) = 7 * 85 = 595 XP
        expect(user.xp, equals(595));
        expect(user.level, equals(3)); // Level 3 needs 520 XP
      });
    });

    group('Level Up Milestones', () {
      test('Exact XP for level 2 (283 XP)', () {
        user.gainXp(283);
        expect(user.level, equals(2));
        expect(user.xp, equals(283));
      });

      test('Exact XP for level 3 (520 XP)', () {
        user.gainXp(520);
        expect(user.level, equals(3));
        expect(user.xp, equals(520));
      });

      test('Reach level 5 with 1118 XP', () {
        user.gainXp(1118);
        expect(user.level, equals(5));
      });

      test('Reach level 10 with 3162 XP', () {
        user.gainXp(3162);
        expect(user.level, equals(10));
      });

      test('Track level progress during progression', () {
        // Start at level 1, 0 XP
        expect(user.level, equals(1));
        expect(user.xp, equals(0));

        // Gain 141 XP (halfway to level 2)
        user.gainXp(141);
        expect(user.level, equals(1));
        expect(user.getLevelProgress(), closeTo(0.5, 0.05));

        // Gain another 142 XP (total 283, level 2)
        user.gainXp(142);
        expect(user.level, equals(2));
        expect(user.xp, equals(283));
      });
    });

    group('Realistic User Journey', () {
      test('Scenario: New user first week', () {
        // Day 1: Complete 2 easy chores
        for (int i = 0; i < 2; i++) {
          final chore = ChoreModel(
            id: 'day1-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.easy,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }
        expect(user.xp, equals(20));
        expect(user.level, equals(1));

        // Day 2-7: Complete 2 medium chores per day
        for (int day = 2; day <= 7; day++) {
          for (int i = 0; i < 2; i++) {
            final chore = ChoreModel(
              id: 'day$day-$i',
              title: '집안일 $i',
              householdId: 'household-1',
              difficulty: ChoreDifficulty.medium,
              dueDate: tomorrow,
            );
            chore.complete(user.id);
            user.gainXp(chore.getXpReward());
          }
        }

        // Total: 20 + (6 days * 2 chores * 25 XP) = 20 + 300 = 320 XP
        expect(user.xp, equals(320));
        expect(user.level, equals(2)); // Leveled up!
      });

      test('Scenario: Power user month', () {
        // 30 days, average 5 chores per day
        // Mix: 50% easy, 30% medium, 20% hard
        for (int day = 0; day < 30; day++) {
          // 2 easy, 2 medium, 1 hard per day
          for (int i = 0; i < 2; i++) {
            user.gainXp(10); // Easy
          }
          for (int i = 0; i < 2; i++) {
            user.gainXp(25); // Medium
          }
          user.gainXp(50); // Hard
        }

        // Total per day: 2*10 + 2*25 + 1*50 = 20 + 50 + 50 = 120 XP
        // Total month: 30 * 120 = 3600 XP
        expect(user.xp, equals(3600));
        expect(user.level, greaterThanOrEqualTo(10)); // High level!
      });

      test('Scenario: Completing overdue chores still gives XP', () {
        final yesterday = now.subtract(const Duration(days: 1));
        final overdueChore = ChoreModel(
          id: 'overdue-chore',
          title: '밀린 집안일',
          householdId: 'household-1',
          difficulty: ChoreDifficulty.hard,
          dueDate: yesterday,
          status: ChoreStatus.pending,
        );

        // Chore is overdue
        expect(overdueChore.isOverdue(), isTrue);

        // Complete it anyway
        overdueChore.complete(user.id);
        user.gainXp(overdueChore.getXpReward());

        // Should get full XP even if overdue
        expect(overdueChore.status, equals(ChoreStatus.completed));
        expect(user.xp, equals(50));
        expect(user.level, equals(1));
      });

      test('Scenario: Different family members completing chores', () {
        final user2 = UserModel(
          id: 'user-2',
          name: '김영희',
          email: 'younghee@chorequest.app',
          xp: 0,
          level: 1,
        );

        // User 1 completes 10 medium chores
        for (int i = 0; i < 10; i++) {
          final chore = ChoreModel(
            id: 'user1-chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.medium,
            dueDate: tomorrow,
          );
          chore.complete(user.id);
          user.gainXp(chore.getXpReward());
        }

        // User 2 completes 10 medium chores
        for (int i = 0; i < 10; i++) {
          final chore = ChoreModel(
            id: 'user2-chore-$i',
            title: '집안일 $i',
            householdId: 'household-1',
            difficulty: ChoreDifficulty.medium,
            dueDate: tomorrow,
          );
          chore.complete(user2.id);
          user2.gainXp(chore.getXpReward());
        }

        // Both users should have same XP and level
        expect(user.xp, equals(250));
        expect(user2.xp, equals(250));
        expect(user.level, equals(1));
        expect(user2.level, equals(1));
      });
    });

    group('XP Progress Tracking', () {
      test('Track XP to next level during progression', () {
        expect(user.getXpToNextLevel(), equals(283)); // Level 1 → 2

        user.gainXp(100);
        expect(user.getXpToNextLevel(), equals(183));

        user.gainXp(100);
        expect(user.getXpToNextLevel(), equals(83));

        user.gainXp(83);
        expect(user.level, equals(2));
        expect(user.getXpToNextLevel(), equals(237)); // Level 2 → 3
      });

      test('Level progress percentage increases correctly', () {
        expect(user.getLevelProgress(), equals(0.0));

        user.gainXp(141); // ~50% of 283
        expect(user.getLevelProgress(), closeTo(0.5, 0.05));

        user.gainXp(71); // ~75% of 283
        expect(user.getLevelProgress(), closeTo(0.75, 0.05));

        user.gainXp(71); // Level up
        expect(user.level, equals(2));
        expect(user.getLevelProgress(), equals(0.0)); // Reset at new level
      });
    });
  });
}
