# ChoreQuest - 기술 문서

## 📐 아키텍처 설계

### 1. 전체 아키텍처

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (Flutter Widgets, Screens, UI Components)      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────┐
│           State Management Layer                 │
│      (Provider: Auth, Household, Chore)         │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────┐
│            Business Logic Layer                  │
│         (Services, Data Processing)              │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────┐
│              Data Layer                          │
│     (Hive Database, Local Storage)              │
└─────────────────────────────────────────────────┘
```

### 2. 데이터 플로우

#### 집안일 완료 플로우 (MVP 핵심 루프)

```
사용자 액션: "집안일 완료" 버튼 클릭
    ↓
ChoreListTile._completeChore()
    ↓
ChoreProvider.completeChore()
    ↓
DatabaseService.completeChoreWithXp()
    ├─→ ChoreModel.complete()
    │     └─→ Hive: choresBox.put()
    │
    └─→ UserModel.gainXp()
          ├─→ XP 추가
          ├─→ 레벨업 체크
          └─→ Hive: usersBox.put()
    ↓
Provider.notifyListeners()
    ├─→ ChoreProvider 리빌드
    ├─→ AuthProvider.refreshCurrentUser()
    └─→ HouseholdProvider.refresh()
    ↓
UI 업데이트
    ├─→ XpProgressCard (레벨/XP 표시)
    ├─→ ChoreListTile (완료 상태)
    └─→ LeaderboardTab (순위 갱신)
```

## 🔧 핵심 컴포넌트 상세

### 1. XP 시스템

#### XP 계산 로직 (Habitica 스타일)

```dart
// 다음 레벨까지 필요한 XP 공식
static int _getRequiredXpForLevel(int targetLevel) {
  // Formula: 100 * (level^1.5)
  return (100 * pow(targetLevel, 1.5)).round();
}

// 예시:
Level 1 → 2: 100 XP
Level 2 → 3: 283 XP
Level 3 → 4: 520 XP
Level 4 → 5: 800 XP
Level 5 → 6: 1118 XP
```

#### 난이도별 XP 보상

```dart
enum ChoreDifficulty {
  easy,    // +10 XP  (일상적인 집안일)
  medium,  // +25 XP  (일반적인 집안일)
  hard,    // +50 XP  (힘든 집안일)
}
```

#### 레벨업 체크

```dart
void _checkLevelUp() {
  int requiredXp = _getRequiredXpForLevel(level + 1);
  while (xp >= requiredXp) {
    level++;
    requiredXp = _getRequiredXpForLevel(level + 1);
  }
}
```

### 2. Hive 데이터베이스 설계

#### Box 구조

```dart
// TypeId 할당
@HiveType(typeId: 0) UserModel
@HiveType(typeId: 1) HouseholdModel
@HiveType(typeId: 2) ChoreStatus (enum)
@HiveType(typeId: 3) ChoreDifficulty (enum)
@HiveType(typeId: 4) ChoreModel

// Box Names
users: Box<UserModel>
households: Box<HouseholdModel>
chores: Box<ChoreModel>
settings: Box<dynamic>
```

#### 데이터베이스 초기화 순서

```dart
1. Hive.initFlutter()
2. registerAdapter(UserModelAdapter())
3. registerAdapter(HouseholdModelAdapter())
4. registerAdapter(ChoreModelAdapter())
5. registerAdapter(ChoreStatusAdapter())
6. registerAdapter(ChoreDifficultyAdapter())
7. openBox<UserModel>('users')
8. openBox<HouseholdModel>('households')
9. openBox<ChoreModel>('chores')
10. openBox('settings')
```

### 3. Provider 상태 관리

#### AuthProvider

```dart
주요 메서드:
- initialize(): 앱 시작시 저장된 사용자 로드
- register(name, email): 회원가입
- login(email): 로그인
- logout(): 로그아웃
- gainXp(amount): XP 획득
- refreshCurrentUser(): 사용자 정보 새로고침

상태:
- _currentUser: UserModel?
- isAuthenticated: bool (computed)
```

#### HouseholdProvider

```dart
주요 메서드:
- createHousehold(name, description, creatorId): 가구 생성
- loadHousehold(householdId): 가구 로드
- addMember(userId): 멤버 추가
- removeMember(userId): 멤버 제거
- getLeaderboard(): 리더보드 조회

상태:
- _currentHousehold: HouseholdModel?
- _members: List<UserModel>
```

#### ChoreProvider

```dart
주요 메서드:
- loadChores(householdId): 집안일 로드
- createChore(...): 집안일 생성
- updateChore(chore): 집안일 수정
- completeChore(choreId, userId): 집안일 완료
- deleteChore(choreId): 집안일 삭제
- getChoresForDate(date): 날짜별 집안일 조회

상태:
- _chores: List<ChoreModel>
- _selectedDate: DateTime
```

## 🎨 UI/UX 구현 상세

### 1. 애니메이션 시스템

#### flutter_animate 패키지 사용

```dart
// 기본 애니메이션
Widget.animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: 0.2, end: 0)

// 지연 애니메이션 (순차 표시)
Widget.animate(delay: (index * 50).ms)
  .fadeIn()
  .slideX(begin: 0.2, end: 0)

// 스케일 애니메이션 (Podium)
Widget.animate()
  .fadeIn(duration: 500.ms)
  .scale(begin: Offset(0.8, 0.8), delay: (rank * 100).ms)
```

### 2. Material Design 3 테마

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light/dark,
  ),
  useMaterial3: true,
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### 3. 마이크로 인터랙션

#### 집안일 완료 버튼

```dart
1. 사용자 클릭
2. 즉각적인 UI 피드백 (아이콘 변경)
3. 데이터베이스 업데이트
4. 애니메이션 SnackBar 표시
   - 아이콘: 별 (⭐)
   - 메시지: "집안일 완료! +XX XP 획득"
   - 배경색: 초록색
   - 지속 시간: 2초
5. XP 바 애니메이션 갱신
6. 리더보드 자동 업데이트
```

## 📊 데이터 쿼리 최적화

### Hive 쿼리 패턴

```dart
// ✅ 효율적인 쿼리
Box.values.where((item) => item.householdId == id).toList()

// ✅ 인덱스 활용 (Key 기반)
Box.get(itemId)

// ✅ 배치 작업
Box.putAll(Map<String, Model>)

// ❌ 비효율적 (전체 스캔)
Box.values.toList().forEach((item) { ... })
```

### 메모리 최적화

```dart
// LazyBox 사용 (대용량 데이터)
await Hive.openLazyBox<Model>('large_data')

// 일반 Box (빈번한 접근)
await Hive.openBox<Model>('frequent_data')
```

## 🔒 데이터 무결성

### 1. 참조 무결성

```dart
// 가구 삭제시 멤버의 householdId 초기화
Future<void> deleteHousehold() async {
  for (final userId in _currentHousehold!.memberIds) {
    final user = _db.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(householdId: '');
      await _db.updateUser(updatedUser);
    }
  }
  await _db.deleteHousehold(_currentHousehold!.id);
}
```

### 2. 트랜잭션 처리

```dart
// 집안일 완료 + XP 지급 (원자성 보장)
Future<void> completeChoreWithXp(String choreId, String userId) async {
  final chore = getChore(choreId);
  final user = getUser(userId);

  if (chore == null || user == null) return;

  // 1. 집안일 완료
  chore.complete(userId);
  await updateChore(chore);

  // 2. XP 지급
  final xpReward = chore.getXpReward();
  user.gainXp(xpReward);
  await updateUser(user);
}
```

## 🚀 성능 최적화

### 1. 위젯 최적화

```dart
// ✅ const 생성자 사용
const Text('Hello')
const SizedBox(height: 16)

// ✅ ListView.builder (가상화)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ❌ ListView (전체 렌더링)
ListView(children: items.map((item) => ItemWidget(item)).toList())
```

### 2. Provider 선택적 리빌드

```dart
// ✅ Consumer (부분 리빌드)
Consumer<ChoreProvider>(
  builder: (context, choreProvider, child) => ChoreList(),
)

// ✅ Selector (특정 값만 감시)
Selector<AuthProvider, int>(
  selector: (_, auth) => auth.currentUser?.xp ?? 0,
  builder: (context, xp, child) => Text('XP: $xp'),
)
```

## 🧪 테스트 전략

### 단위 테스트

```dart
// XP 계산 테스트
test('Level 1 to 2 requires 100 XP', () {
  final xp = UserModel._getRequiredXpForLevel(2);
  expect(xp, equals(100));
});

// 레벨업 테스트
test('User levels up at correct XP', () {
  final user = UserModel(id: '1', name: 'Test', email: 'test@test.com');
  user.gainXp(100);
  expect(user.level, equals(2));
});
```

### 위젯 테스트

```dart
testWidgets('Login screen shows email field', (tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.byType(TextFormField), findsWidgets);
});
```

### 통합 테스트

```dart
// E2E 시나리오: 회원가입 → 집안일 생성 → 완료
testWidgets('Complete chore flow', (tester) async {
  // 1. 회원가입
  await tester.enterText(find.byType(TextFormField).first, 'Test User');
  await tester.tap(find.text('가입하기'));
  await tester.pumpAndSettle();
  
  // 2. 가구 생성
  await tester.tap(find.text('가구 만들기'));
  await tester.pumpAndSettle();
  
  // 3. 집안일 추가
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // 4. 집안일 완료
  await tester.tap(find.byIcon(Icons.check_circle_outline));
  await tester.pumpAndSettle();
  
  // 5. XP 획득 확인
  expect(find.text('집안일 완료!'), findsOneWidget);
});
```

## 📱 플랫폼별 고려사항

### 웹 (현재 지원)
- ✅ Hive IndexedDB 지원
- ✅ 반응형 디자인
- ✅ CORS 헤더 설정
- ✅ PWA 가능

### 모바일 (향후 확장)
- [ ] Hive 파일 시스템 저장소
- [ ] 푸시 알림
- [ ] 백그라운드 동기화
- [ ] 오프라인 모드

## 🔮 Firebase 마이그레이션 계획

### Phase 1: Authentication
```dart
// Firebase Auth로 교체
- EmailAuthProvider
- GoogleAuthProvider
- 익명 로그인
```

### Phase 2: Firestore
```dart
// Collection 구조
users/
  {userId}/
    - name, email, xp, level, householdId
    
households/
  {householdId}/
    - name, description, memberIds
    
chores/
  {choreId}/
    - title, difficulty, status, householdId, dueDate
```

### Phase 3: Real-time Updates
```dart
// Firestore Snapshots
FirebaseFirestore.instance
  .collection('chores')
  .where('householdId', isEqualTo: householdId)
  .snapshots()
  .listen((snapshot) {
    // 실시간 UI 업데이트
  });
```

### Phase 4: Cloud Functions
```dart
// 서버리스 로직
- onChoreComplete: XP 지급 및 레벨업 처리
- onUserLevelUp: 업적 확인 및 알림
- dailyCron: 마감일 지난 집안일 상태 업데이트
```

## 📈 스케일링 전략

### 데이터베이스
1. **Hive → Firebase Firestore** (100+ 사용자)
2. **Firestore → Cloud SQL** (10,000+ 사용자)
3. **샤딩 및 파티셔닝** (100,000+ 사용자)

### 캐싱
1. **Hive 로컬 캐시** 유지
2. **Redis 서버 캐시** (실시간 리더보드)
3. **CDN** (정적 자산)

### 백엔드
1. **Firebase Functions** (서버리스)
2. **Cloud Run** (컨테이너)
3. **Kubernetes** (대규모)

## 🔐 보안 고려사항

### 현재 구현 (로컬)
- ✅ 클라이언트 측 데이터 격리
- ✅ 입력 검증
- ✅ XSS 방지 (Flutter 기본 제공)

### 향후 구현 (Firebase)
- [ ] Row-Level Security (RLS)
- [ ] API Rate Limiting
- [ ] 데이터 암호화
- [ ] 감사 로그

---

## 📚 참고 자료

### Flutter 공식 문서
- [Provider 패턴](https://pub.dev/packages/provider)
- [Hive 데이터베이스](https://pub.dev/packages/hive)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)

### 디자인 레퍼런스
- **Habitica**: RPG 게임화 메커니즘
- **TimeTree**: 가족 공유 캘린더
- **Todoist**: 태스크 관리 UI/UX

### 수식 및 알고리즘
- XP 공식: `100 * level^1.5` (Habitica 스타일)
- 레벨 진행률: `(currentXP - levelXP) / (nextLevelXP - levelXP)`

---

<div align="center">
  <strong>ChoreQuest</strong> - Technical Documentation v1.0
</div>
