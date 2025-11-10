# Phase 2 Firebase 마이그레이션 - 진행 상황 및 다음 단계

> **작성일**: 2025-11-04
> **최종 업데이트**: 2025-11-04
> **현재 상태**: Step 1-3 완료 (main.dart, AuthProvider, HouseholdProvider), Step 4 진행 예정

---

## ✅ 완료된 작업

### 1. 프로젝트 문서화
- [x] PRD.md - 제품 요구사항 정의서
- [x] ARCHITECTURE.md - Firebase 기반 아키텍처 설계
- [x] DATABASE_SCHEMA.md - Firestore 스키마 설계
- [x] DOMAIN_STRATEGY.md - 도메인 및 브랜딩 전략
- [x] DEVELOPMENT_GUIDE.md - 개발자 가이드
- [x] CLAUDE.md - AI 어시스턴트 컨텍스트
- [x] README.md - 프로젝트 개요 업데이트

### 2. Firebase 인프라 구축

#### 패키지 의존성 (pubspec.yaml)
```yaml
dependencies:
  firebase_core: ^3.10.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  firebase_storage: ^12.5.0
  firebase_analytics: ^11.5.0
  google_sign_in: ^6.2.2
  connectivity_plus: ^6.1.2
```

#### 환경 설정
- [x] `lib/config/environment.dart` - 환경별 설정 (dev/staging/prod)
- [x] `lib/config/firebase_config.dart` - Firebase 초기화 및 Emulator 설정

#### 로깅 시스템
- [x] `lib/utils/logger.dart` - 개발용 로거 (debugPrint 기반)

#### Firebase Emulator 설정
- [x] `firebase.json` - 프로젝트 설정
- [x] `firestore.rules` - Firestore 보안 규칙
- [x] `firestore.indexes.json` - 복합 인덱스 정의
- [x] `storage.rules` - Storage 보안 규칙

**Emulator 포트**:
- Firestore: 8080
- Auth: 9099
- Storage: 9199
- UI: 4000

### 3. 핵심 서비스 구현

#### FirebaseAuthService (`lib/services/firebase_auth_service.dart`)
- [x] 이메일/비밀번호 로그인/가입
- [x] Google Sign-In 연동
- [x] 비밀번호 재설정
- [x] 한국어 에러 메시지 처리
- [x] 계정 삭제 및 프로필 업데이트

**주요 메서드**:
```dart
Future<User> signInWithEmail(String email, String password)
Future<User> signUpWithEmail(String email, String password)
Future<User> signInWithGoogle()
Future<void> sendPasswordResetEmail(String email)
Future<void> updateDisplayName(String displayName)
Future<void> signOut()
Future<void> deleteAccount()
```

#### FirestoreService (`lib/services/firestore_service.dart`)
- [x] 기본 CRUD 작업 (setDocument, updateDocument, getDocument, deleteDocument)
- [x] 실시간 리스너 (watchDocument, watchCollection)
- [x] 트랜잭션 및 배치 작업
- [x] 쿼리 빌더 헬퍼 메서드

**주요 메서드**:
```dart
Future<void> setDocument(String collection, String docId, Map<String, dynamic> data)
Future<Map<String, dynamic>?> getDocument(String collection, String docId)
Future<List<QueryDocumentSnapshot>> getCollectionDocs(String collection, {queryBuilder})
Stream<DocumentSnapshot> watchDocument(String collection, String docId)
Stream<QuerySnapshot> watchCollection(String collection, {queryBuilder})
Future<T> runTransaction<T>(Future<T> Function(Transaction) updateFunction)
```

### 4. 데이터 모델 Firestore 호환 업데이트

#### UserModel (`lib/models/user_model.dart`)
- [x] Phase 2 필드 추가
  - `achievements` (List<String>)
  - `currentStreak` (int)
  - `longestStreak` (int)
  - `lastLoginAt` (DateTime?)
  - `lastActivityAt` (DateTime?)
- [x] Firestore 직렬화 메서드
  - `toFirestore()` - Timestamp 변환
  - `fromFirestore(DocumentSnapshot)` - DocumentSnapshot에서 생성
  - `fromFirestoreMap(String id, Map)` - Map에서 직접 생성
- [x] Hive 호환성 유지 (toMap/fromMap)

#### HouseholdModel (`lib/models/household_model.dart`)
- [x] Phase 2 필드 추가
  - `avatarUrl` (String?)
  - `memberCount` (int) - 자동 계산
  - `adminIds` (List<String>)
- [x] Firestore 직렬화 메서드 (toFirestore, fromFirestore, fromFirestoreMap)
- [x] Hive 호환성 유지

#### ChoreModel (`lib/models/chore_model.dart`)
- [x] Firestore 직렬화 메서드 (toFirestore, fromFirestore, fromFirestoreMap)
- [x] Enum 직렬화 개선
  - Hive: `toString()` 사용 (기존 호환성)
  - Firestore: `.name` 사용 (더 간결)
- [x] Hive 호환성 유지

#### Hive TypeAdapter 재생성
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Repository 패턴 구현

#### UserRepository (`lib/repositories/user_repository.dart`)
**Cache-first 읽기 전략**: Hive 캐시 우선 → Firestore 조회 → 캐시 업데이트

**CRUD 작업**:
- `createUser(UserModel user)` - 사용자 생성
- `getUser(String userId)` - 단일 사용자 조회 (캐시 우선)
- `getUsersByHousehold(String householdId)` - 가구별 사용자 목록
- `updateUser(UserModel user)` - 사용자 정보 업데이트
- `deleteUser(String userId)` - 사용자 삭제

**특수 작업**:
- `incrementXp(String userId, int amount)` - XP 증가 (트랜잭션)
- `getLeaderboard(String householdId, {int limit})` - 리더보드 조회

**실시간 동기화**:
- `watchUser(String userId)` - 단일 사용자 실시간 감시
- `watchUsersByHousehold(String householdId)` - 가구 사용자 목록 실시간
- `watchLeaderboard(String householdId, {int limit})` - 리더보드 실시간

**캐시 관리**:
- `getFromCache(String userId)` - 캐시에서만 조회
- `clearCache()` - 전체 캐시 삭제
- `refreshUser(String userId)` - Firestore에서 강제 새로고침

#### HouseholdRepository (`lib/repositories/household_repository.dart`)
**CRUD 작업**:
- `createHousehold(HouseholdModel household)`
- `getHousehold(String householdId)` - 캐시 우선
- `getHouseholdsForUser(String userId)` - 사용자가 속한 가구 목록
- `updateHousehold(HouseholdModel household)`
- `deleteHousehold(String householdId)`

**멤버 관리** (트랜잭션):
- `addMember(String householdId, String userId)` - 멤버 추가
- `removeMember(String householdId, String userId)` - 멤버 제거

**실시간 동기화**:
- `watchHousehold(String householdId)`
- `watchHouseholdsForUser(String userId)`

**캐시 관리**:
- `getFromCache(String householdId)`
- `clearCache()`
- `refreshHousehold(String householdId)`

#### ChoreRepository (`lib/repositories/chore_repository.dart`)
**CRUD 작업**:
- `createChore(ChoreModel chore)`
- `getChore(String choreId)` - 캐시 우선
- `getChoresByHousehold(String householdId)` - 가구별 전체 집안일
- `getPendingChores(String householdId)` - 대기 중인 집안일만
- `getChoresByUser(String householdId, String userId)` - 사용자 할당 집안일
- `getChoresDueToday(String householdId)` - 오늘 마감 집안일
- `updateChore(ChoreModel chore)`
- `deleteChore(String choreId)`

**특수 작업** (트랜잭션):
- `completeChore(String choreId, String userId)` - 집안일 완료
- `assignChore(String choreId, String userId)` - 집안일 할당

**실시간 동기화**:
- `watchChore(String choreId)`
- `watchChoresByHousehold(String householdId)`
- `watchPendingChores(String householdId)`
- `watchChoresByUser(String householdId, String userId)`

**캐시 관리**:
- `getFromCache(String choreId)`
- `clearCache()`
- `refreshChore(String choreId)`

### 6. Provider 통합 완료 (Step 1-3)

#### Step 1: main.dart 업데이트 ✅
- [x] Firebase 초기화 (`FirebaseConfig.initialize()`)
- [x] Hive 초기화 및 TypeAdapter 등록
- [x] Hive Box 열기 (users, households, chores)
- [x] Services 인스턴스 생성 (FirestoreService, FirebaseAuthService)
- [x] Repositories 인스턴스 생성 (UserRepository, HouseholdRepository, ChoreRepository)
- [x] Provider에 Repository 및 Service 제공

**주요 변경사항**:
- [lib/main.dart](lib/main.dart): 81줄 - Firebase + Hive 통합 초기화, Repository 생성 및 Provider 등록
- [lib/utils/logger.dart:27](lib/utils/logger.dart#L27): warning 메서드에 선택적 error 파라미터 추가

#### Step 2: AuthProvider 업데이트 ✅
- [x] FirebaseAuthService와 UserRepository 주입
- [x] Auth state changes 리스너 추가
- [x] 로그인/회원가입 Firebase 통합
  - `signUpWithEmail()`: Firebase Auth + Firestore 사용자 생성
  - `signInWithEmail()`: Firebase Auth 로그인
  - `signInWithGoogle()`: Google 로그인
- [x] 로그아웃 시 캐시 자동 정리
- [x] XP 시스템 트랜잭션 사용 (`incrementXp()`)
- [x] 로딩 상태 관리 (`isLoading`)

**주요 변경사항**:
- [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart): 357줄 - 완전히 새로운 구현
  - Firebase Auth 실시간 동기화
  - UserRepository의 트랜잭션 사용
  - 로깅 시스템 통합
  - 에러 처리 강화

**주요 기능**:
```dart
// Auth state listener가 자동으로 로그인/로그아웃 처리
_authService.authStateChanges.listen(_onAuthStateChanged);

// XP 증가 (원자적 트랜잭션)
await _userRepository.incrementXp(userId, amount);

// 캐시 정리
await _userRepository.clearCache();
```

#### Step 3: HouseholdProvider 업데이트 ✅
- [x] HouseholdRepository와 UserRepository 주입
- [x] 실시간 동기화 스트림 구독
  - `watchHousehold()`: 가구 정보 실시간 감시
  - `watchUsersByHousehold()`: 멤버 목록 실시간 감시
- [x] 가구 생성/업데이트 Repository 사용
- [x] 멤버 추가/제거 트랜잭션 메서드 사용
- [x] 리더보드 실시간 스트림 제공
- [x] 로딩 상태 관리

**주요 변경사항**:
- [lib/providers/household_provider.dart](lib/providers/household_provider.dart): 327줄 - 완전히 새로운 구현
  - Firestore 실시간 리스너 사용
  - StreamSubscription 관리
  - 자동 캐시 업데이트
  - 트랜잭션 기반 멤버 관리

**주요 기능**:
```dart
// 실시간 동기화
_householdSubscription = _householdRepository
    .watchHousehold(householdId)
    .listen((household) {
      _currentHousehold = household;
      notifyListeners();
    });

// 멤버 추가 (트랜잭션)
await _householdRepository.addMember(householdId, userId);

// 리더보드 실시간 스트림
Stream<List<UserModel>> watchLeaderboard({int limit = 10})
```

---

## 📋 다음 작업 단계

### ✅ 완료된 단계
- **Step 1**: main.dart 업데이트 및 Repository 초기화 ✅
- **Step 2**: AuthProvider 업데이트 ✅
- **Step 3**: HouseholdProvider 업데이트 ✅

### 🚧 진행 중인 단계

### Step 4: ChoreProvider 업데이트 (다음 작업)

**목표**: ChoreRepository + UserRepository 통합, 실시간 스트림 연결

**파일**: `lib/providers/chore_provider.dart`

**작업 내용**:
1. ChoreRepository와 UserRepository 주입받도록 수정
2. 실시간 동기화 스트림 구독
3. 집안일 완료 시 Repository의 트랜잭션 메서드 사용
4. XP 증가는 UserRepository의 incrementXp 사용

**예상 구현**:
```dart
class ChoreProvider extends ChangeNotifier {
  final ChoreRepository _choreRepository;
  final UserRepository _userRepository;

  List<ChoreModel> _chores = [];
  StreamSubscription? _choresSubscription;

  // 가구별 집안일 감시
  void watchChoresByHousehold(String householdId) {
    _choresSubscription?.cancel();
    _choresSubscription = _choreRepository
        .watchChoresByHousehold(householdId)
        .listen((chores) {
      _chores = chores;
      notifyListeners();
    });
  }

  // 집안일 완료
  Future<void> completeChore(String choreId, String userId) async {
    // 1. 집안일 완료 (트랜잭션)
    await _choreRepository.completeChore(choreId, userId);

    // 2. XP 증가 (트랜잭션)
    final chore = await _choreRepository.getChore(choreId);
    if (chore != null) {
      final xpReward = chore.getXpReward();
      await _userRepository.incrementXp(userId, xpReward);
    }

    // 실시간 리스너가 자동으로 UI 업데이트
  }

  @override
  void dispose() {
    _choresSubscription?.cancel();
    super.dispose();
  }
}
```

---

### Step 5: UI 화면 업데이트 (필요 시)

**목표**: Provider 변경사항 반영 및 실시간 동기화 확인

**주요 확인 사항**:
1. `Consumer` 위젯이 올바른 Provider를 구독하는지 확인
2. 실시간 업데이트가 작동하는지 테스트
3. 로딩 상태 처리
4. 에러 처리

**확인할 화면**:
- 로그인/회원가입 화면
- 대시보드
- 집안일 목록
- 리더보드
- 가구 설정

---

### Step 6: Firebase Emulator 테스트

**목표**: 로컬 환경에서 Firebase 기능 테스트

**Emulator 실행**:
```bash
firebase emulators:start
```

**테스트 항목**:
1. **인증 테스트**
   - 이메일/비밀번호 회원가입
   - 로그인/로그아웃
   - 비밀번호 재설정

2. **Firestore 테스트**
   - 사용자 생성/조회/업데이트
   - 가구 생성/멤버 추가/제거
   - 집안일 생성/완료/삭제

3. **실시간 동기화 테스트**
   - 여러 클라이언트(탭) 동시 실행
   - 한쪽에서 변경 → 다른 쪽 자동 업데이트 확인

4. **캐시 전략 테스트**
   - 오프라인 모드 테스트 (인터넷 연결 끊기)
   - 캐시에서 데이터 로드 확인
   - 온라인 복귀 시 동기화 확인

5. **보안 규칙 테스트**
   - 본인 데이터만 수정 가능한지 확인
   - 가구 멤버만 가구 데이터 접근 가능한지 확인

**Emulator UI 접속**:
```
http://localhost:4000
```

---

### Step 7: 실제 Firebase 프로젝트 연결 (선택)

**목표**: Firebase Console에서 프로젝트 생성 및 연결

**작업 순서**:
1. Firebase Console에서 프로젝트 생성
2. Flutter 앱 추가 (Android/iOS/Web)
3. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 다운로드
4. Firebase CLI로 프로젝트 연결
   ```bash
   firebase use --add
   ```
5. Firestore 데이터베이스 생성 (프로덕션 모드)
6. 보안 규칙 배포
   ```bash
   firebase deploy --only firestore:rules
   ```
7. 인덱스 배포
   ```bash
   firebase deploy --only firestore:indexes
   ```
8. Storage 보안 규칙 배포
   ```bash
   firebase deploy --only storage
   ```

**환경 전환**:
```dart
// lib/config/environment.dart에서 환경 변경
EnvironmentConfig.setCurrent(Environment.production);
```

---

## 🔧 Repository 패턴 핵심 원칙

### Cache-First 읽기 전략
```dart
Future<T?> getData(String id) async {
  // 1. 캐시 확인
  final cached = _localCache.get(id);
  if (cached != null) return cached;

  // 2. Firestore 조회
  final data = await _firestoreService.getDocument(collection, id);

  // 3. 캐시 업데이트
  if (data != null) {
    final model = Model.fromFirestoreMap(id, data);
    await _localCache.put(id, model);
    return model;
  }

  return null;
}
```

### Write-Through 쓰기 전략
```dart
Future<void> updateData(T model) async {
  // 1. Firestore 먼저 업데이트
  await _firestoreService.setDocument(
    collection,
    model.id,
    model.toFirestore(),
    merge: true,
  );

  // 2. 캐시 업데이트
  await _localCache.put(model.id, model);
}
```

### 실시간 동기화
```dart
Stream<T?> watchData(String id) {
  return _firestoreService
      .watchDocument(collection, id)
      .map((snapshot) {
    if (!snapshot.exists) {
      _localCache.delete(id);
      return null;
    }

    final model = Model.fromFirestore(snapshot);
    _localCache.put(id, model); // 캐시 자동 업데이트
    return model;
  });
}
```

### 원자적 작업 (트랜잭션)
```dart
Future<void> atomicOperation(String id, Function(T) update) async {
  await _firestoreService.runTransaction((transaction) async {
    final docRef = _firestore.collection(collection).doc(id);
    final snapshot = await transaction.get(docRef);

    final model = Model.fromFirestore(snapshot);
    update(model); // 모델 업데이트

    transaction.update(docRef, model.toFirestore());

    // 캐시 업데이트
    await _localCache.put(id, model);
  });
}
```

---

## 📌 중요 참고사항

### Enum 직렬화 차이점
```dart
// Hive (기존 호환성)
toMap() => {'status': status.toString()}; // 'ChoreStatus.pending'

// Firestore (새 방식)
toFirestore() => {'status': status.name}; // 'pending'
```

### Timestamp vs DateTime 변환
```dart
// Firestore로 저장
'createdAt': Timestamp.fromDate(createdAt)

// Firestore에서 읽기
createdAt: (data['createdAt'] as Timestamp).toDate()
```

### 캐시 무효화 시점
- 로그아웃 시: 전체 캐시 삭제 (`clearCache()`)
- 데이터 삭제 시: 해당 항목만 캐시에서 제거
- 실시간 리스너: 자동으로 캐시 업데이트

### 오프라인 지원
- Firestore는 자동으로 오프라인 캐시 제공
- Hive 캐시는 추가 레이어로 더 빠른 읽기 제공
- 네트워크 복구 시 자동 동기화

---

## 📂 파일 구조 참고

```
lib/
├── config/
│   ├── environment.dart              ✅ 완료
│   └── firebase_config.dart          ✅ 완료
├── models/
│   ├── user_model.dart               ✅ Firestore 호환 완료
│   ├── household_model.dart          ✅ Firestore 호환 완료
│   └── chore_model.dart              ✅ Firestore 호환 완료
├── repositories/
│   ├── user_repository.dart          ✅ 완료
│   ├── household_repository.dart     ✅ 완료
│   └── chore_repository.dart         ✅ 완료
├── services/
│   ├── firebase_auth_service.dart    ✅ 완료
│   ├── firestore_service.dart        ✅ 완료
│   └── database_service.dart         ⚠️  점진적 제거 예정
├── providers/
│   ├── auth_provider.dart            ✅ Step 2 완료 (Firebase + Repository 통합)
│   ├── household_provider.dart       ✅ Step 3 완료 (Repository + 실시간 동기화)
│   └── chore_provider.dart           ⏳ Step 4 작업 필요
├── utils/
│   └── logger.dart                   ✅ 완료 (warning 메서드 개선)
└── main.dart                         ✅ Step 1 완료 (Firebase + Repository 초기화)
```

---

## 🐛 알려진 이슈 및 주의사항

### 1. Analyzer 버전 경고
```
Your current `analyzer` version may not fully support your current SDK version.
Analyzer language version: 3.4.0
SDK language version: 3.9.0
```
**해결 방법**: 무시 가능 (build_runner 작동에 문제 없음)

### 2. memberCount 자동 계산
HouseholdModel의 `memberCount`는 `memberIds.length`로 자동 계산됩니다.
멤버 추가/제거 시 자동 업데이트되므로 수동 설정 불필요.

### 3. 캐시와 Firestore 동기화
실시간 리스너를 사용하면 캐시는 자동으로 최신 상태 유지됩니다.
단, 리스너를 사용하지 않는 경우 `refresh()` 메서드로 수동 갱신 필요.

---

## 📞 문제 발생 시 체크리스트

### 빌드 에러
- [ ] `dart run build_runner build --delete-conflicting-outputs` 실행했는지 확인
- [ ] `flutter pub get` 실행했는지 확인
- [ ] import 경로가 올바른지 확인

### Firebase 연결 에러
- [ ] `firebase.json` 파일이 프로젝트 루트에 있는지 확인
- [ ] Firebase Emulator가 실행 중인지 확인 (`firebase emulators:start`)
- [ ] Environment 설정이 `development`인지 확인

### 실시간 동기화 안 됨
- [ ] `watch*()` 메서드를 사용하고 있는지 확인
- [ ] StreamSubscription을 dispose에서 cancel하고 있는지 확인
- [ ] Firestore 인덱스가 생성되었는지 확인 (Emulator UI에서 확인)

### 캐시 데이터가 오래됨
- [ ] 실시간 리스너가 작동 중인지 확인
- [ ] `refresh*()` 메서드로 수동 갱신 시도
- [ ] `clearCache()` 후 재조회

---

## 📚 추가 참고 문서

- **아키텍처 설계**: [ARCHITECTURE.md](./ARCHITECTURE.md)
- **데이터베이스 스키마**: [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)
- **개발 가이드**: [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
- **작업 로그**: [WORKLOG.md](./WORKLOG.md)

---

**다음 작업 시작**: Step 1 (main.dart 업데이트) 부터 순서대로 진행하세요.
