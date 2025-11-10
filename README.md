# ChoreQuest (홈챌린저) - 가족 협력형 집안일 관리 앱

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.35.4-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.9.2-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Status-MVP-green" alt="Status">
  <img src="https://img.shields.io/badge/Phase-1--Complete-success" alt="Phase">
</div>

## 📋 프로젝트 개요

**ChoreQuest (한국명: 홈챌린저)**는 가사 노동의 정신적 부담을 줄이고 가족 간 공정한 분담을 지원하는 협업 앱입니다. Habitica의 RPG 게임화 메커니즘과 TimeTree의 소셜 공유 기능을 결합하여, 집안일을 재미있는 퀘스트로 만들어 가족 구성원들이 즐겁게 참여할 수 있도록 설계되었습니다.

### 🎯 핵심 가치

- **정신적 노동 경감**: 집안일 계획, 분배, 감독의 인지적 부담 감소
- **기여도 가시화**: 객관적 포인트/레벨 시스템으로 공정성 확보
- **지속적 동기 부여**: 다층적 게임화로 반복적인 집안일에 재미 부여

### 🎮 핵심 컨셉

- **RPG 게임화**: 집안일 완료 시 XP 획득, 레벨업 시스템
- **가족 협력**: 가구(Household) 단위로 집안일 공유 및 관리
- **실시간 리더보드**: 가족 구성원 간 경쟁과 동기부여
- **직관적 UI/UX**: 캘린더 통합, 애니메이션, 사용자 친화적 인터페이스

## 🚀 주요 기능

### 1. 사용자 관리 (Authentication)
- ✅ 로컬 사용자 등록 및 로그인
- ✅ 사용자 프로필 관리
- ✅ 이메일 기반 인증

### 2. 가구(Household) 관리
- ✅ 가구 생성 및 설정
- ✅ 가구 멤버 초대 및 관리
- ✅ 가구별 데이터 격리

### 3. 집안일(Chore) 시스템
- ✅ 집안일 CRUD (생성, 조회, 수정, 삭제)
- ✅ 난이도 설정 (쉬움/보통/어려움)
- ✅ 마감일 및 시간 설정
- ✅ 집안일 상태 관리 (진행중/완료/지연)
- ✅ 캘린더 통합 뷰

### 4. XP & 레벨 시스템
- ✅ 집안일 완료 시 XP 획득
  - 쉬움: +10 XP
  - 보통: +25 XP
  - 어려움: +50 XP
- ✅ 경험치 기반 레벨업 (Habitica 스타일)
- ✅ 레벨 진행률 시각화

### 5. 리더보드
- ✅ 가구 내 실시간 순위 표시
- ✅ Top 3 Podium 애니메이션
- ✅ XP 및 레벨 기반 랭킹

### 6. 대시보드
- ✅ 캘린더 뷰 (주간/월간)
- ✅ 오늘의 집안일 요약
- ✅ XP 진행률 카드
- ✅ 통계 위젯

### 7. UI/UX 마이크로 인터랙션
- ✅ 집안일 완료 애니메이션
- ✅ XP 획득 SnackBar
- ✅ 부드러운 페이드인/슬라이드 효과
- ✅ Material Design 3 적용

## 🏗️ 아키텍처

### 데이터 모델

```dart
// 사용자 모델
UserModel {
  - id: String
  - name: String
  - email: String
  - householdId: String?
  - xp: int
  - level: int
  + gainXp(amount): void
  + getLevelProgress(): double
}

// 가구 모델
HouseholdModel {
  - id: String
  - name: String
  - memberIds: List<String>
  - creatorId: String
  + addMember(userId): void
  + removeMember(userId): void
}

// 집안일 모델
ChoreModel {
  - id: String
  - title: String
  - difficulty: ChoreDifficulty
  - status: ChoreStatus
  - dueDate: DateTime
  + complete(userId): void
  + getXpReward(): int
}
```

### 상태 관리 (Provider)

```
AuthProvider - 사용자 인증 및 세션 관리
HouseholdProvider - 가구 데이터 및 멤버 관리
ChoreProvider - 집안일 CRUD 및 필터링
```

### 데이터베이스 (Hive)

```
Local Storage with Hive NoSQL
- users: Box<UserModel>
- households: Box<HouseholdModel>
- chores: Box<ChoreModel>
- settings: Box<dynamic>
```

## 📱 화면 구성

### 1. 인증 화면
- **로그인 화면**: 이메일 기반 로그인
- **회원가입 화면**: 이름, 이메일 입력
- **스플래시 화면**: 앱 초기 로딩

### 2. 홈 화면 (TabBar Navigation)
- **대시보드 탭**: 캘린더 + XP 진행률 + 오늘의 집안일
- **집안일 탭**: 진행중/완료/지연 집안일 목록
- **리더보드 탭**: 가족 순위 및 XP 랭킹
- **프로필 탭**: 사용자 정보 및 통계

### 3. 기능 화면
- **가구 생성 화면**: 가구 이름 및 설명 입력
- **집안일 추가 화면**: 제목, 난이도, 마감일 설정

## 🎨 UI/UX 디자인 원칙

### Material Design 3
- **다크 모드 지원**: 시스템 설정 자동 감지
- **컬러 스킴**: Seed color 기반 동적 색상
- **카드 레이아웃**: 12px 모서리 둥글림, 2px 그림자

### 애니메이션
```dart
flutter_animate 패키지 사용
- fadeIn(): 부드러운 페이드인
- slideX/slideY(): 슬라이드 효과
- scale(): 크기 변환
- delay(): 순차 애니메이션
```

### 컬러 코딩
- **쉬움**: 초록색 (Green)
- **보통**: 주황색 (Orange)
- **어려움**: 빨간색 (Red)
- **완료**: 초록색 체크
- **지연**: 빨간색 경고

## 🛠️ 기술 스택

### Frontend
- **Flutter**: 3.35.4
- **Dart**: 3.9.2
- **State Management**: Provider 6.1.5+1

### 데이터베이스
- **Hive**: 2.2.3 (NoSQL 로컬 DB)
- **Hive Flutter**: 1.1.0

### UI 라이브러리
- **table_calendar**: ^3.0.9 (캘린더 위젯)
- **flutter_animate**: ^4.5.0 (애니메이션)
- **intl**: ^0.19.0 (날짜/시간 포맷팅)

### 개발 도구
- **build_runner**: ^2.4.9 (코드 생성)
- **hive_generator**: ^2.0.1 (TypeAdapter 생성)

## 📂 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── user_model.dart
│   ├── household_model.dart
│   └── chore_model.dart
├── providers/                # 상태 관리
│   ├── auth_provider.dart
│   ├── household_provider.dart
│   └── chore_provider.dart
├── services/                 # 비즈니스 로직
│   └── database_service.dart
├── screens/                  # UI 화면
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── dashboard_tab.dart
│   │   ├── chores_tab.dart
│   │   ├── leaderboard_tab.dart
│   │   └── profile_tab.dart
│   ├── household/
│   │   └── create_household_screen.dart
│   └── chore/
│       └── add_chore_screen.dart
└── widgets/                  # 재사용 위젯
    ├── xp_progress_card.dart
    └── chore_list_tile.dart
```

## 🚦 시작하기

### 필수 조건
- Flutter SDK 3.35.4
- Dart SDK 3.9.2

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Hive TypeAdapters)
dart run build_runner build --delete-conflicting-outputs

# 웹 빌드
flutter build web --release

# 로컬 서버 실행
cd build/web
python3 -m http.server 5060
```

### 개발 모드 실행

```bash
# Flutter 웹 개발 서버
flutter run -d chrome

# 또는 릴리스 모드
flutter build web --release
```

## 🧪 테스팅

### 단위 테스트
```bash
flutter test
```

### E2E 테스트 시나리오

1. **회원가입 → 로그인 플로우**
   - 회원가입 화면에서 이름/이메일 입력
   - 로그인 화면에서 이메일로 로그인
   - 홈 화면 진입 확인

2. **가구 생성 → 집안일 추가 플로우**
   - 가구 생성 화면에서 가구 정보 입력
   - 집안일 추가 화면에서 집안일 생성
   - 대시보드에 집안일 표시 확인

3. **집안일 완료 → XP 획득 플로우**
   - 집안일 목록에서 완료 버튼 클릭
   - XP 획득 SnackBar 표시 확인
   - 프로필 탭에서 XP/레벨 업데이트 확인
   - 리더보드에서 순위 변동 확인

## 🔮 향후 개발 계획

### Phase 2: Firebase 통합
- [ ] Firebase Authentication
- [ ] Cloud Firestore 실시간 동기화
- [ ] Firebase Cloud Messaging (푸시 알림)

### Phase 3: 추가 기능
- [ ] 집안일 반복 패턴 (매일, 매주, 매월)
- [ ] 가구 초대 코드 시스템
- [ ] 집안일 히스토리 및 통계
- [ ] 뱃지 및 업적 시스템
- [ ] 다크/라이트 테마 전환 버튼

### Phase 4: 소셜 기능
- [ ] 가구 내 채팅
- [ ] 집안일 댓글 및 사진 첨부
- [ ] 친구 가구 방문 및 비교

## 📚 프로젝트 문서

ChoreQuest는 체계적인 문서화로 개발과 협업을 지원합니다.

### 비즈니스 문서
- **[Summary.md](./Summary.md)** - 시장 분석 및 비즈니스 전략 보고서
- **[PRD.md](./PRD.md)** - 제품 요구사항 정의서 (Product Requirements Document)
- **[DOMAIN_STRATEGY.md](./DOMAIN_STRATEGY.md)** - 도메인명, 브랜딩, 마케팅 전략

### 기술 문서
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - 기술 아키텍처 설계 (Phase 2 Firebase)
- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Firebase Firestore 데이터베이스 스키마
- **[TECHNICAL_DOCUMENTATION.md](./TECHNICAL_DOCUMENTATION.md)** - MVP 기술 문서 (Phase 1 Hive)
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - 개발자 가이드 및 코딩 컨벤션

### AI 지원
- **[CLAUDE.md](./CLAUDE.md)** - AI 어시스턴트 컨텍스트 문서

### 개발 진행 상황
- **[PHASE2_PROGRESS.md](./PHASE2_PROGRESS.md)** ⭐ **Phase 2 작업 진행 상황 및 다음 단계**
- **[WORKLOG.md](./WORKLOG.md)** - 일자별 작업 로그

### 문서 활용 가이드

| 알고 싶은 내용 | 참고 문서 |
|---------------|----------|
| 왜 이 기능이 필요한가? | Summary.md, PRD.md |
| 무엇을 개발해야 하나? | PRD.md |
| 어떻게 구현하나? | ARCHITECTURE.md, TECHNICAL_DOCUMENTATION.md |
| 데이터 구조는? | DATABASE_SCHEMA.md |
| 개발 환경 설정은? | DEVELOPMENT_GUIDE.md |
| 도메인/브랜딩 전략은? | DOMAIN_STRATEGY.md |
| **Phase 2 작업 진행 상황은?** | **PHASE2_PROGRESS.md** ⭐ |
| 일자별 작업 내역은? | WORKLOG.md |

## 📄 라이선스

이 프로젝트는 MIT 라이선스로 배포됩니다.

## 👥 기여

프로젝트에 기여하고 싶으시다면:
1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**기여 전 필독**:
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - 코딩 스타일, Git 워크플로우
- [PRD.md](./PRD.md) - 기능 우선순위 확인

## 📞 문의

프로젝트 관련 문의사항은 이슈를 통해 남겨주세요.

### 팀 연락처 (Phase 2 이후)
- 이메일: team@chorequest.app
- 카카오톡 채널: 홈챌린저

---

<div align="center">
  <strong>ChoreQuest</strong> - Making Chores Fun!<br>
  Made with ❤️ using Flutter
</div>
