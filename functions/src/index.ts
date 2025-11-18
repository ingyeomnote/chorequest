import * as admin from "firebase-admin";

// Firebase Admin SDK 초기화
admin.initializeApp();

// Scheduled Functions
export {dailyKakaoNotification} from "./scheduled/dailyKakaoNotification";

// Firestore Triggers
export {onChoreComplete} from "./triggers/onChoreComplete";

// Callable Functions
export {sendPraiseMessage} from "./callable/sendPraiseMessage";
