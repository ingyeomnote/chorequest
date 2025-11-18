import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

/**
 * 가족 구성원에게 칭찬 메시지를 카카오톡으로 전송하는 callable function
 *
 * 호출 예시 (Flutter):
 * ```dart
 * final result = await FirebaseFunctions.instance
 *   .httpsCallable('sendPraiseMessage')
 *   .call({
 *     'targetUserId': 'user123',
 *     'message': '설거지 해줘서 고마워!',
 *   });
 * ```
 */
export const sendPraiseMessage = functions
  .region("asia-northeast3")
  .https
  .onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "사용자 인증이 필요합니다."
      );
    }

    const senderId = context.auth.uid;
    const targetUserId = data.targetUserId as string;
    const message = data.message as string;

    // 입력 검증
    if (!targetUserId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUserId는 필수입니다."
      );
    }

    if (!message || message.trim().length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "message는 필수입니다."
      );
    }

    if (message.length > 500) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "메시지는 500자를 초과할 수 없습니다."
      );
    }

    const db = admin.firestore();

    try {
      // 발신자 정보 조회
      const senderDoc = await db.collection("users").doc(senderId).get();
      if (!senderDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "발신자를 찾을 수 없습니다."
        );
      }
      const senderData = senderDoc.data()!;

      // 수신자 정보 조회
      const targetDoc = await db.collection("users").doc(targetUserId).get();
      if (!targetDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "수신자를 찾을 수 없습니다."
        );
      }
      const targetData = targetDoc.data()!;

      // 같은 가구인지 확인
      if (senderData.householdId !== targetData.householdId) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "같은 가구 구성원에게만 메시지를 보낼 수 있습니다."
        );
      }

      // 카카오톡 알림 설정 확인
      if (!targetData.settings?.kakaoNotificationsEnabled) {
        return {
          success: false,
          message: "수신자가 카카오톡 알림을 비활성화했습니다.",
        };
      }

      if (!targetData.kakaoAccessToken) {
        return {
          success: false,
          message: "수신자의 카카오톡이 연동되지 않았습니다.",
        };
      }

      // 카카오톡 메시지 생성
      const kakaoMessage = `💌 ChoreQuest 칭찬 메시지

${senderData.name}님이 칭찬을 보냈어요!

"${message}"

💚 따뜻한 마음을 나눠주셔서 감사합니다!`;

      // 카카오톡 메시지 전송
      await sendKakaoMessage(targetData.kakaoAccessToken, kakaoMessage);

      // 칭찬 기록 저장 (통계용)
      await db
        .collection("households")
        .doc(senderData.householdId)
        .collection("praises")
        .add({
          senderId,
          senderName: senderData.name,
          targetUserId,
          targetName: targetData.name,
          message,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      functions.logger.info(`Praise message sent from ${senderId} to ${targetUserId}`);

      return {
        success: true,
        message: "칭찬 메시지가 전송되었습니다.",
      };
    } catch (error) {
      functions.logger.error("Failed to send praise message", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "메시지 전송 중 오류가 발생했습니다."
      );
    }
  });

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
    button_title: "ChoreQuest 열기",
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
