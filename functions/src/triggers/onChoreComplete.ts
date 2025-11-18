import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * 집안일 완료 시 트리거되는 Firestore function
 * - XP 부여 및 레벨업 계산
 * - 업적 진행도 업데이트
 * - 스트릭 업데이트
 *
 * Trigger path: households/{householdId}/chores/{choreId}
 */
export const onChoreComplete = functions
  .region("asia-northeast3")
  .firestore
  .document("households/{householdId}/chores/{choreId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const householdId = context.params.householdId;
    const choreId = context.params.choreId;

    // 상태가 pending -> completed로 변경된 경우만 처리
    if (before.status !== "completed" && after.status === "completed") {
      functions.logger.info(`Chore ${choreId} completed`, {
        householdId,
        assignedTo: after.assignedTo,
        difficulty: after.difficulty,
      });

      const db = admin.firestore();
      const userId = after.assignedTo;
      const difficulty = after.difficulty || "medium";

      try {
        // XP 계산
        const xpReward = calculateXpReward(difficulty);

        // 사용자 문서 참조
        const userRef = db.collection("users").doc(userId);

        // 트랜잭션으로 XP 및 레벨 업데이트
        await db.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);

          if (!userDoc.exists) {
            throw new Error(`User ${userId} not found`);
          }

          const userData = userDoc.data()!;
          const currentXp = userData.xp || 0;
          const currentLevel = userData.level || 1;
          const totalChoresCompleted = (userData.totalChoresCompleted || 0) + 1;

          // 새 XP 및 레벨 계산
          let newXp = currentXp + xpReward;
          let newLevel = currentLevel;
          let leveledUp = false;

          // 레벨업 확인
          while (newXp >= calculateXpForLevel(newLevel + 1)) {
            newXp -= calculateXpForLevel(newLevel + 1);
            newLevel++;
            leveledUp = true;
          }

          // 스트릭 업데이트
          const today = new Date();
          today.setHours(0, 0, 0, 0);
          const lastCompletedDate = userData.lastChoreCompletedAt?.toDate();
          let currentStreak = userData.currentStreak || 0;
          let longestStreak = userData.longestStreak || 0;

          if (lastCompletedDate) {
            const lastDate = new Date(lastCompletedDate);
            lastDate.setHours(0, 0, 0, 0);
            const daysDiff = Math.floor(
              (today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
            );

            if (daysDiff === 0) {
              // 오늘 이미 완료한 적 있음 - 스트릭 유지
            } else if (daysDiff === 1) {
              // 어제 완료 - 스트릭 증가
              currentStreak++;
            } else {
              // 스트릭 끊김
              currentStreak = 1;
            }
          } else {
            // 첫 완료
            currentStreak = 1;
          }

          // 최장 스트릭 업데이트
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }

          // 사용자 업데이트
          transaction.update(userRef, {
            xp: newXp,
            level: newLevel,
            totalChoresCompleted: totalChoresCompleted,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastChoreCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          functions.logger.info(`User ${userId} updated`, {
            xpReward,
            newXp,
            newLevel,
            leveledUp,
            currentStreak,
          });

          // 레벨업 시 카카오톡 축하 메시지 전송 (별도 함수로 분리)
          if (leveledUp) {
            functions.logger.info(`User ${userId} leveled up to ${newLevel}`);
            // TODO: Send level-up KakaoTalk message via callable function
          }
        });

        // 업적 진행도 업데이트 (비동기)
        await updateAchievementProgress(userId, householdId, {
          type: "choreCompleted",
          difficulty,
        });
      } catch (error) {
        functions.logger.error(`Failed to process chore completion for ${choreId}`, error);
        throw error;
      }
    }
  });

/**
 * 난이도별 XP 보상 계산
 * TECHNICAL_DOCUMENTATION.md 섹션 2.1 참고
 */
function calculateXpReward(difficulty: string): number {
  switch (difficulty) {
  case "easy":
    return 10;
  case "medium":
    return 25;
  case "hard":
    return 50;
  default:
    return 25;
  }
}

/**
 * 레벨 달성에 필요한 총 XP 계산
 * Habitica 스타일: 100 * (level^1.5)
 */
function calculateXpForLevel(level: number): number {
  return Math.floor(100 * Math.pow(level, 1.5));
}

/**
 * 업적 진행도 업데이트
 */
async function updateAchievementProgress(
  userId: string,
  householdId: string,
  event: {type: string; difficulty?: string}
): Promise<void> {
  const db = admin.firestore();

  try {
    // 사용자의 업적 진행도 조회
    const achievementsSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("achievements")
      .where("completed", "==", false)
      .get();

    const batch = db.batch();

    for (const achievementDoc of achievementsSnapshot.docs) {
      const achievement = achievementDoc.data();

      // 업적 유형에 따라 진행도 증가
      if (event.type === "choreCompleted") {
        if (achievement.type === "choreCount") {
          const newProgress = (achievement.progress || 0) + 1;
          batch.update(achievementDoc.ref, {
            progress: newProgress,
            completed: newProgress >= achievement.target,
            completedAt: newProgress >= achievement.target ?
              admin.firestore.FieldValue.serverTimestamp() :
              null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
    }

    await batch.commit();
    functions.logger.info(`Updated achievements for user ${userId}`);
  } catch (error) {
    functions.logger.error(`Failed to update achievements for user ${userId}`, error);
    // 업적 업데이트 실패는 메인 플로우에 영향 없음
  }
}
