# ChoreQuest - 개발 가이드

## 📄 문서 정보

- **버전**: 1.0
- **작성일**: 2025-11-03
- **대상**: 개발자 (신규 팀원 온보딩, 기여자)
- **선행 문서**: [ARCHITECTURE.md](./ARCHITECTURE.md), [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)

---

## 1. 개발 환경 설정

### 1.1 필수 도구 설치

#### 1) Flutter SDK

```bash
# Flutter 3.35.4 설치
# https://docs.flutter.dev/get-started/install

# 설치 확인
flutter --version
# Flutter 3.35.4 • channel stable

# 최신 버전 업데이트
flutter upgrade

# Flutter Doctor 실행 (문제 진단)
flutter doctor -v
```

#### 2) IDE 설정

**추천: Visual Studio Code**
```bash
# VS Code 확장 설치
- Flutter (Dart Code)
- Dart
- Error Lens (에러 시각화)
- GitLens (Git 히스토리)
- Firebase (Firebase 지원)
```

**대안: Android Studio**
- Flutter Plugin 설치
- Dart Plugin 설치

#### 3) Git 설정

```bash
# Git 설치 확인
git --version

# 프로젝트 클론
git clone https://github.com/your-org/chorequest.git
cd chorequest

# Git 사용자 설정
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 1.2 프로젝트 초기화

```bash
# 1. 의존성 설치
flutter pub get

# 2. Hive TypeAdapter 생성
dart run build_runner build --delete-conflicting-outputs

# 3. 실행 (웹)
flutter run -d chrome

# 4. 실행 (Android 에뮬레이터)
flutter run

# 5. 실행 (iOS 시뮬레이터 - macOS만)
flutter run -d ios
```

### 1.3 Firebase 설정 (Phase 2)

```bash
# 1. Firebase CLI 설치
npm install -g firebase-tools

# 2. Firebase 로그인
firebase login

# 3. FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# 4. Firebase 프로젝트 설정
flutterfire configure

# 5. Firebase 초기화 (Functions, Hosting)
firebase init
# Firestore, Functions, Hosting 선택
```

---

## 2. 프로젝트 구조

### 2.1 디렉토리 구조

```
lib/
├── main.dart                      # 앱 진입점
├── config/
│   ├── theme.dart                # Material 3 테마
│   └── routes.dart               # 라우팅 설정
├── models/                       # 데이터 모델
│   ├── user_model.dart          # Hive + Firestore
│   ├── user_model.g.dart        # Generated
│   ├── household_model.dart
│   ├── chore_model.dart
│   └── ...
├── providers/                    # 상태 관리 (Provider)
│   ├── auth_provider.dart
│   ├── household_provider.dart
│   ├── chore_provider.dart
│   └── ...
├── services/                     # 비즈니스 로직
│   ├── database_service.dart    # Hive (Phase 1)
│   ├── firebase_auth_service.dart # Firebase Auth (Phase 2)
│   ├── firestore_service.dart   # Firestore (Phase 2)
│   ├── notification_service.dart
│   └── ...
├── repositories/                 # 데이터 접근 추상화 (Phase 2)
│   ├── user_repository.dart
│   ├── household_repository.dart
│   └── chore_repository.dart
├── screens/                      # UI 화면
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart     # TabBar 컨테이너
│   │   ├── dashboard_tab.dart
│   │   ├── chores_tab.dart
│   │   ├── leaderboard_tab.dart
│   │   └── profile_tab.dart
│   ├── chore/
│   │   └── add_chore_screen.dart
│   └── ...
├── widgets/                      # 재사용 위젯
│   ├── common/
│   │   ├── loading_indicator.dart
│   │   └── error_message.dart
│   ├── chore/
│   │   └── chore_list_tile.dart
│   └── gamification/
│       └── xp_progress_card.dart
└── utils/                        # 유틸리티
    ├── constants.dart           # 상수
    ├── date_helpers.dart        # 날짜 헬퍼
    └── xp_calculator.dart       # XP 계산

test/                             # 테스트
├── unit/
│   ├── models/
│   └── services/
├── widget/
│   └── screens/
└── integration/
    └── chore_completion_test.dart

functions/                        # Firebase Cloud Functions
├── src/
│   ├── index.ts
│   ├── triggers/                # Firestore 트리거
│   ├── scheduled/               # Cron Jobs
│   └── callable/                # Callable Functions
└── package.json
```

### 2.2 명명 규칙

#### 파일명
```dart
// ✅ 소문자 + 스네이크 케이스
user_model.dart
chore_provider.dart
add_chore_screen.dart

// ❌ 카멜 케이스 (X)
userModel.dart
ChoreProvider.dart
```

#### 클래스명
```dart
// ✅ 파스칼 케이스 (PascalCase)
class UserModel {}
class ChoreProvider {}
class AddChoreScreen {}
```

#### 변수/함수명
```dart
// ✅ 카멜 케이스 (camelCase)
final currentUser = ...;
void completeChore() {}

// Private 변수는 언더스코어 prefix
final _isLoading = false;
```

#### 상수
```dart
// ✅ 대문자 + 스네이크 케이스
const MAX_HOUSEHOLD_MEMBERS = 10;
const API_BASE_URL = '...';
```

---

## 3. 코딩 스타일 가이드

### 3.1 Dart 스타일 가이드

```dart
// ✅ const 사용
const Text('Hello')
const SizedBox(height: 16)

// ✅ final 사용 (불변 변수)
final user = Provider.of<AuthProvider>(context).currentUser;

// ✅ 타입 명시 (가독성)
final List<ChoreModel> chores = [];
final Map<String, dynamic> data = {};

// ❌ var 남용 (X)
var chores = []; // 타입 불명확
```

### 3.2 Provider 사용 패턴

```dart
// ✅ Consumer (부분 리빌드)
Consumer<ChoreProvider>(
  builder: (context, choreProvider, child) {
    return ChoreList(chores: choreProvider.chores);
  },
)

// ✅ Selector (특정 값만 감시)
Selector<AuthProvider, int>(
  selector: (_, auth) => auth.currentUser?.xp ?? 0,
  builder: (context, xp, child) => Text('XP: $xp'),
)

// ✅ Provider.of (빌드 트리거 없음)
final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
choreProvider.completeChore(choreId);

// ❌ Provider.of (listen: true) 남용 (불필요한 리빌드)
final choreProvider = Provider.of<ChoreProvider>(context); // 전체 리빌드!
```

### 3.3 에러 처리

```dart
// ✅ try-catch with 사용자 피드백
Future<void> completeChore(String choreId) async {
  try {
    await _choreRepository.completeChore(choreId);
    _showSnackBar('집안일 완료! +10 XP 획득');
  } on FirebaseException catch (e) {
    _showErrorDialog('오류 발생: ${e.message}');
  } catch (e) {
    _showErrorDialog('알 수 없는 오류가 발생했습니다.');
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}
```

### 3.4 비동기 프로그래밍

```dart
// ✅ async/await
Future<UserModel?> getUser(String userId) async {
  final data = await _firestoreService.getDocument('users', userId);
  if (data == null) return null;
  return UserModel.fromJson(data);
}

// ✅ Future.wait (병렬 실행)
final results = await Future.wait([
  getUser(userId1),
  getUser(userId2),
  getUser(userId3),
]);

// ❌ then 체이닝 (가독성 떨어짐)
getUser(userId).then((user) {
  getHousehold(user.householdId).then((household) {
    // ...
  });
});
```

---

## 4. 주요 기능 개발 가이드

### 4.1 새 화면 추가하기

#### Step 1: 화면 파일 생성

```dart
// lib/screens/example/example_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예시 화면'),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
```

#### Step 2: 라우팅 추가

```dart
// lib/config/routes.dart
static const String example = '/example';

// MaterialApp에 라우트 추가
routes: {
  '/example': (context) => const ExampleScreen(),
  // ...
},
```

#### Step 3: 네비게이션

```dart
// 화면 이동
Navigator.pushNamed(context, '/example');

// 데이터 전달
Navigator.pushNamed(
  context,
  '/example',
  arguments: {'userId': '123'},
);
```

### 4.2 새 Provider 추가하기

```dart
// lib/providers/example_provider.dart
import 'package:flutter/foundation.dart';

class ExampleProvider extends ChangeNotifier {
  final ExampleService _service;

  ExampleProvider(this._service);

  // 상태
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 메서드
  Future<void> doSomething() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.doSomething();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

#### main.dart에 Provider 등록

```dart
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(...)),
      ChangeNotifierProvider(create: (_) => ExampleProvider(...)),
      // ...
    ],
    child: MyApp(),
  ),
);
```

### 4.3 Firestore 데이터 CRUD

```dart
// 생성 (Create)
Future<void> createChore(ChoreModel chore) async {
  await FirebaseFirestore.instance
      .collection('chores')
      .doc(chore.id)
      .set(chore.toJson());
}

// 조회 (Read)
Future<ChoreModel?> getChore(String choreId) async {
  final doc = await FirebaseFirestore.instance
      .collection('chores')
      .doc(choreId)
      .get();

  if (!doc.exists) return null;
  return ChoreModel.fromJson(doc.data()!);
}

// 업데이트 (Update)
Future<void> updateChore(ChoreModel chore) async {
  await FirebaseFirestore.instance
      .collection('chores')
      .doc(chore.id)
      .update(chore.toJson());
}

// 삭제 (Delete)
Future<void> deleteChore(String choreId) async {
  await FirebaseFirestore.instance
      .collection('chores')
      .doc(choreId)
      .delete();
}

// 실시간 감시 (Watch)
Stream<List<ChoreModel>> watchChores(String householdId) {
  return FirebaseFirestore.instance
      .collection('chores')
      .where('householdId', isEqualTo: householdId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChoreModel.fromJson(doc.data()))
            .toList();
      });
}
```

---

## 5. 테스트 작성 가이드

### 5.1 단위 테스트 (Unit Test)

```dart
// test/unit/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('gainXp increases XP correctly', () {
      final user = UserModel(
        id: '1',
        name: 'Test',
        email: 'test@test.com',
        xp: 0,
        level: 1,
      );

      final updatedUser = user.gainXp(100);

      expect(updatedUser.xp, 100);
      expect(updatedUser.level, 2); // 100 XP로 레벨 2
    });

    test('level up formula is correct', () {
      expect(UserModel.getRequiredXpForLevel(2), 100);
      expect(UserModel.getRequiredXpForLevel(3), 283);
    });
  });
}
```

### 5.2 위젯 테스트 (Widget Test)

```dart
// test/widget/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chorequest/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen has email field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('이메일'), findsOneWidget);
  });
}
```

### 5.3 통합 테스트 (Integration Test)

```dart
// test/integration/chore_completion_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chorequest/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete chore flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. 로그인
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    // 2. 집안일 완료 버튼 클릭
    await tester.tap(find.byIcon(Icons.check_circle_outline).first);
    await tester.pumpAndSettle();

    // 3. XP 획득 SnackBar 확인
    expect(find.text('집안일 완료!'), findsOneWidget);
  });
}
```

---

## 6. Git 워크플로우

### 6.1 브랜치 전략 (Git Flow)

```
main (프로덕션)
  └─ develop (개발)
      ├─ feature/add-kakao-login (기능 개발)
      ├─ feature/leaderboard-animation (기능 개발)
      ├─ bugfix/xp-calculation-error (버그 수정)
      └─ hotfix/critical-crash (긴급 수정)
```

### 6.2 브랜치 명명 규칙

```bash
# 기능 개발
feature/기능명
예: feature/kakao-login, feature/recurring-chores

# 버그 수정
bugfix/버그명
예: bugfix/xp-negative-value

# 긴급 수정 (프로덕션)
hotfix/문제명
예: hotfix/login-crash

# 문서 작성
docs/문서명
예: docs/update-readme
```

### 6.3 커밋 메시지 컨벤션

```bash
# 형식
<type>: <subject>

<body>

# 타입
feat: 새 기능
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅 (기능 변경 없음)
refactor: 리팩토링
test: 테스트 추가
chore: 빌드, 패키지 업데이트

# 예시
feat: Add KakaoTalk login integration

- Implement Kakao OAuth flow
- Add Kakao SDK dependency
- Update login screen UI

# 예시 2
fix: Fix negative XP bug when completing chore

- Prevent XP from going negative
- Add validation in gainXp() method
- Add unit test for edge case
```

### 6.4 Pull Request 프로세스

```bash
# 1. 작업 브랜치 생성
git checkout -b feature/kakao-login

# 2. 작업 및 커밋
git add .
git commit -m "feat: Add KakaoTalk login"

# 3. 원격 푸시
git push origin feature/kakao-login

# 4. GitHub에서 PR 생성
# Base: develop <- Compare: feature/kakao-login

# 5. PR 템플릿
```

#### PR 템플릿

```markdown
## 변경 사항
- 카카오톡 로그인 기능 추가
- OAuth 플로우 구현

## 테스트
- [ ] 단위 테스트 통과
- [ ] 위젯 테스트 통과
- [ ] 수동 테스트 완료

## 스크린샷
(스크린샷 첨부)

## 체크리스트
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트
- [ ] 변경 이력 추가
```

---

## 7. 빌드 및 배포

### 7.1 웹 빌드

```bash
# 프로덕션 빌드
flutter build web --release

# 빌드 결과
build/web/

# Firebase Hosting 배포
firebase deploy --only hosting
```

### 7.2 Android APK 빌드

```bash
# APK 빌드
flutter build apk --release

# 빌드 결과
build/app/outputs/flutter-apk/app-release.apk

# App Bundle (Google Play)
flutter build appbundle --release
build/app/outputs/bundle/release/app-release.aab
```

### 7.3 iOS 빌드 (macOS)

```bash
# iOS 빌드
flutter build ios --release

# Xcode에서 Archive 및 업로드
open ios/Runner.xcworkspace
```

### 7.4 환경 변수 설정

```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5001',
  );

  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}

// 빌드 시 환경 변수 전달
flutter build web --dart-define=API_URL=https://api.chorequest.app --dart-define=PRODUCTION=true
```

---

## 8. 디버깅 및 문제 해결

### 8.1 자주 발생하는 문제

#### 1) "Waiting for another flutter command to release the startup lock"

```bash
# 해결: 잠금 파일 삭제
rm -rf /path/to/flutter/bin/cache/lockfile
```

#### 2) Firebase 초기화 에러

```bash
# 해결: FlutterFire 재설정
flutterfire configure
```

#### 3) Hive TypeAdapter 오류

```bash
# 해결: build_runner 재실행
dart run build_runner build --delete-conflicting-outputs
```

### 8.2 디버깅 팁

```dart
// 1. print() 대신 debugPrint() 사용
debugPrint('User: $user');

// 2. assert() 사용 (디버그 모드에서만 실행)
assert(xp >= 0, 'XP cannot be negative');

// 3. Flutter Inspector (VS Code)
// Cmd/Ctrl + Shift + P → "Flutter: Open DevTools"

// 4. 성능 프로파일링
// DevTools → Performance 탭
```

---

## 9. 참고 자료

### 공식 문서
- Flutter Docs: https://docs.flutter.dev
- Firebase Docs: https://firebase.google.com/docs
- Dart Style Guide: https://dart.dev/guides/language/effective-dart

### 패키지
- Provider: https://pub.dev/packages/provider
- Hive: https://pub.dev/packages/hive
- Cloud Firestore: https://pub.dev/packages/cloud_firestore

### 커뮤니티
- Flutter Community: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

## 10. 체크리스트

### 신규 개발자 온보딩
- [ ] Flutter SDK 설치 및 doctor 실행
- [ ] 프로젝트 클론 및 pub get
- [ ] VS Code 확장 설치
- [ ] 웹 빌드 및 로컬 실행 확인
- [ ] PRD.md, ARCHITECTURE.md 읽기
- [ ] 첫 번째 이슈 할당받기

### PR 제출 전
- [ ] 로컬 테스트 통과 (`flutter test`)
- [ ] 빌드 성공 (`flutter build web`)
- [ ] 코드 포맷팅 (`dart format .`)
- [ ] Lint 오류 없음 (`flutter analyze`)
- [ ] 커밋 메시지 컨벤션 준수
- [ ] PR 템플릿 작성

---

<div align="center">
  <strong>ChoreQuest Development Guide</strong> v1.0<br>
  Happy Coding! 🚀
</div>
