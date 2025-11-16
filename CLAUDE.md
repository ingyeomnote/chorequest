# ChoreQuest - AI 어시스턴트 컨텍스트 문서

## 📄 문서 목적

이 문서는 Claude, ChatGPT 등 AI 어시스턴트가 ChoreQuest 프로젝트를 빠르게 이해하고 효과적으로 지원할 수 있도록 작성된 컨텍스트 가이드입니다.

---

## 1. 프로젝트 개요

### 1.1 기본 정보

- **프로젝트명**: ChoreQuest (한국명: 홈챌린저)
- **목적**: 가사 노동의 정신적 부담을 줄이고 가족 간 공정한 분담을 지원하는 협업 앱
- **타겟**: 한국 맞벌이 부부, 유자녀 가정, 룸메이트
- **현재 상태**: Phase 2 Firebase 마이그레이션 진행 중 (Step 1-3 완료, Step 4 진행 예정)
- **기술 스택**: Flutter 3.35.4, Dart 3.9.2, Hive (로컬 캐시), Firebase (클라우드 동기화)

### 1.2 핵심 가치 제안

ChoreQuest는 단순한 할 일 관리 앱이 아닙니다. 다음 세 가지 핵심 문제를 해결합니다:

1. **정신적 노동 경감**: 집안일 계획, 분배, 감독의 인지적 부담 감소
2. **기여도 가시화**: 객관적 포인트/레벨 시스템으로 "누가 더 많이 했는가" 논쟁 해소
3. **지속적 동기 부여**: RPG 게임화로 반복적인 집안일에 재미 부여

### 1.3 차별화 요소

- **초월적 현지화**: 카카오톡 연동, 한국형 집안일 템플릿 (예: "김치냉장고 정리", "명절 준비")
- **협업적 온보딩**: 가족 전체가 함께 초기 설정 (앱 관리자 함정 방지)
- **다층적 게임화**: 즉각 보상(포인트) + 장기 성장(레벨) + 사회적 요소(리더보드) + 협력 목표

---

## 2. 문서 구조

프로젝트의 주요 문서는 다음과 같이 구성되어 있습니다:

### 비즈니스/전략 문서
1. **[Summary.md](./Summary.md)** ⭐ 최우선 참고
   - 시장 분석, 경쟁사 분석, 비즈니스 전략
   - 가사 노동의 정신적 부담, 경쟁사(Sweepy, OurHome) 분석
   - "왜 이 기능이 필요한가?"에 대한 답

2. **[PRD.md](./PRD.md)** ⭐ 최우선 참고
   - 제품 요구사항 정의서
   - Phase별 기능 우선순위, 사용자 페르소나, KPI
   - 신기능 추가 시 필수 참고

3. **[DOMAIN_STRATEGY.md](./DOMAIN_STRATEGY.md)**
   - 도메인명, 브랜딩, 마케팅 전략
   - 앱 이름, 로고, 색상 등 결정 사항

### 기술 문서
4. **[ARCHITECTURE.md](./ARCHITECTURE.md)** ⭐ 최우선 참고
   - Phase 2 (Firebase) 아키텍처 설계
   - Flutter 클라이언트, Firebase, Cloud Functions 구조
   - 데이터 플로우, 보안, 성능 최적화

5. **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** ⭐ 최우선 참고
   - Firebase Firestore 스키마 상세
   - Collection 구조, 인덱스, 보안 규칙
   - 데이터베이스 관련 질문 시 필수

6. **[PHASE2_PROGRESS.md](./PHASE2_PROGRESS.md)** ⭐ Phase 2 작업 시 필수
   - Firebase 마이그레이션 진행 상황 (Step 1-3 완료)
   - Repository 패턴 구현 상세
   - 다음 작업 단계 및 체크리스트
   - 완료된 작업: main.dart, AuthProvider, HouseholdProvider
   - 진행 예정: ChoreProvider 업데이트 (Step 4)

7. **[TECHNICAL_DOCUMENTATION.md](./TECHNICAL_DOCUMENTATION.md)**
   - Phase 1 (Hive) MVP 기술 문서
   - XP 시스템, Hive 데이터베이스, Provider 패턴

8. **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)**
   - 개발자 온보딩, 코딩 스타일, Git 워크플로우
   - 개발 환경 설정, 테스트 작성, 디버깅

9. **[WORKLOG.md](./WORKLOG.md)**
   - 일별 개발 작업 로그
   - 완료된 작업, 다음 작업, 메모

### 기타
10. **[README.md](./README.md)**
   - 프로젝트 개요, 빠른 시작 가이드
   - 외부 기여자/투자자 대상

---

## 3. AI 어시스턴트 활용 가이드

### 3.1 질문 시 컨텍스트 제공 방법

AI에게 질문할 때 다음 형식을 사용하면 더 정확한 답변을 받을 수 있습니다:

```
[상황] ChoreQuest는 Flutter로 개발된 가사 관리 앱입니다.
        현재 Phase 2 Firebase 마이그레이션 진행 중 (Step 1-3 완료)

[문서] PRD.md에 따르면 Phase 2에서 카카오톡 연동 기능을 추가해야 합니다.

[질문] Cloud Functions에서 매일 오전 8시에 카카오톡으로 오늘의 할 일을 전송하는
        scheduled function을 어떻게 구현하나요?

[참고] ARCHITECTURE.md의 "Cloud Functions" 섹션과 PHASE2_PROGRESS.md를 참고해주세요.
```

### 3.2 문서별 활용 가이드

| 질문 유형 | 참고 문서 | 예시 질문 |
|-----------|-----------|----------|
| 왜 이 기능이 필요한가? | Summary.md, PRD.md | "협업적 온보딩이 왜 중요한가요?" |
| 이 기능의 우선순위는? | PRD.md | "Phase 2에서 무엇을 먼저 개발해야 하나요?" |
| 어떻게 구현하나요? | ARCHITECTURE.md, PHASE2_PROGRESS.md | "Repository 패턴을 어떻게 구현하나요?" |
| 데이터 구조는? | DATABASE_SCHEMA.md | "집안일 반복 설정은 어떤 필드로 저장하나요?" |
| 코딩 스타일은? | DEVELOPMENT_GUIDE.md | "Provider 사용 시 주의사항은?" |
| Phase 2 진행 상황은? | PHASE2_PROGRESS.md, WORKLOG.md | "다음에 무엇을 작업해야 하나요?" |

### 3.3 자주 묻는 질문 (FAQ)

#### Q1: ChoreQuest의 핵심 차별화 요소는?
**A**: Summary.md 섹션 1.2, PRD.md 섹션 1.2 참고
- 정신적 노동 경감 (자동 스케줄링, 담당자 순환)
- 카카오톡 연동 (한국 시장 특화)
- 협업적 온보딩 ("앱 관리자" 함정 방지)

#### Q2: XP/레벨 시스템은 어떻게 작동하나요?
**A**: TECHNICAL_DOCUMENTATION.md 섹션 2.1 참고
```dart
// XP 공식 (Habitica 스타일)
100 * (level^1.5)

// 난이도별 XP
쉬움: +10 XP
보통: +25 XP
어려움: +50 XP
```

#### Q3: Firebase 마이그레이션 진행 상황은?
**A**: PHASE2_PROGRESS.md 참고
- Step 1-3 완료 (main.dart, AuthProvider, HouseholdProvider)
- Step 4 진행 예정 (ChoreProvider)
- Repository 패턴 구현 완료 (UserRepository, HouseholdRepository, ChoreRepository)

#### Q4: 프리미엄 구독 모델은?
**A**: PRD.md 섹션 3.2.5, Summary.md 섹션 4.1 참고
- 무료: 3명까지, 기본 기능
- 프리미엄: 월 ₩4,900 / 연 ₩49,000, 무제한 멤버, 고급 통계

#### Q5: 카카오톡 연동은 어떻게 구현하나요?
**A**: ARCHITECTURE.md 섹션 3.3, PRD.md 섹션 3.2.4 참고
- Cloud Functions (Scheduled) + Kakao Message API
- 매일 오전 8시 오늘의 할 일 전송

---

## 4. 프로젝트 현황 (2025-11-16 기준)

### 4.1 완료된 기능 (Phase 1 MVP)

✅ **사용자 관리**
- 이메일 기반 회원가입/로그인
- 사용자 프로필 (이름, 이메일)
- XP/레벨 시스템

✅ **가구(Household) 관리**
- 가구 생성 및 설정
- 멤버 관리

✅ **집안일(Chore) 시스템**
- CRUD 기능
- 난이도 설정 (쉬움/보통/어려움)
- 마감일, 상태 관리
- 캘린더 통합 뷰

✅ **게임화 시스템**
- XP 획득 및 레벨업
- 리더보드 (가구 내 순위)
- 완료 애니메이션

✅ **UI/UX**
- Material Design 3
- 다크 모드
- 마이크로 인터랙션 (flutter_animate)

### 4.2 진행 중 (Phase 2 Firebase 마이그레이션)

✅ **Firebase 인프라 구축** (완료)
- Firebase Core, Auth, Firestore, Storage, Analytics 설정
- Firebase Emulator 구성 (Firestore:8080, Auth:9099, Storage:9199, UI:4000)
- 환경별 설정 시스템 (dev/staging/prod)
- Firestore 보안 규칙 및 인덱스 정의

✅ **핵심 서비스 구현** (완료)
- `FirebaseAuthService`: 이메일/비밀번호 로그인, Google Sign-In, 한국어 에러 메시지
- `FirestoreService`: CRUD, 실시간 리스너, 트랜잭션, 배치 작업

✅ **데이터 모델 Firestore 호환** (완료)
- `UserModel`: Firestore 직렬화, Phase 2 필드 추가 (achievements, streaks, lastLoginAt 등)
- `HouseholdModel`: Firestore 직렬화, Phase 2 필드 추가 (avatarUrl, memberCount, adminIds)
- `ChoreModel`: Firestore 직렬화, Enum 최적화 (.name 사용)
- Hive 호환성 유지 (로컬 캐싱용)

✅ **Repository 패턴 구현** (완료)
- `UserRepository`: Cache-first 읽기, 실시간 동기화, XP 트랜잭션, 리더보드
- `HouseholdRepository`: 가구 CRUD, 멤버 관리 트랜잭션, 실시간 감시
- `ChoreRepository`: 집안일 CRUD, 완료 트랜잭션, 다양한 쿼리 메서드

✅ **Provider 통합** (Step 1-3 완료)
- `main.dart`: Firebase + Hive 통합 초기화, Repository 인스턴스 생성 및 Provider 등록
- `AuthProvider`: FirebaseAuthService + UserRepository 통합, Auth state listener, XP 트랜잭션
- `HouseholdProvider`: HouseholdRepository + UserRepository 통합, 실시간 동기화 스트림

🚧 **Provider 통합** (Step 4 - 다음 작업)
- `ChoreProvider`: ChoreRepository 통합, 실시간 스트림 연결 (진행 예정)

🚧 **정신적 노동 경감 UX** (P0 - 계획됨)
- 협업적 온보딩
- 자동 스케줄링 및 순환
- 관리자 역할 순환

🚧 **다층적 게임화** (P0 - 계획됨)
- 아바타, 테마, 배지 시스템
- 가족 협력 목표
- 연속 달성 (Streak)

🚧 **한국 시장 현지화** (P1 - 계획됨)
- 카카오톡 알림 연동
- 한국형 집안일 템플릿
- 카카오 로그인

🚧 **프리미엄 구독** (P1 - 계획됨)
- 월/연 구독 결제
- 보상형 광고
- IAP (꾸미기 아이템)

### 4.3 장기 로드맵 (Phase 3+)

📅 **Phase 3** (중기)
- 복잡한 반복 패턴
- 가구 초대 코드 시스템
- 통계 및 월간 리포트
- 업적 및 배지 시스템

📅 **Phase 4** (장기)
- 가구 내 채팅
- IoT 연동 (SmartThings)
- 음성 명령
- 커뮤니티 플랫폼 ("오늘의집" 스타일)

---

## 5. 코드 베이스 이해

### 5.1 주요 디렉토리

```
lib/
├── config/                  # 환경 및 Firebase 설정
│   ├── environment.dart     # 환경별 설정 (dev/staging/prod)
│   └── firebase_config.dart # Firebase 초기화 및 Emulator 설정
├── models/                  # 데이터 모델 (Hive + Firestore 호환)
│   ├── user_model.dart
│   ├── household_model.dart
│   ├── household.dart
│   └── chore_model.dart
├── providers/               # 상태 관리 (Provider 패턴)
│   ├── auth_provider.dart       # ✅ Firebase 통합 완료
│   ├── household_provider.dart  # ✅ Repository 통합 완료
│   └── chore_provider.dart      # 🚧 통합 진행 예정
├── repositories/            # 데이터 접근 계층 (Cache-first)
│   ├── user_repository.dart      # ✅ 완료
│   ├── household_repository.dart # ✅ 완료
│   └── chore_repository.dart     # ✅ 완료
├── services/                # 비즈니스 로직 및 Firebase 서비스
│   ├── firebase_auth_service.dart  # ✅ 완료
│   ├── firestore_service.dart      # ✅ 완료
│   └── database_service.dart       # ⚠️  점진적 제거 예정 (Hive 전용)
├── screens/                 # UI 화면
│   ├── auth/               # 로그인, 회원가입
│   ├── chore/              # 집안일 추가/편집
│   ├── home/               # 대시보드, 집안일 목록, 리더보드, 프로필
│   ├── household/          # 가구 생성/관리
│   └── profile/            # 설정, 도움말
├── utils/                   # 유틸리티
│   └── logger.dart          # 개발용 로거
└── widgets/                 # 재사용 위젯
    ├── xp_progress_card.dart
    └── chore_list_tile.dart

firebase/                    # Firebase 설정 (Phase 2)
├── firebase.json            # Firebase 프로젝트 설정
├── firestore.rules          # Firestore 보안 규칙
├── firestore.indexes.json   # Firestore 인덱스
└── storage.rules            # Storage 보안 규칙

functions/                   # Firebase Cloud Functions (Phase 3 예정)
├── src/
│   ├── triggers/            # Firestore 트리거
│   ├── scheduled/           # Cron Jobs (카카오톡 알림 등)
│   └── callable/            # Callable Functions
```

### 5.2 핵심 파일

| 파일 | 역할 | 참고 |
|------|------|------|
| `lib/main.dart` | 앱 진입점, Firebase + Hive 초기화, Repository 및 Provider 등록 | PHASE2_PROGRESS.md Step 1 |
| `lib/config/firebase_config.dart` | Firebase 초기화, Emulator 설정 | ARCHITECTURE.md |
| `lib/models/user_model.dart` | User 모델, XP/레벨 로직, Firestore 직렬화 | DATABASE_SCHEMA.md |
| `lib/models/household_model.dart` | Household 모델, Firestore 직렬화 | DATABASE_SCHEMA.md |
| `lib/models/chore_model.dart` | Chore 모델, Firestore 직렬화 | DATABASE_SCHEMA.md |
| `lib/services/firebase_auth_service.dart` | Firebase 인증 서비스 (이메일, Google) | PHASE2_PROGRESS.md |
| `lib/services/firestore_service.dart` | Firestore CRUD, 실시간 리스너, 트랜잭션 | PHASE2_PROGRESS.md |
| `lib/repositories/user_repository.dart` | User 데이터 접근 (Cache-first, 실시간 동기화) | PHASE2_PROGRESS.md |
| `lib/repositories/household_repository.dart` | Household 데이터 접근 | PHASE2_PROGRESS.md |
| `lib/repositories/chore_repository.dart` | Chore 데이터 접근 | PHASE2_PROGRESS.md |
| `lib/providers/auth_provider.dart` | 인증 상태 관리, Firebase + Repository 통합 | PHASE2_PROGRESS.md Step 2 |
| `lib/providers/household_provider.dart` | 가구 상태 관리, 실시간 동기화 | PHASE2_PROGRESS.md Step 3 |
| `lib/providers/chore_provider.dart` | 집안일 상태 관리 (Repository 통합 예정) | PHASE2_PROGRESS.md Step 4 |
| `lib/screens/home/dashboard_tab.dart` | 대시보드 화면 | |
| `lib/services/database_service.dart` | Hive CRUD (Phase 1, 점진적 제거 예정) | |

### 5.3 데이터 플로우 예시

**집안일 완료 플로우** (Phase 2 - Repository 패턴)
```
사용자 액션: "완료" 버튼 클릭
    ↓
ChoreListTile._completeChore()
    ↓
ChoreProvider.completeChore(choreId, userId)
    ├─→ ChoreRepository.completeChore(choreId, userId)  [트랜잭션]
    │   ├─→ Firestore: chores/{choreId} 업데이트 (status: completed)
    │   └─→ Hive: 캐시 업데이트
    └─→ UserRepository.incrementXp(userId, xpAmount)  [트랜잭션]
        ├─→ Firestore: users/{userId} 업데이트 (xp, level)
        └─→ Hive: 캐시 업데이트
    ↓
Firestore 실시간 리스너
    ├─→ ChoreProvider.watchChoresByHousehold() 스트림
    └─→ HouseholdProvider.watchLeaderboard() 스트림
    ↓
Provider.notifyListeners() (자동)
    ↓
UI 리빌드 (XpProgressCard, LeaderboardTab, ChoreList)
```

**캐시 전략**
- **읽기**: Cache-first (Hive 캐시 → Firestore 조회 → 캐시 업데이트)
- **쓰기**: Write-through (Firestore 먼저 → 캐시 업데이트)
- **실시간**: Firestore listener가 캐시 자동 업데이트

---

## 6. 개발 시 주의사항

### 6.1 비즈니스 룰

1. **정신적 노동 경감 최우선**: 모든 기능 개발 시 "이것이 사용자의 인지적 부담을 줄이는가?" 질문
2. **OurHome 실패 교훈**: 안정성 > 기능 다양성. 실시간 동기화가 완벽하지 않으면 출시하지 말 것
3. **Sweepy 성공 사례**: 게임화는 단순한 포인트가 아니라 감정적 보상(성취감, 공정함)을 제공해야 함

### 6.2 기술적 제약

1. **Firebase 무료 플랜 한계**: 읽기 50K/일, 쓰기 20K/일 → 캐싱 전략 필수
2. **Flutter Web 성능**: 모바일 대비 느림 → Phase 2에서 모바일 네이티브 앱 우선
3. **Firestore 비용**: 쿼리 최적화, 불필요한 리스너 제거 필수

### 6.3 코딩 컨벤션

- **Repository 패턴**: 모든 Firestore 접근은 Repository를 통해서만 수행
- **Provider 패턴**: `Consumer` 또는 `Selector` 사용, `Provider.of(listen: true)` 남용 금지
- **실시간 동기화**: `watch*()` 메서드 사용, StreamSubscription은 dispose에서 cancel
- **트랜잭션**: 원자적 작업은 반드시 트랜잭션 사용 (XP 증가, 멤버 추가/제거 등)
- **캐시 관리**: 로그아웃 시 전체 캐시 삭제, 실시간 리스너가 자동으로 캐시 업데이트
- **비동기**: `async/await` 사용, `then` 체이닝 지양
- **에러 처리**: 사용자 피드백 필수 (`_showSnackBar`, `_showErrorDialog`)
- **테스트**: 단위 테스트 + 통합 테스트, PR 전 필수 실행

### 6.4 Firebase Emulator 사용

**Emulator 시작**:
```bash
firebase emulators:start
```

**포트 정보**:
- Firestore: localhost:8080
- Auth: localhost:9099
- Storage: localhost:9199
- Emulator UI: localhost:4000

**환경 전환**:
```dart
// lib/config/environment.dart
EnvironmentConfig.setCurrent(Environment.development); // Emulator 사용
EnvironmentConfig.setCurrent(Environment.production);  // 실제 Firebase
```

---

## 7. AI 어시스턴트 프롬프트 예시

### 7.1 기능 개발 요청

```
ChoreQuest 프로젝트에서 "카카오톡 알림 연동" 기능을 개발하려고 합니다.

[요구사항] (PRD.md 섹션 3.2.4 참고)
- 매일 오전 8시에 오늘의 할 일을 카카오톡 메시지로 전송
- 마감 임박 집안일은 별도 알림

[기술 스택]
- Firebase Cloud Functions (TypeScript)
- Kakao Message API

[질문]
1. Cloud Functions scheduled function 구현 코드 작성
2. Kakao Message API 연동 방법
3. Firestore에서 오늘 마감 집안일 쿼리

ARCHITECTURE.md 섹션 3.3과 DATABASE_SCHEMA.md의 chores 스키마를 참고해주세요.
```

### 7.2 코드 리뷰 요청

```
다음 코드에 대한 리뷰를 부탁드립니다.

[코드]
(코드 붙여넣기)

[확인 사항]
1. DEVELOPMENT_GUIDE.md의 코딩 스타일 준수 여부
2. Repository 패턴 올바른 사용 여부
3. 실시간 동기화 및 캐시 전략 적용 여부
4. 에러 처리 및 사용자 피드백
5. 성능 최적화 가능 부분

특히 "불필요한 리빌드"와 "Firestore 읽기 비용"을 중점적으로 봐주세요.
```

### 7.3 문서 이해 요청

```
PHASE2_PROGRESS.md를 읽고 다음 질문에 답변해주세요.

1. 현재 완료된 작업은 무엇인가요?
2. 다음에 작업해야 할 것은 무엇인가요?
3. Repository 패턴의 Cache-first 전략이란?
4. ChoreProvider 업데이트 시 어떤 작업이 필요한가요?
```

---

## 8. 기여 가이드

### 8.1 이슈 제출

```markdown
## 이슈 유형
- [ ] 버그
- [ ] 기능 제안
- [ ] 문서 개선

## 설명
(문제 상황 설명)

## 재현 방법 (버그인 경우)
1. ...
2. ...

## 기대 동작
(예상되는 동작)

## 스크린샷
(필요시 첨부)

## 환경
- Flutter 버전:
- 플랫폼: Web / Android / iOS
```

### 8.2 Pull Request

```markdown
## 변경 사항
- ...

## 관련 이슈
Closes #123

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 수동 테스트 완료

## 참고 문서
- PRD.md 섹션 X.Y
- ARCHITECTURE.md 섹션 Z
```

---

## 9. 연락처 및 지원

### 프로젝트 관련
- GitHub Issues: (저장소 URL)
- 이메일: team@chorequest.app (Phase 2 이후)

### 문서 기여
- 문서 오류 발견 시: GitHub Issues 또는 PR
- 새 문서 제안: `docs/` 브랜치에서 작업

---

## 10. Phase 2 진행 상황 체크리스트

자세한 내용은 [PHASE2_PROGRESS.md](./PHASE2_PROGRESS.md) 참고

### ✅ 완료된 단계
- **Step 0**: 문서화 및 Firebase 인프라 구축 ✅
- **Step 1**: main.dart 업데이트 및 Repository 초기화 ✅
- **Step 2**: AuthProvider 업데이트 (FirebaseAuthService + UserRepository 통합) ✅
- **Step 3**: HouseholdProvider 업데이트 (HouseholdRepository + 실시간 동기화) ✅

### 🚧 다음 작업
- **Step 4**: ChoreProvider 업데이트 (ChoreRepository 통합, 실시간 스트림)
- **Step 5**: UI 화면 업데이트 및 테스트
- **Step 6**: Firebase Emulator 테스트
- **Step 7**: 실제 Firebase 프로젝트 연결

### 📌 중요 참고사항
- **Enum 직렬화**: Hive는 `toString()`, Firestore는 `.name` 사용
- **Timestamp 변환**: `Timestamp.fromDate()` / `Timestamp.toDate()` 사용
- **캐시 무효화**: 로그아웃 시 `clearCache()`, 실시간 리스너가 자동 업데이트
- **오프라인 지원**: Firestore 자동 오프라인 캐시 + Hive 추가 레이어

---

## 11. 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-11-03 | 초안 작성 |
| 2.0 | 2025-11-16 | Phase 2 진행 상황 반영, Repository 패턴 추가, Firebase 통합 업데이트 |

---

<div align="center">
  <strong>ChoreQuest AI Context Document</strong> v2.0<br>
  AI 어시스턴트가 프로젝트를 효과적으로 지원하기 위한 컨텍스트 가이드
</div>
