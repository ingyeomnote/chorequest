# ChoreQuest - 개발 작업 로그

## 📅 2025-11-03 (일요일)

### Phase 2 Firebase 마이그레이션 시작

#### ✅ 완료된 작업

**1. 프로젝트 문서화 완료**
- [x] PRD.md - 제품 요구사항 정의서 작성
- [x] ARCHITECTURE.md - Firebase 기반 아키텍처 설계 문서 작성
- [x] DATABASE_SCHEMA.md - Firestore 스키마 상세 설계
- [x] DOMAIN_STRATEGY.md - 도메인명 및 브랜딩 전략 수립
- [x] DEVELOPMENT_GUIDE.md - 개발자 온보딩 가이드 작성
- [x] CLAUDE.md - AI 어시스턴트 컨텍스트 문서 작성
- [x] README.md 업데이트 - 문서 링크 및 구조 개선

**2. Firebase 기반 인프라 구축**
- [x] Firebase 패키지 의존성 추가 (pubspec.yaml)
  - firebase_core, firebase_auth, cloud_firestore
  - firebase_storage, firebase_analytics
  - google_sign_in, connectivity_plus
- [x] 환경 설정 시스템 구현
  - `lib/config/environment.dart` - 환경별(dev/staging/prod) 설정
  - `lib/config/firebase_config.dart` - Firebase 초기화 및 Emulator 설정
- [x] 로깅 시스템 구현
  - `lib/utils/logger.dart` - 개발용 로거 (debugPrint 기반)

**3. Firebase Emulator 설정**
- [x] `firebase.json` - Firebase 프로젝트 설정 (Emulator 포트 포함)
- [x] `firestore.rules` - Firestore 보안 규칙 구현
  - 사용자별 접근 제어
  - 가구 멤버 권한 체크
  - Collection별 보안 규칙 정의
- [x] `firestore.indexes.json` - 복합 인덱스 정의
  - 집안일 쿼리 최적화 인덱스
  - 리더보드 쿼리 인덱스
- [x] `storage.rules` - Firebase Storage 보안 규칙

**4. 핵심 서비스 구현**
- [x] `lib/services/firebase_auth_service.dart` - 인증 서비스
  - 이메일/비밀번호 로그인/가입
  - Google Sign-In 연동
  - 비밀번호 재설정
  - 한국어 에러 메시지 처리
- [x] `lib/services/firestore_service.dart` - Firestore 서비스
  - 기본 CRUD 작업
  - 실시간 리스너 (watchDocument, watchCollection)
  - 트랜잭션 및 배치 작업
  - 쿼리 빌더 헬퍼 메서드

**5. Repository 패턴 및 데이터 모델 업데이트**
- [x] `lib/models/user_model.dart` - Firestore 호환 업데이트
  - Phase 2 필드 추가 (achievements, currentStreak, longestStreak, lastLoginAt, lastActivityAt)
  - `toFirestore()` 메서드 추가 (Timestamp 변환)
  - `fromFirestore()` 및 `fromFirestoreMap()` 팩토리 메서드 추가
  - 기존 Hive 호환성 유지 (toMap/fromMap)
- [x] `lib/repositories/user_repository.dart` - 사용자 Repository 구현
  - Cache-first 읽기 전략 (Hive 캐시 우선, Firestore 조회)
  - CRUD 작업 (createUser, getUser, updateUser, deleteUser)
  - 실시간 감시 (watchUser, watchUsersByHousehold, watchLeaderboard)
  - XP 증가 원자적 작업 (incrementXp with transaction)
  - 리더보드 쿼리 (XP 기준 정렬)
- [x] Hive TypeAdapter 재생성 (build_runner)

#### 📋 다음 작업 예정

**Phase 2 Sprint 1 계속 (예상 1-2주)**
- [x] HouseholdModel Firestore 호환 업데이트
- [x] HouseholdRepository 구현
- [x] ChoreModel Firestore 호환 업데이트
- [x] ChoreRepository 구현
- [ ] Provider 업데이트 (Firebase 연동)
  - AuthProvider → FirebaseAuthService + UserRepository 사용
  - HouseholdProvider → HouseholdRepository 패턴 적용
  - ChoreProvider → 실시간 스트림 연결

#### 💡 메모
- Firebase Emulator를 사용하여 로컬 개발 가능 (Firebase 프로젝트 생성 전)
- Emulator 포트: Firestore(8080), Auth(9099), Storage(9199), UI(4000)
- 보안 규칙은 DATABASE_SCHEMA.md의 설계를 따름

---

## 📅 2025-11-04 (월요일)

### Phase 2 Firebase 마이그레이션 계속 - Repository 패턴 완성

#### ✅ 완료된 작업

**1. HouseholdModel Firestore 호환 업데이트**
- [x] Phase 2 필드 추가
  - `@HiveField(7) String? avatarUrl` - 가구 프로필 이미지
  - `@HiveField(8) int memberCount` - 멤버 수 (자동 계산)
  - `@HiveField(9) List<String> adminIds` - 관리자 ID 목록
- [x] 생성자 업데이트
  - 새 필드 초기화 로직 추가
  - memberCount는 memberIds 길이로 자동 계산
  - adminIds는 기본적으로 creatorId로 초기화
- [x] Firestore 직렬화 메서드 추가
  - `toFirestore()` - Timestamp 변환 포함
  - `fromFirestore()` - DocumentSnapshot에서 생성
  - `fromFirestoreMap()` - Map에서 직접 생성
- [x] Hive 호환성 유지
  - `toMap()` / `fromMap()` 업데이트 (새 필드 포함)
- [x] Hive TypeAdapter 재생성 (build_runner)

**2. HouseholdRepository 구현**
- [x] `lib/repositories/household_repository.dart` - 가구 Repository 구현
  - Cache-first 읽기 전략
  - **CREATE**: createHousehold()
  - **READ**:
    - getHousehold() - 단일 가구 조회 (캐시 우선)
    - getHouseholdsForUser() - 사용자가 속한 모든 가구 조회
  - **UPDATE**:
    - updateHousehold() - 가구 정보 업데이트
    - addMember() - 멤버 추가 (트랜잭션)
    - removeMember() - 멤버 제거 (트랜잭션)
  - **DELETE**: deleteHousehold()
  - **실시간**:
    - watchHousehold() - 단일 가구 실시간 감시
    - watchHouseholdsForUser() - 사용자 가구 목록 실시간 감시
  - **캐시 관리**: getFromCache(), clearCache(), refreshHousehold()

**3. ChoreModel Firestore 호환 업데이트**
- [x] Firestore 직렬화 메서드 추가
  - `toFirestore()` - Timestamp 변환, enum은 `.name`으로 저장
  - `fromFirestore()` - DocumentSnapshot에서 생성
  - `fromFirestoreMap()` - Map에서 직접 생성
- [x] Enum 직렬화 방식 개선
  - 기존 `toString()` → Firestore에서는 `.name` 사용
  - 'ChoreDifficulty.easy' → 'easy' (더 간결)
- [x] Hive TypeAdapter 재생성 (build_runner)

**4. ChoreRepository 구현**
- [x] `lib/repositories/chore_repository.dart` - 집안일 Repository 구현
  - Cache-first 읽기 전략
  - **CREATE**: createChore()
  - **READ**:
    - getChore() - 단일 집안일 조회 (캐시 우선)
    - getChoresByHousehold() - 가구별 전체 집안일 조회
    - getPendingChores() - 대기 중인 집안일만 조회
    - getChoresByUser() - 사용자에게 할당된 집안일 조회
    - getChoresDueToday() - 오늘 마감인 집안일 조회
  - **UPDATE**:
    - updateChore() - 집안일 정보 업데이트
    - completeChore() - 집안일 완료 (트랜잭션)
    - assignChore() - 집안일 할당
  - **DELETE**: deleteChore()
  - **실시간**:
    - watchChore() - 단일 집안일 실시간 감시
    - watchChoresByHousehold() - 가구별 집안일 목록 실시간 감시
    - watchPendingChores() - 대기 중인 집안일 실시간 감시
    - watchChoresByUser() - 사용자 할당 집안일 실시간 감시
  - **캐시 관리**: getFromCache(), clearCache(), refreshChore()

#### 📋 다음 작업 예정

**Phase 2 Sprint 1 계속**
- [ ] Provider 업데이트 (Firebase 연동)
  - [ ] AuthProvider → FirebaseAuthService + UserRepository 통합
  - [ ] HouseholdProvider → HouseholdRepository 패턴 적용
  - [ ] ChoreProvider → ChoreRepository + 실시간 스트림 연결
- [ ] 기존 UI 화면과 Repository 연결 테스트
- [ ] Firebase Emulator 테스트

#### 💡 메모

**Repository 패턴 설계 원칙**
- Cache-first: 읽기 시 Hive 캐시 우선 조회, 없으면 Firestore 조회
- Write-through: 쓰기 시 Firestore 먼저 저장, 그 다음 캐시 업데이트
- Real-time sync: Firestore listeners가 캐시 자동 업데이트
- Atomic operations: 트랜잭션 사용 (멤버 추가/제거, 집안일 완료 등)

**Enum 직렬화 방식**
- Hive: `toString()` 사용 (기존 호환성)
- Firestore: `.name` 사용 (더 간결, Firestore 친화적)

**다음 단계 고려사항**
- Provider 클래스들이 Repository를 사용하도록 리팩토링 필요
- 기존 DatabaseService는 점진적으로 제거 (Repository로 대체)
- Firebase Emulator로 로컬 테스트 후 실제 Firebase 프로젝트 연결

---

## 템플릿 (다음 날짜 작업 시 복사)

```markdown
## 📅 YYYY-MM-DD (요일)

### [작업 주제]

#### ✅ 완료된 작업
- [x] 작업 항목 1
- [x] 작업 항목 2

#### 📋 다음 작업 예정
- [ ] 예정 작업 1
- [ ] 예정 작업 2

#### 💡 메모
- 중요한 결정 사항이나 메모

---
```
