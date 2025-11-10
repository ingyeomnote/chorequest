# ChoreQuest - 기술 아키텍처 설계서

## 📄 문서 정보

- **버전**: 2.0
- **작성일**: 2025-11-03
- **대상**: Phase 2 (Firebase 마이그레이션) 이후 아키텍처
- **참고**: [TECHNICAL_DOCUMENTATION.md](./TECHNICAL_DOCUMENTATION.md) (MVP Phase 1 문서)

---

## 1. 아키텍처 개요

### 1.1 전체 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Flutter   │  │   Flutter   │  │   Flutter   │             │
│  │     Web     │  │     iOS     │  │   Android   │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼─────────────────┼─────────────────┼───────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
                 ┌──────────▼──────────┐
                 │   Firebase SDK      │
                 └──────────┬──────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                    Firebase Platform                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Firebase  │  │    Cloud    │  │  Firebase   │             │
│  │     Auth    │  │  Firestore  │  │  Functions  │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Firebase  │  │   Firebase  │  │   Cloud     │             │
│  │   Storage   │  │   Hosting   │  │  Messaging  │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└──────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                  External Integrations                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   KakaoTalk │  │  SmartThings│  │   Payment   │             │
│  │   Message   │  │     API     │  │   Gateway   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└──────────────────────────────────────────────────────────────────┘
```

### 1.2 클라이언트 아키텍처 (Flutter)

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Screens (StatelessWidget / StatefulWidget)             │   │
│  │  - LoginScreen, HomeScreen, DashboardTab, etc.          │   │
│  └───────────────────────┬──────────────────────────────────┘   │
│                          │ uses                                 │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │  Widgets (Reusable Components)                           │   │
│  │  - XpProgressCard, ChoreListTile, LeaderboardPodium     │   │
│  └───────────────────────┬──────────────────────────────────┘   │
└──────────────────────────┼───────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                   State Management Layer                         │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Provider Pattern (ChangeNotifier)                        │  │
│  │  - AuthProvider, HouseholdProvider, ChoreProvider        │  │
│  │  - StatsProvider, SubscriptionProvider                   │  │
│  └───────────────────────┬───────────────────────────────────┘  │
└──────────────────────────┼───────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                     Business Logic Layer                         │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Services                                                 │  │
│  │  - FirebaseAuthService, FirestoreService                 │  │
│  │  - NotificationService, AnalyticsService                 │  │
│  │  - KakaoMessageService, SubscriptionService              │  │
│  └───────────────────────┬───────────────────────────────────┘  │
└──────────────────────────┼───────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                         Data Layer                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Repositories (Data Access Abstraction)                  │  │
│  │  - UserRepository, HouseholdRepository, ChoreRepository  │  │
│  └───────────────────────┬───────────────────────────────────┘  │
│                          │                                       │
│  ┌───────────────────────▼───────────────────────────────────┐  │
│  │  Data Sources                                             │  │
│  │  - FirebaseFirestore (Remote)                            │  │
│  │  - Hive (Local Cache)                                    │  │
│  └───────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. 계층별 상세 설계

### 2.1 Presentation Layer

#### 2.1.1 화면 구조 (Screens)

```dart
// 인증 플로우
lib/screens/auth/
├── splash_screen.dart          // 앱 초기 로딩
├── login_screen.dart           // 로그인
├── register_screen.dart        // 회원가입
└── forgot_password_screen.dart // 비밀번호 재설정 (Phase 2)

// 온보딩 플로우 (Phase 2)
lib/screens/onboarding/
├── welcome_screen.dart         // 환영 화면
├── collaborative_setup_screen.dart // 협업 온보딩
└── household_creation_wizard.dart  // 가구 생성 마법사

// 메인 플로우
lib/screens/home/
├── home_screen.dart            // TabBar 컨테이너
├── dashboard_tab.dart          // 대시보드
├── chores_tab.dart             // 집안일 목록
├── leaderboard_tab.dart        // 리더보드
└── profile_tab.dart            // 프로필

// 집안일 관리
lib/screens/chore/
├── add_chore_screen.dart       // 집안일 추가
├── edit_chore_screen.dart      // 집안일 수정
├── chore_detail_screen.dart    // 집안일 상세
└── recurring_setup_screen.dart // 반복 설정 (Phase 2)

// 가구 관리
lib/screens/household/
├── create_household_screen.dart  // 가구 생성
├── household_settings_screen.dart // 가구 설정
└── invite_members_screen.dart     // 멤버 초대 (Phase 2)

// 설정 및 기타
lib/screens/profile/
├── settings_screen.dart        // 설정
├── help_screen.dart            // 도움말
└── subscription_screen.dart    // 구독 관리 (Phase 2)

// 통계 및 리포트 (Phase 3)
lib/screens/stats/
├── stats_overview_screen.dart  // 통계 대시보드
└── monthly_report_screen.dart  // 월간 리포트
```

#### 2.1.2 재사용 위젯 (Widgets)

```dart
lib/widgets/
├── common/
│   ├── loading_indicator.dart      // 로딩 스피너
│   ├── error_message.dart          // 에러 표시
│   └── empty_state.dart            // 빈 상태 UI
│
├── chore/
│   ├── chore_list_tile.dart        // 집안일 항목
│   ├── chore_card.dart             // 집안일 카드
│   ├── difficulty_badge.dart       // 난이도 뱃지
│   └── chore_status_chip.dart      // 상태 칩
│
├── gamification/
│   ├── xp_progress_card.dart       // XP 진행률
│   ├── level_badge.dart            // 레벨 뱃지
│   ├── achievement_badge.dart      // 업적 뱃지 (Phase 2)
│   └── streak_indicator.dart       // 연속 달성 표시 (Phase 2)
│
└── leaderboard/
    ├── podium_widget.dart          // 순위 포디움
    ├── leaderboard_tile.dart       // 순위 항목
    └── family_goal_card.dart       // 가족 목표 (Phase 2)
```

### 2.2 State Management Layer

#### 2.2.1 Provider 패턴 구조

```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserRepository _userRepository;

  User? _currentUser;
  AuthState _state = AuthState.unauthenticated;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Methods
  Future<void> signInWithEmail(String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final firebaseUser = await _authService.signIn(email, password);
      _currentUser = await _userRepository.getUser(firebaseUser.uid);
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.error;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async { /* Phase 2 */ }
  Future<void> signOut() async { /* ... */ }
}

// lib/providers/household_provider.dart
class HouseholdProvider extends ChangeNotifier {
  final HouseholdRepository _householdRepository;
  final UserRepository _userRepository;

  Household? _currentHousehold;
  List<User> _members = [];

  // Getters
  Household? get currentHousehold => _currentHousehold;
  List<User> get members => _members;

  // Methods
  Future<void> loadHousehold(String householdId) async { /* ... */ }
  Future<void> createHousehold(String name, String description) async { /* ... */ }
  Future<List<LeaderboardEntry>> getLeaderboard() async { /* ... */ }

  // Phase 2: Real-time updates
  Stream<Household?> watchHousehold(String householdId) {
    return _householdRepository.watchHousehold(householdId);
  }
}

// lib/providers/chore_provider.dart
class ChoreProvider extends ChangeNotifier {
  final ChoreRepository _choreRepository;
  final NotificationService _notificationService;

  List<Chore> _chores = [];
  DateTime _selectedDate = DateTime.now();
  ChoreFilter _filter = ChoreFilter.all;

  // Getters
  List<Chore> get chores => _getFilteredChores();
  List<Chore> get todayChores => _getChoresForDate(DateTime.now());

  // Methods
  Future<void> createChore(Chore chore) async { /* ... */ }
  Future<void> completeChore(String choreId, String userId) async { /* ... */ }
  Future<void> updateChore(Chore chore) async { /* ... */ }
  Future<void> deleteChore(String choreId) async { /* ... */ }

  // Phase 2: Real-time updates
  Stream<List<Chore>> watchChores(String householdId) {
    return _choreRepository.watchChores(householdId);
  }
}

// Phase 2: 새 Providers
// lib/providers/stats_provider.dart
class StatsProvider extends ChangeNotifier {
  // 통계 데이터 관리
}

// lib/providers/subscription_provider.dart
class SubscriptionProvider extends ChangeNotifier {
  // 구독 상태 관리
}
```

### 2.3 Business Logic Layer

#### 2.3.1 Services

```dart
// lib/services/firebase_auth_service.dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이메일/비밀번호 인증
  Future<User> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> signUp(String email, String password) async { /* ... */ }

  // Phase 2: 소셜 로그인
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user!;
  }

  Future<void> sendPasswordResetEmail(String email) async { /* ... */ }
  Future<void> signOut() async { /* ... */ }

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// lib/services/firestore_service.dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 기본 CRUD 헬퍼
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  Stream<DocumentSnapshot> watchDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // 트랜잭션 지원
  Future<void> runTransaction(TransactionHandler handler) async {
    await _firestore.runTransaction(handler);
  }
}

// lib/services/notification_service.dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> showChoreReminderNotification(Chore chore) async { /* ... */ }
  Future<void> showXpGainNotification(int xp) async { /* ... */ }

  // Phase 2: Firebase Cloud Messaging
  Future<void> subscribeToHouseholdTopic(String householdId) async {
    await FirebaseMessaging.instance.subscribeToTopic('household_$householdId');
  }
}

// lib/services/analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logChoreCompleted(String choreId, int xpGained) async {
    await _analytics.logEvent(
      name: 'chore_completed',
      parameters: {'chore_id': choreId, 'xp_gained': xpGained},
    );
  }

  Future<void> logLevelUp(int newLevel) async { /* ... */ }
  Future<void> logSubscriptionStarted() async { /* ... */ }
}

// Phase 2: 카카오톡 연동
// lib/services/kakao_message_service.dart
class KakaoMessageService {
  Future<void> sendDailyChoresSummary(String userId, List<Chore> chores) async {
    // Kakao Message API 호출
    // Cloud Functions에서 처리하는 것이 보안상 더 안전
  }
}

// Phase 2: 구독 관리
// lib/services/subscription_service.dart
class SubscriptionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> startPremiumSubscription(String userId, String plan) async {
    await _functions.httpsCallable('createSubscription').call({
      'userId': userId,
      'plan': plan, // 'monthly' or 'yearly'
    });
  }

  Future<bool> isPremiumUser(String userId) async { /* ... */ }
}
```

### 2.4 Data Layer

#### 2.4.1 Repository 패턴

```dart
// lib/repositories/user_repository.dart
class UserRepository {
  final FirestoreService _firestoreService;
  final Box<UserModel> _localCache; // Hive cache

  UserRepository(this._firestoreService, this._localCache);

  // 사용자 조회 (캐시 우선)
  Future<UserModel?> getUser(String userId) async {
    // 1. 로컬 캐시 확인
    final cachedUser = _localCache.get(userId);
    if (cachedUser != null) return cachedUser;

    // 2. Firestore에서 조회
    final data = await _firestoreService.getDocument('users', userId);
    if (data == null) return null;

    // 3. 캐시 업데이트
    final user = UserModel.fromJson(data);
    await _localCache.put(userId, user);
    return user;
  }

  // 사용자 업데이트
  Future<void> updateUser(UserModel user) async {
    // 1. Firestore 업데이트
    await _firestoreService.setDocument('users', user.id, user.toJson());

    // 2. 캐시 업데이트
    await _localCache.put(user.id, user);
  }

  // 실시간 감시
  Stream<UserModel?> watchUser(String userId) {
    return _firestoreService
        .watchDocument('users', userId)
        .map((snapshot) {
          if (!snapshot.exists) return null;
          final user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
          _localCache.put(userId, user); // 캐시 업데이트
          return user;
        });
  }
}

// lib/repositories/household_repository.dart
class HouseholdRepository {
  final FirestoreService _firestoreService;
  final Box<HouseholdModel> _localCache;

  Future<HouseholdModel?> getHousehold(String householdId) async { /* ... */ }
  Future<void> updateHousehold(HouseholdModel household) async { /* ... */ }
  Stream<HouseholdModel?> watchHousehold(String householdId) { /* ... */ }
}

// lib/repositories/chore_repository.dart
class ChoreRepository {
  final FirestoreService _firestoreService;
  final Box<ChoreModel> _localCache;

  Future<List<ChoreModel>> getChores(String householdId) async { /* ... */ }
  Future<void> createChore(ChoreModel chore) async { /* ... */ }
  Future<void> updateChore(ChoreModel chore) async { /* ... */ }
  Future<void> deleteChore(String choreId) async { /* ... */ }

  // 실시간 감시
  Stream<List<ChoreModel>> watchChores(String householdId) {
    return _firestoreService._firestore
        .collection('chores')
        .where('householdId', isEqualTo: householdId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final chore = ChoreModel.fromJson(doc.data());
            _localCache.put(chore.id, chore);
            return chore;
          }).toList();
        });
  }
}
```

---

## 3. Firebase 아키텍처

### 3.1 Firebase Authentication

```dart
// 지원 인증 방식
- EmailAuthProvider       // MVP
- GoogleAuthProvider      // Phase 2
- AppleAuthProvider       // Phase 3 (iOS)
- 익명 로그인              // Phase 2 (체험 모드)

// 보안 규칙
// users collection에는 본인 데이터만 읽기/쓰기 가능
// households는 멤버만 접근 가능
```

### 3.2 Cloud Firestore 구조

자세한 스키마는 [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) 참고

```
firestore/
├── users/
│   └── {userId}/
│       ├── stats/                    // Subcollection
│       │   └── {statId}/
│       └── subscriptions/            // Subcollection
│           └── {subscriptionId}/
│
├── households/
│   └── {householdId}/
│       ├── members/                  // Subcollection
│       │   └── {memberId}/
│       └── invites/                  // Subcollection
│           └── {inviteCode}/
│
├── chores/
│   └── {choreId}/
│
└── templates/                        // 한국형 템플릿
    └── {templateId}/
```

### 3.3 Cloud Functions

```typescript
// functions/src/index.ts

// === 트리거 함수 ===

// 집안일 완료 시 XP 지급
export const onChoreComplete = functions.firestore
  .document('chores/{choreId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 상태가 pending → completed로 변경됨
    if (before.status !== 'completed' && after.status === 'completed') {
      const userId = after.completedBy;
      const xpReward = calculateXpReward(after.difficulty);

      // User XP 업데이트 (트랜잭션)
      await admin.firestore().runTransaction(async (transaction) => {
        const userRef = admin.firestore().collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);

        const currentXp = userDoc.data()!.xp;
        const currentLevel = userDoc.data()!.level;

        const newXp = currentXp + xpReward;
        const newLevel = calculateLevel(newXp);

        transaction.update(userRef, {
          xp: newXp,
          level: newLevel,
          lastActivityAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 레벨업 체크
        if (newLevel > currentLevel) {
          // 레벨업 알림 전송
          await sendLevelUpNotification(userId, newLevel);
        }
      });
    }
  });

// === Scheduled Functions ===

// 매일 오전 8시: 오늘의 할 일 카카오톡 전송
export const sendDailyChoresSummary = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    const households = await admin.firestore().collection('households').get();

    for (const householdDoc of households.docs) {
      const householdId = householdDoc.id;
      const memberIds = householdDoc.data().memberIds;

      // 오늘 마감인 집안일 조회
      const chores = await getTodayChores(householdId);

      // 각 멤버에게 카카오톡 전송
      for (const memberId of memberIds) {
        await sendKakaoMessage(memberId, {
          type: 'daily_chores',
          chores: chores,
        });
      }
    }
  });

// 매일 자정: 마감일 지난 집안일 상태 업데이트
export const updateOverdueChores = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const overdueChores = await admin.firestore()
      .collection('chores')
      .where('status', '==', 'pending')
      .where('dueDate', '<', now)
      .get();

    const batch = admin.firestore().batch();
    overdueChores.docs.forEach((doc) => {
      batch.update(doc.ref, { status: 'overdue' });
    });

    await batch.commit();
  });

// === Callable Functions (클라이언트에서 호출) ===

// 프리미엄 구독 생성
export const createSubscription = functions.https.onCall(
  async (data, context) => {
    const userId = context.auth?.uid;
    if (!userId) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');

    const { plan } = data; // 'monthly' or 'yearly'

    // 결제 처리 (PG사 연동)
    // ...

    // Firestore에 구독 정보 저장
    await admin.firestore().collection('users').doc(userId).update({
      subscription: {
        plan: plan,
        status: 'active',
        startedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: calculateExpirationDate(plan),
      },
    });

    return { success: true };
  }
);

// 가구 초대 코드 생성
export const generateInviteCode = functions.https.onCall(
  async (data, context) => {
    const userId = context.auth?.uid;
    const { householdId } = data;

    // 권한 확인
    const household = await admin.firestore()
      .collection('households')
      .doc(householdId)
      .get();

    if (household.data()!.creatorId !== userId) {
      throw new functions.https.HttpsError('permission-denied', 'Not authorized');
    }

    // 6자리 초대 코드 생성
    const inviteCode = generateRandomCode(6);

    await admin.firestore()
      .collection('households')
      .doc(householdId)
      .collection('invites')
      .doc(inviteCode)
      .set({
        createdBy: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7일 후
        ),
        used: false,
      });

    return { inviteCode };
  }
);
```

### 3.4 Firebase Storage

```dart
// 사용자 아바타 이미지 저장
storage/
├── avatars/
│   └── {userId}/
│       └── profile.jpg
│
└── chores/
    └── {choreId}/
        └── attachments/
            └── {filename}

// 보안 규칙
// 본인 폴더에만 업로드 가능
// 모든 사용자 읽기 가능 (아바타)
```

### 3.5 Firebase Hosting

```yaml
# firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

---

## 4. 핵심 데이터 플로우

### 4.1 집안일 완료 플로우 (Phase 2)

```
[사용자 액션] "완료" 버튼 클릭
    ↓
[ChoreListTile] _completeChore() 호출
    ↓
[ChoreProvider] completeChore(choreId, userId)
    ↓
[ChoreRepository] updateChore(chore.copyWith(status: completed))
    ↓
[FirestoreService] setDocument('chores', choreId, data)
    ↓
[Firestore] Document 업데이트 (트리거 발생)
    ↓
[Cloud Function] onChoreComplete 실행
    ├─→ XP 계산
    ├─→ User XP 업데이트 (트랜잭션)
    └─→ 레벨업 체크 → 알림
    ↓
[Firestore Snapshot Listener] 변경 감지
    ↓
[ChoreProvider.watchChores] 스트림 업데이트
    ↓
[Provider] notifyListeners()
    ↓
[UI 리빌드]
    ├─→ ChoreListTile (완료 상태)
    ├─→ XpProgressCard (XP/레벨 업데이트)
    └─→ LeaderboardTab (순위 갱신)
```

### 4.2 실시간 동기화 플로우

```
[기기 A] 집안일 완료
    ↓
[Firestore] chores/{choreId} 업데이트
    ↓
[Firestore Snapshot] 변경 이벤트 발생
    ↓
[기기 B, C, D] Snapshot Listener 트리거
    ↓
[ChoreProvider] 스트림을 통해 새 데이터 수신
    ↓
[UI 자동 리빌드] 모든 기기에서 즉시 반영
```

### 4.3 카카오톡 알림 플로우 (Phase 2)

```
[Cloud Scheduler] cron: "0 8 * * *" (매일 오전 8시)
    ↓
[Cloud Function] sendDailyChoresSummary 실행
    ↓
[Firestore 조회] 모든 households 및 오늘 마감 chores
    ↓
[For each household member]
    ├─→ User 정보 조회 (카카오톡 ID)
    ├─→ 오늘의 할 일 목록 필터링
    └─→ KakaoTalk Message API 호출
    ↓
[사용자 카카오톡] "오늘의 할 일 3개" 메시지 수신
```

---

## 5. 오프라인 모드 및 캐싱 전략

### 5.1 Hive 로컬 캐시

```dart
// Phase 2에서도 Hive 캐시 유지 (오프라인 지원)

// 읽기 우선순위
1. Hive 캐시 (즉시 반환)
2. Firestore 조회 (네트워크 요청)
3. Hive 캐시 업데이트

// 쓰기 전략
1. Hive 로컬 저장 (즉시 UI 반영)
2. Firestore 업데이트 (백그라운드)
3. 실패 시 재시도 큐 추가
```

### 5.2 Firestore 오프라인 지원

```dart
// Firestore 자체 캐싱 활성화
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// 오프라인 → 온라인 전환 시 자동 동기화
```

### 5.3 네트워크 상태 표시

```dart
// lib/widgets/common/network_indicator.dart
class NetworkIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.none) {
          return Container(
            color: Colors.red,
            child: Text('오프라인 모드'),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
```

---

## 6. 보안 아키텍처

### 6.1 Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 사용자는 본인 데이터만 읽기/쓰기
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 통계 및 구독 정보
      match /stats/{statId} {
        allow read, write: if request.auth.uid == userId;
      }
      match /subscriptions/{subscriptionId} {
        allow read: if request.auth.uid == userId;
        allow write: if false; // Cloud Functions에서만 수정
      }
    }

    // 가구는 멤버만 접근
    match /households/{householdId} {
      allow read: if request.auth.uid in resource.data.memberIds;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.creatorId;

      match /invites/{inviteCode} {
        allow read: if request.auth != null;
        allow create: if request.auth.uid == get(/databases/$(database)/documents/households/$(householdId)).data.creatorId;
      }
    }

    // 집안일은 가구 멤버만 접근
    match /chores/{choreId} {
      allow read, write: if request.auth.uid in
        get(/databases/$(database)/documents/households/$(resource.data.householdId)).data.memberIds;
    }

    // 템플릿은 모두 읽기 가능, 쓰기는 관리자만
    match /templates/{templateId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin SDK에서만
    }
  }
}
```

### 6.2 Firebase Storage Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // 아바타는 본인만 업로드, 모두 읽기 가능
    match /avatars/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // 5MB
                   && request.resource.contentType.matches('image/.*');
    }

    // 집안일 첨부 파일
    match /chores/{choreId}/attachments/{fileName} {
      allow read, write: if request.auth != null;
      // TODO: 가구 멤버 권한 체크
    }
  }
}
```

---

## 7. 성능 최적화

### 7.1 Firestore 쿼리 최적화

```dart
// ❌ 비효율적: 모든 집안일 가져온 후 필터링
final allChores = await _firestore.collection('chores').get();
final myChores = allChores.docs.where((doc) => doc['householdId'] == id);

// ✅ 효율적: 서버 측 필터링
final myChores = await _firestore
    .collection('chores')
    .where('householdId', isEqualTo: id)
    .where('status', isEqualTo: 'pending')
    .orderBy('dueDate')
    .limit(50)
    .get();

// Composite Index 필요 (Firebase Console에서 자동 생성 안내)
```

### 7.2 위젯 최적화

```dart
// ✅ const 생성자 사용
const Text('Hello')

// ✅ RepaintBoundary (애니메이션 격리)
RepaintBoundary(
  child: AnimatedXpBar(),
)

// ✅ AutomaticKeepAliveClientMixin (탭 전환 시 상태 유지)
class ChoresTab extends StatefulWidget {
  @override
  _ChoresTabState createState() => _ChoresTabState();
}

class _ChoresTabState extends State<ChoresTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 반드시 호출
    return ListView(...);
  }
}

// ✅ Selector (부분 리빌드)
Selector<AuthProvider, int>(
  selector: (_, auth) => auth.currentUser?.xp ?? 0,
  builder: (context, xp, child) => Text('XP: $xp'),
)
```

### 7.3 이미지 최적화

```dart
// cached_network_image 사용
CachedNetworkImage(
  imageUrl: user.avatarUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.person),
  cacheManager: CacheManager(
    Config(
      'chorequest_cache',
      stalePeriod: Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  ),
)
```

---

## 8. 모니터링 및 로깅

### 8.1 Firebase Analytics

```dart
// 주요 이벤트 추적
- chore_completed (choreId, xpGained, difficulty)
- level_up (newLevel)
- subscription_started (plan)
- household_created (memberCount)
- invite_sent (inviteCode)
```

### 8.2 Firebase Crashlytics

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Crashlytics 초기화
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
```

### 8.3 Firebase Performance Monitoring

```dart
// 성능 추적
final trace = FirebasePerformance.instance.newTrace('chore_completion');
await trace.start();

// ... 작업 수행 ...

await trace.stop();
```

---

## 9. 배포 아키텍처

### 9.1 환경 구성

```dart
// lib/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment current = Environment.development;

  static String get apiUrl {
    switch (current) {
      case Environment.development:
        return 'http://localhost:5001/chorequest-dev/us-central1';
      case Environment.staging:
        return 'https://us-central1-chorequest-staging.cloudfunctions.net';
      case Environment.production:
        return 'https://us-central1-chorequest-prod.cloudfunctions.net';
    }
  }
}
```

### 9.2 CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.4'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build web
        run: flutter build web --release

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: chorequest-prod
```

---

## 10. 확장성 전략

### 10.1 단계별 확장 계획

```
Phase 1 (현재): Hive 로컬 DB
  - 100명 규모
  - 단일 기기

Phase 2 (진행중): Firebase
  - 10,000명 규모
  - 실시간 동기화
  - 다중 기기

Phase 3 (향후): 최적화
  - 100,000명 규모
  - Firestore 샤딩
  - Cloud Run 서버리스

Phase 4 (미래): 대규모
  - 1,000,000명 규모
  - Cloud SQL (PostgreSQL)
  - Kubernetes
```

### 10.2 데이터베이스 샤딩

```dart
// 가구 ID 기반 샤딩 (Phase 3)
String getShardId(String householdId) {
  final hash = householdId.hashCode;
  final shardIndex = hash % 10; // 10개 샤드
  return 'shard_$shardIndex';
}

// 컬렉션 구조
firestore/
├── chores_shard_0/
├── chores_shard_1/
├── ...
└── chores_shard_9/
```

---

## 11. 부록

### 11.1 기술 스택 요약

| 계층 | 기술 | 버전 | 용도 |
|------|------|------|------|
| Client | Flutter | 3.35.4 | 크로스플랫폼 UI |
| Language | Dart | 3.9.2 | 프로그래밍 언어 |
| State | Provider | 6.1.5+ | 상태 관리 |
| Local DB | Hive | 2.2.3 | 로컬 캐싱 |
| Backend | Firebase | - | BaaS |
| Auth | Firebase Auth | - | 인증 |
| DB | Firestore | - | NoSQL 데이터베이스 |
| Functions | Cloud Functions | Node 18 | 서버리스 로직 |
| Storage | Firebase Storage | - | 파일 저장 |
| Hosting | Firebase Hosting | - | 정적 사이트 호스팅 |
| Messaging | FCM | - | 푸시 알림 |
| Analytics | Firebase Analytics | - | 사용자 분석 |
| Crash | Crashlytics | - | 오류 추적 |

### 11.2 참고 문서

- [PRD.md](./PRD.md) - 제품 요구사항 정의서
- [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) - 데이터베이스 스키마
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 개발 가이드

---

<div align="center">
  <strong>ChoreQuest Architecture</strong> v2.0<br>
  Firebase-Ready Architecture for Phase 2+
</div>
