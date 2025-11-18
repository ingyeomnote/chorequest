# ChoreQuest Cloud Functions

Firebase Cloud Functions for ChoreQuest - Automated tasks, KakaoTalk notifications, and server-side logic.

## 📁 Structure

```
functions/
├── src/
│   ├── index.ts              # Main entry point, exports all functions
│   ├── scheduled/            # Scheduled functions (cron jobs)
│   │   └── dailyKakaoNotification.ts
│   ├── triggers/             # Firestore triggers
│   │   └── onChoreComplete.ts
│   └── callable/             # Callable functions (from client)
│       └── sendPraiseMessage.ts
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

## 🚀 Functions Overview

### 1. Scheduled Functions

#### `dailyKakaoNotification`
- **Trigger**: Every day at 8:00 AM (Asia/Seoul timezone)
- **Purpose**: Send daily chore reminders via KakaoTalk
- **Logic**:
  1. Query all users with `kakaoNotificationsEnabled: true`
  2. For each user, fetch today's pending chores
  3. Send KakaoTalk message with chore list (max 5, with "..." for more)
  4. Log success/failure for monitoring

**KakaoTalk Message Format**:
```
🏠 ChoreQuest - 오늘의 할 일

안녕하세요, {user.name}님!
오늘 완료해야 할 집안일이 {totalChores}개 있어요.

⭐ 설거지
⭐⭐ 빨래 개기
⭐⭐⭐ 욕실 청소
...
외 2개...

💪 오늘도 화이팅!
```

**Firestore Queries**:
```typescript
// Users with notifications enabled
db.collection('users')
  .where('settings.notificationsEnabled', '==', true)
  .where('settings.kakaoNotificationsEnabled', '==', true)

// Today's chores for user
db.collection('households/{householdId}/chores')
  .where('assignedTo', '==', userId)
  .where('status', '==', 'pending')
  .where('dueDate', '>=', today)
  .where('dueDate', '<', tomorrow)
  .orderBy('dueDate', 'asc')
  .limit(10)
```

---

### 2. Firestore Triggers

#### `onChoreComplete`
- **Trigger**: `households/{householdId}/chores/{choreId}` document update
- **Condition**: `status` changes from `pending` to `completed`
- **Purpose**: Award XP, update streaks, check achievements
- **Logic**:
  1. Calculate XP reward based on difficulty (easy: 10, medium: 25, hard: 50)
  2. Update user document with atomic transaction:
     - Add XP and check for level-up
     - Update streak (current + longest)
     - Increment `totalChoresCompleted`
  3. Update achievement progress asynchronously

**XP Calculation**:
```typescript
// Habitica formula: 100 * (level^1.5)
function calculateXpForLevel(level: number): number {
  return Math.floor(100 * Math.pow(level, 1.5));
}
```

**Level-up Logic**:
```typescript
while (newXp >= calculateXpForLevel(newLevel + 1)) {
  newXp -= calculateXpForLevel(newLevel + 1);
  newLevel++;
  leveledUp = true;
}
```

**Streak Calculation**:
```typescript
if (daysSinceLast === 0) {
  // Already completed today, no change
} else if (daysSinceLast === 1) {
  currentStreak++;  // Yesterday → Today: Continue streak
} else {
  currentStreak = 1;  // Streak broken
}
```

---

### 3. Callable Functions

#### `sendPraiseMessage`
- **Trigger**: Called from client (`FirebaseFunctions.httpsCallable`)
- **Purpose**: Send praise message to family member via KakaoTalk
- **Authentication**: Required
- **Input**:
  ```typescript
  {
    targetUserId: string;  // User to send praise to
    message: string;       // Praise message (max 500 chars)
  }
  ```
- **Validation**:
  - User must be authenticated
  - Target user must exist
  - Both users must be in same household
  - Target must have KakaoTalk enabled
- **Output**:
  ```typescript
  {
    success: boolean;
    message: string;
  }
  ```

**Client Usage Example (Flutter)**:
```dart
final callable = FirebaseFunctions.instance
  .httpsCallable('sendPraiseMessage');

try {
  final result = await callable.call({
    'targetUserId': 'user-123',
    'message': '설거지 해줘서 고마워! 😊',
  });

  if (result.data['success']) {
    _showSnackBar('칭찬 메시지가 전송되었습니다!');
  }
} catch (e) {
  _showErrorDialog('메시지 전송 실패: $e');
}
```

---

## 🛠️ Development

### Prerequisites
- Node.js 18+ (required by Firebase Functions)
- Firebase CLI: `npm install -g firebase-tools`
- Firebase project with Blaze plan (for scheduled functions)

### Setup

1. **Install dependencies**:
   ```bash
   cd functions
   npm install
   ```

2. **Set Firebase project**:
   ```bash
   firebase use <project-id>
   ```

3. **Configure environment variables** (optional):
   ```bash
   firebase functions:config:set kakao.api_key="YOUR_KEY"
   ```

### Local Development

1. **Build TypeScript**:
   ```bash
   npm run build
   ```

2. **Start emulators**:
   ```bash
   npm run serve
   # or from project root:
   firebase emulators:start
   ```

3. **Watch mode** (auto-rebuild on changes):
   ```bash
   npm run build:watch
   ```

### Testing Functions Locally

#### Test Scheduled Function (Manual Trigger)
```bash
# In Firebase Emulator UI (http://localhost:4000)
# Go to Functions → dailyKakaoNotification → Run
```

#### Test Firestore Trigger
```bash
# In Firestore Emulator, create a chore and update its status to 'completed'
# Trigger will fire automatically
```

#### Test Callable Function
```dart
// In Flutter app, point to emulator
FirebaseFunctions.instanceFor(region: 'asia-northeast3')
  .useFunctionsEmulator('localhost', 5001);
```

### Linting & Type Checking

```bash
npm run lint          # Check for linting errors
npm run lint:fix      # Auto-fix linting errors
```

---

## 🚢 Deployment

### Deploy All Functions
```bash
firebase deploy --only functions
```

### Deploy Specific Function
```bash
firebase deploy --only functions:dailyKakaoNotification
firebase deploy --only functions:onChoreComplete
firebase deploy --only functions:sendPraiseMessage
```

### Deploy with Target
```bash
firebase deploy --only functions --project production
```

### View Deployment Status
```bash
firebase functions:list
```

---

## 📊 Monitoring & Logs

### View Logs (Real-time)
```bash
firebase functions:log
```

### View Specific Function Logs
```bash
firebase functions:log --only dailyKakaoNotification
```

### View Logs by Severity
```bash
firebase functions:log --severity error
```

### Cloud Console Logs
- **URL**: https://console.cloud.google.com/logs/query
- **Filter by function**:
  ```
  resource.type="cloud_function"
  resource.labels.function_name="dailyKakaoNotification"
  ```

---

## 🔐 Security & Best Practices

### Authentication
- All callable functions verify `context.auth` before processing
- Firestore triggers validate user permissions

### Error Handling
- All functions use try-catch blocks
- Errors logged with `functions.logger.error()`
- Transactional operations for atomic updates

### Performance Optimization
- Use Firestore queries with indexes
- Limit batch operations (max 500 docs)
- Cache frequently accessed data in Hive (client-side)

### Cost Optimization
- Region: `asia-northeast3` (Seoul) for lowest latency
- Scheduled functions: Run once per day (not hourly)
- Batch operations: Process multiple users in parallel
- Firestore reads: Use cache-first strategy in client

---

## 📈 Scaling Considerations

### Free Tier Limits (Spark Plan)
- **Invocations**: 125K/month (2M/month on Blaze)
- **GB-seconds**: 40K/month (400K/month on Blaze)
- **CPU-seconds**: 200K/month (200K GHz-seconds/month on Blaze)

### Production Recommendations
- **Blaze Plan Required** for:
  - Scheduled functions (cron jobs)
  - Outbound network requests (Kakao API)
- **Concurrency**: Default 1000 concurrent executions
- **Timeout**: Default 60s, max 540s (9 min)
- **Memory**: Default 256MB, can increase to 8GB

### Expected Load (MVP Phase)
- **Users**: 1,000 active users
- **Daily notifications**: 1,000 invocations/day (~30K/month)
- **Chore completions**: 5,000 invocations/day (~150K/month)
- **Total**: ~180K invocations/month (well under free tier)

---

## 🐛 Troubleshooting

### Function Not Deploying
```bash
# Check Node version
node --version  # Must be 18+

# Check TypeScript compilation
npm run build

# Check for linting errors
npm run lint
```

### KakaoTalk Messages Not Sending
- Verify `kakaoAccessToken` in user document
- Check Kakao API rate limits (300 requests/day for free tier)
- Verify user has granted "Send messages" permission

### Firestore Trigger Not Firing
- Check index creation: `firebase deploy --only firestore:indexes`
- Verify trigger path matches document structure
- Check Cloud Functions logs for errors

### Scheduled Function Not Running
- Verify Blaze plan is enabled
- Check cron expression syntax: https://crontab.guru/
- Verify timezone: `Asia/Seoul`

---

## 📚 Resources

- **Firebase Functions Docs**: https://firebase.google.com/docs/functions
- **Kakao API Docs**: https://developers.kakao.com/docs/latest/ko/message/rest-api
- **TypeScript Docs**: https://www.typescriptlang.org/docs/
- **Cron Syntax**: https://crontab.guru/

---

## 🔄 Changelog

### v1.0.0 (2025-11-18)
- Initial Cloud Functions setup
- ✅ Daily KakaoTalk notifications (8 AM KST)
- ✅ Chore completion trigger (XP, streak, achievements)
- ✅ Praise message callable function

---

## 📝 TODO (Phase 3+)

- [ ] Weekly summary email/KakaoTalk
- [ ] Overdue chore reminders (3 PM KST)
- [ ] Streak warning (if user hasn't completed chores in 24h)
- [ ] Household leaderboard update trigger
- [ ] Monthly report generation
- [ ] Backup Firestore data daily
- [ ] Analytics event logging

---

**Maintained by**: ChoreQuest Team
**Last Updated**: 2025-11-18
