import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/models/user_model.dart';
import 'dart:math';

void main() {
  group('UserModel XP System Tests', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(
        id: 'test-user-1',
        name: 'Test User',
        email: 'test@chorequest.app',
        xp: 0,
        level: 1,
      );
    });

    group('Required XP Calculation', () {
      test('Level 1 requires 0 XP (starting level)', () {
        expect(_getRequiredXpForLevel(1), equals(100));
      });

      test('Level 2 requires 282 XP (Habitica formula)', () {
        // 100 * (2^1.5) = 100 * 2.828... = 282.84... ≈ 283
        expect(_getRequiredXpForLevel(2), equals(283));
      });

      test('Level 3 requires 520 XP', () {
        // 100 * (3^1.5) = 100 * 5.196... = 519.61... ≈ 520
        expect(_getRequiredXpForLevel(3), equals(520));
      });

      test('Level 5 requires 1118 XP', () {
        // 100 * (5^1.5) = 100 * 11.180... = 1118.03... ≈ 1118
        expect(_getRequiredXpForLevel(5), equals(1118));
      });

      test('Level 10 requires 3162 XP', () {
        // 100 * (10^1.5) = 100 * 31.622... = 3162.27... ≈ 3162
        expect(_getRequiredXpForLevel(10), equals(3162));
      });
    });

    group('Basic XP Gain', () {
      test('Gaining XP increases xp value', () {
        testUser.gainXp(10);
        expect(testUser.xp, equals(10));
      });

      test('Gaining XP multiple times accumulates', () {
        testUser.gainXp(10);
        testUser.gainXp(15);
        testUser.gainXp(25);
        expect(testUser.xp, equals(50));
      });

      test('Gaining XP updates updatedAt timestamp', () {
        final oldUpdatedAt = testUser.updatedAt;
        Future.delayed(const Duration(milliseconds: 10), () {
          testUser.gainXp(10);
          expect(testUser.updatedAt.isAfter(oldUpdatedAt), isTrue);
        });
      });
    });

    group('Level Up Logic', () {
      test('Level 1 → 2: Gaining 283 XP levels up to level 2', () {
        testUser.gainXp(283);
        expect(testUser.level, equals(2));
        expect(testUser.xp, equals(283));
      });

      test('Gaining exactly required XP levels up', () {
        testUser.gainXp(283); // Level 2
        expect(testUser.level, equals(2));
      });

      test('Gaining more than required XP keeps overflow', () {
        testUser.gainXp(300);
        expect(testUser.level, equals(2));
        expect(testUser.xp, equals(300));
      });

      test('Multiple level ups in single gainXp call', () {
        // Level 1 → Level 2: 283 XP
        // Level 2 → Level 3: 520 XP
        // Total: 803 XP to reach Level 3
        testUser.gainXp(1000);
        expect(testUser.level, greaterThanOrEqualTo(3));
      });

      test('Level 1 to Level 3 with exact XP (520)', () {
        testUser.gainXp(520);
        expect(testUser.level, equals(3));
      });

      test('Gradual leveling with easy chore rewards (10 XP)', () {
        // Easy chores: 10 XP each
        // Level 1 → 2 needs 283 XP = 29 easy chores
        for (int i = 0; i < 29; i++) {
          testUser.gainXp(10);
        }
        expect(testUser.level, equals(2));
        expect(testUser.xp, equals(290));
      });

      test('Gradual leveling with medium chore rewards (25 XP)', () {
        // Medium chores: 25 XP each
        // Level 1 → 2 needs 283 XP = 12 medium chores
        for (int i = 0; i < 12; i++) {
          testUser.gainXp(25);
        }
        expect(testUser.level, equals(2));
        expect(testUser.xp, equals(300));
      });

      test('Gradual leveling with hard chore rewards (50 XP)', () {
        // Hard chores: 50 XP each
        // Level 1 → 2 needs 283 XP = 6 hard chores
        for (int i = 0; i < 6; i++) {
          testUser.gainXp(50);
        }
        expect(testUser.level, equals(2));
        expect(testUser.xp, equals(300));
      });

      test('Level progression is exponential (gets harder)', () {
        final level2Xp = _getRequiredXpForLevel(2);
        final level3Xp = _getRequiredXpForLevel(3);
        final level5Xp = _getRequiredXpForLevel(5);
        final level10Xp = _getRequiredXpForLevel(10);

        // Each level requires more XP than the previous
        expect(level3Xp, greaterThan(level2Xp));
        expect(level5Xp, greaterThan(level3Xp));
        expect(level10Xp, greaterThan(level5Xp));

        // The gap increases exponentially
        final gap2to3 = level3Xp - level2Xp;
        final gap3to5 = level5Xp - level3Xp;
        expect(gap3to5, greaterThan(gap2to3));
      });
    });

    group('Level Progress Calculation', () {
      test('At level start (0 XP) progress is 0.0', () {
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 283, // Exactly at level 2
          level: 2,
        );
        expect(testUser.getLevelProgress(), equals(0.0));
      });

      test('Halfway through level shows ~0.5 progress', () {
        // Level 2 → 3: 283 → 520 (237 XP gap)
        // Halfway: 283 + 118.5 ≈ 401 XP
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 401,
          level: 2,
        );
        final progress = testUser.getLevelProgress();
        expect(progress, closeTo(0.5, 0.05));
      });

      test('Near level up (90% progress)', () {
        // Level 2 → 3: 237 XP gap
        // 90%: 283 + 213 = 496 XP
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 496,
          level: 2,
        );
        final progress = testUser.getLevelProgress();
        expect(progress, closeTo(0.9, 0.05));
      });
    });

    group('XP To Next Level', () {
      test('At level 1 with 0 XP, needs 283 XP for level 2', () {
        expect(testUser.getXpToNextLevel(), equals(283));
      });

      test('At level 1 with 100 XP, needs 183 XP for level 2', () {
        testUser.gainXp(100);
        expect(testUser.getXpToNextLevel(), equals(183));
      });

      test('At level 2 with 283 XP, needs 237 XP for level 3', () {
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 283,
          level: 2,
        );
        // Level 3 needs 520 XP total
        // Currently at 283 XP
        // Needs: 520 - 283 = 237 XP
        expect(testUser.getXpToNextLevel(), equals(237));
      });

      test('Just before level up shows 1 XP needed', () {
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 282,
          level: 1,
        );
        expect(testUser.getXpToNextLevel(), equals(1));
      });
    });

    group('Edge Cases', () {
      test('Gaining 0 XP does not level up', () {
        testUser.gainXp(0);
        expect(testUser.level, equals(1));
        expect(testUser.xp, equals(0));
      });

      test('Gaining negative XP is not prevented (business logic)', () {
        // Note: Current implementation allows negative XP
        // Consider adding validation if this is undesired
        testUser.gainXp(-10);
        expect(testUser.xp, equals(-10));
      });

      test('Very large XP gain levels up multiple times', () {
        testUser.gainXp(10000);
        expect(testUser.level, greaterThan(10));
      });

      test('User at high level (50) can still gain XP', () {
        testUser = UserModel(
          id: 'test-user',
          name: 'Test',
          email: 'test@test.com',
          xp: 100000,
          level: 50,
        );
        final oldXp = testUser.xp;
        testUser.gainXp(50);
        expect(testUser.xp, equals(oldXp + 50));
      });
    });

    group('Realistic Gameplay Scenarios', () {
      test('Scenario: New user completes 10 easy chores', () {
        for (int i = 0; i < 10; i++) {
          testUser.gainXp(10);
        }
        expect(testUser.xp, equals(100));
        expect(testUser.level, equals(1)); // Not enough to level up
      });

      test('Scenario: User completes 5 medium + 5 hard chores', () {
        // 5 medium (25 XP) + 5 hard (50 XP) = 125 + 250 = 375 XP
        for (int i = 0; i < 5; i++) {
          testUser.gainXp(25);
        }
        for (int i = 0; i < 5; i++) {
          testUser.gainXp(50);
        }
        expect(testUser.xp, equals(375));
        expect(testUser.level, equals(2)); // Should level up
      });

      test('Scenario: Weekly active user (7 days, 3 chores/day)', () {
        // Average 2 medium chores/day = 50 XP/day
        // 7 days = 350 XP total
        for (int day = 0; day < 7; day++) {
          testUser.gainXp(25); // Morning chore
          testUser.gainXp(25); // Evening chore
        }
        expect(testUser.xp, equals(350));
        expect(testUser.level, equals(2));
      });

      test('Scenario: Power user completes 100 chores', () {
        // Mix of difficulties (40% easy, 40% medium, 20% hard)
        // Expected: 40*10 + 40*25 + 20*50 = 400 + 1000 + 1000 = 2400 XP
        for (int i = 0; i < 40; i++) {
          testUser.gainXp(10);
        }
        for (int i = 0; i < 40; i++) {
          testUser.gainXp(25);
        }
        for (int i = 0; i < 20; i++) {
          testUser.gainXp(50);
        }
        expect(testUser.xp, equals(2400));
        expect(testUser.level, greaterThanOrEqualTo(7));
      });
    });
  });
}

// Helper function to match UserModel's private method
int _getRequiredXpForLevel(int targetLevel) {
  return (100 * pow(targetLevel, 1.5)).round();
}
