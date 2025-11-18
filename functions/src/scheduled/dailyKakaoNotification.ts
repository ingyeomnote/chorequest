import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

/**
 * 매일 오전 8시에 실행되는 scheduled function
 * 모든 사용자에게 오늘의 할 일을 카카오톡으로 전송
 *
 * 실행 시간: 한국 시간 매일 오전 8:00 (Asia/Seoul)
 * Cron expression: 0 8 * * * (Every day at 8:00 AM KST)
 */
export const dailyKakaoNotification = functions
  .region("asia-northeast3") // Seoul region
  .pubsub
  .schedule("0 8 * * *")
  .timeZone("Asia/Seoul")
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    functions.logger.info("Daily KakaoTalk notification started", {
      time: now.toDate().toISOString(),
    });

    try {
      // 모든 활성 사용자 조회
      const usersSnapshot = await db
        .collection("users")
        .where("settings.notificationsEnabled", "==", true)
        .where("settings.kakaoNotificationsEnabled", "==", true)
        .get();

      functions.logger.info(`Found ${usersSnapshot.size} users with notifications enabled`);

      const promises = usersSnapshot.docs.map(async (userDoc) => {
        const userData = userDoc.data();
        const userId = userDoc.id;

        // 카카오 액세스 토큰 확인
        if (!userData.kakaoAccessToken) {
          functions.logger.warn(`User ${userId} has no Kakao access token`);
          return;
        }

        try {
          // 사용자의 가구 ID 조회
          const householdId = userData.householdId;
          if (!householdId) {
            functions.logger.warn(`User ${userId} has no household`);
            return;
          }

          // 오늘 해야 할 집안일 조회
          const choresSnapshot = await db
            .collection("households")
            .doc(householdId)
            .collection("chores")
            .where("assignedTo", "==", userId)
            .where("status", "==", "pending")
            .where("dueDate", ">=", admin.firestore.Timestamp.fromDate(today))
            .where("dueDate", "<", admin.firestore.Timestamp.fromDate(tomorrow))
            .orderBy("dueDate", "asc")
            .limit(10)
            .get();

          if (choresSnapshot.empty) {
            functions.logger.info(`No chores for user ${userId} today`);
            return;
          }

          // 집안일 목록 생성
          const chores = choresSnapshot.docs.map((doc) => {
            const chore = doc.data();
            const difficultyIcon = getDifficultyIcon(chore.difficulty);
            return `${difficultyIcon} ${chore.title}`;
          });

          const choreList = chores.slice(0, 5).join("\n");
          const totalChores = choresSnapshot.size;

          // 카카오톡 메시지 생성
          const message = `🏠 ChoreQuest - 오늘의 할 일

안녕하세요, ${userData.name}님!
오늘 완료해야 할 집안일이 ${totalChores}개 있어요.

${choreList}

${totalChores > 5 ? `\n외 ${totalChores - 5}개...` : ""}

💪 오늘도 화이팅!`;

          // 카카오톡 메시지 전송
          await sendKakaoMessage(userData.kakaoAccessToken, message);

          functions.logger.info(`Sent daily notification to user ${userId}`, {
            choresCount: totalChores,
          });
        } catch (error) {
          functions.logger.error(`Failed to send notification to user ${userId}`, error);
        }
      });

      await Promise.all(promises);

      functions.logger.info("Daily KakaoTalk notification completed");
    } catch (error) {
      functions.logger.error("Daily KakaoTalk notification failed", error);
      throw error;
    }
  });

/**
 * 난이도 아이콘 반환
 */
function getDifficultyIcon(difficulty: string): string {
  switch (difficulty) {
  case "easy":
    return "⭐";
  case "medium":
    return "⭐⭐";
  case "hard":
    return "⭐⭐⭐";
  default:
    return "⭐";
  }
}

/**
 * 카카오톡 메시지 전송
 */
async function sendKakaoMessage(accessToken: string, message: string): Promise<void> {
  const url = "https://kapi.kakao.com/v2/api/talk/memo/default/send";

  const templateObject = {
    object_type: "text",
    text: message,
    link: {
      web_url: "https://chorequest.app",
      mobile_web_url: "https://chorequest.app",
    },
  };

  try {
    const response = await axios.post(
      url,
      new URLSearchParams({
        template_object: JSON.stringify(templateObject),
      }),
      {
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    if (response.status !== 200) {
      throw new Error(`Kakao API error: ${response.status} ${response.statusText}`);
    }
  } catch (error) {
    if (axios.isAxiosError(error)) {
      functions.logger.error("Kakao API error", {
        status: error.response?.status,
        data: error.response?.data,
      });
    }
    throw error;
  }
}
