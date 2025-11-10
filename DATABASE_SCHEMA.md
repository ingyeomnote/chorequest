# ChoreQuest - Database Schema (Firebase Firestore)

## 📄 문서 정보

- **버전**: 2.0
- **작성일**: 2025-11-03
- **최종 업데이트**: 2025-11-04
- **데이터베이스**: Cloud Firestore
- **마이그레이션 대상**: Hive (Phase 1) → Firestore (Phase 2)

## 🚀 구현 상태

### Phase 2 마이그레이션 진행 상황

- ✅ **Repository 패턴**: UserRepository, HouseholdRepository, ChoreRepository 완료
- ✅ **Provider 통합**: AuthProvider, HouseholdProvider 완료 (Step 1-3)
- ✅ **실시간 동기화**: Firestore listeners를 통한 실시간 데이터 동기화 구현
- ✅ **캐시 전략**: Hive를 사용한 로컬 캐시 (cache-first read, write-through)
- ⏳ **ChoreProvider**: 다음 작업 (Step 4)

### 지원되는 기능

- ✅ 사용자 인증 (Firebase Auth + Firestore)
- ✅ 가구 관리 (생성, 멤버 추가/제거, 실시간 동기화)
- ✅ XP/레벨 시스템 (트랜잭션 기반)
- ✅ 리더보드 (실시간 스트림)
- ⏳ 집안일 관리 (Step 4에서 통합 예정)

---

## 1. 스키마 개요

### 1.1 설계 원칙

1. **정규화보다 비정규화**: Firestore의 NoSQL 특성을 고려한 데이터 중복 허용
2. **쿼리 최적화 우선**: 읽기 속도를 위해 중첩 컬렉션과 참조 분리
3. **실시간 동기화 고려**: 변경 감지가 필요한 데이터는 별도 문서로 분리
4. **비용 효율**: 불필요한 읽기/쓰기 최소화
5. **확장성**: 샤딩 및 파티셔닝 가능한 구조

### 1.2 Top-Level Collections

```
firestore/
├── users/                  # 사용자 정보
├── households/             # 가구 정보
├── chores/                 # 집안일
├── templates/              # 집안일 템플릿 (한국형)
├── invites/                # 초대 코드 (Phase 2)
├── subscriptions/          # 구독 정보 (Phase 2)
└── analytics/              # 통계 데이터 (Phase 3)
```

---

## 2. Collection 상세 스키마

### 2.1 users Collection

#### Document Structure

```typescript
/users/{userId}

{
  // 기본 정보
  id: string,                    // Firebase Auth UID
  name: string,                  // 사용자 이름
  email: string,                 // 이메일
  avatarUrl?: string,            // 프로필 이미지 URL (Firebase Storage)

  // 가구 정보
  householdId?: string,          // 소속 가구 ID (외래키)

  // 게임화 데이터
  xp: number,                    // 경험치 (default: 0)
  level: number,                 // 레벨 (default: 1)
  achievements: string[],        // 획득한 업적 ID 배열 (Phase 2)
  currentStreak: number,         // 연속 달성 일수 (Phase 2)
  longestStreak: number,         // 최장 연속 달성 (Phase 2)

  // 개인화 설정
  settings: {
    theme: 'light' | 'dark' | 'system',
    notifications: {
      choreReminders: boolean,    // 집안일 알림
      levelUp: boolean,           // 레벨업 알림
      leaderboard: boolean,       // 리더보드 변동 알림
      kakaoIntegration: boolean,  // 카카오톡 연동 (Phase 2)
    },
    language: 'ko' | 'en',       // 언어 설정
  },

  // 구독 정보 (Phase 2)
  subscription?: {
    plan: 'free' | 'monthly' | 'yearly',
    status: 'active' | 'inactive' | 'cancelled',
    startedAt: Timestamp,
    expiresAt: Timestamp,
  },

  // 메타데이터
  createdAt: Timestamp,
  lastLoginAt: Timestamp,
  lastActivityAt: Timestamp,     // 마지막 집안일 완료 시간
}
```

#### Subcollections

```typescript
// 통계 데이터 (Phase 3)
/users/{userId}/stats/{statId}
{
  date: Timestamp,               // 날짜 (YYYY-MM-DD)
  choresCompleted: number,       // 완료한 집안일 수
  xpGained: number,              // 획득한 XP
  rank: number,                  // 가구 내 순위
}
```

#### Indexes

```javascript
// Composite Index
users
  .where('householdId', '==', householdId)
  .orderBy('xp', 'desc')  // 리더보드 쿼리
```

#### 예시 데이터

```json
{
  "id": "user_abc123",
  "name": "김지혜",
  "email": "jihye@example.com",
  "avatarUrl": "https://storage.googleapis.com/chorequest/avatars/user_abc123.jpg",
  "householdId": "household_xyz789",
  "xp": 1250,
  "level": 8,
  "achievements": ["first_chore", "week_streak_7", "lvl_10"],
  "currentStreak": 5,
  "longestStreak": 14,
  "settings": {
    "theme": "system",
    "notifications": {
      "choreReminders": true,
      "levelUp": true,
      "leaderboard": false,
      "kakaoIntegration": true
    },
    "language": "ko"
  },
  "subscription": {
    "plan": "yearly",
    "status": "active",
    "startedAt": "2025-01-01T00:00:00Z",
    "expiresAt": "2026-01-01T00:00:00Z"
  },
  "createdAt": "2024-11-01T10:30:00Z",
  "lastLoginAt": "2025-11-03T08:45:00Z",
  "lastActivityAt": "2025-11-03T09:15:00Z"
}
```

---

### 2.2 households Collection

#### Document Structure

```typescript
/households/{householdId}

{
  // 기본 정보
  id: string,                    // 가구 ID (UUID)
  name: string,                  // 가구 이름 (예: "김씨네 가족")
  description?: string,          // 설명 (선택)
  avatarUrl?: string,            // 가구 대표 이미지 (Phase 2)

  // 멤버 관리
  creatorId: string,             // 생성자 User ID
  memberIds: string[],           // 멤버 User ID 배열
  memberCount: number,           // 멤버 수 (쿼리 최적화용 중복 저장)
  adminIds: string[],            // 관리자 권한 User ID 배열 (Phase 2)

  // 게임화 설정
  familyGoal?: {                 // 가족 협력 목표 (Phase 2)
    targetXp: number,            // 목표 XP
    currentXp: number,           // 현재 XP
    startDate: Timestamp,
    endDate: Timestamp,
    reward: string,              // 보상 설명 (예: "영화 보러 가기")
    completed: boolean,
  },

  // 관리자 역할 순환 (Phase 2)
  managerRotation?: {
    enabled: boolean,
    currentManagerId: string,    // 현재 주 관리자
    rotationDay: number,         // 0~6 (일~토)
    nextRotationDate: Timestamp,
  },

  // 메타데이터
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```

#### Subcollections

```typescript
// 초대 코드 (Phase 2)
/households/{householdId}/invites/{inviteCode}
{
  code: string,                  // 6자리 초대 코드
  createdBy: string,             // 생성자 User ID
  createdAt: Timestamp,
  expiresAt: Timestamp,          // 만료일 (생성 후 7일)
  used: boolean,                 // 사용 여부
  usedBy?: string,               // 사용자 User ID
  usedAt?: Timestamp,
}
```

#### Indexes

```javascript
// memberIds 배열 쿼리
households
  .where('memberIds', 'array-contains', userId)

// 멤버 수 기반 프리미엄 전환 체크
households
  .where('memberCount', '>', 3)
```

#### 예시 데이터

```json
{
  "id": "household_xyz789",
  "name": "김씨네 가족",
  "description": "우리 집 집안일 함께 해요!",
  "avatarUrl": "https://storage.googleapis.com/chorequest/households/xyz789.jpg",
  "creatorId": "user_abc123",
  "memberIds": ["user_abc123", "user_def456", "user_ghi789"],
  "memberCount": 3,
  "adminIds": ["user_abc123"],
  "familyGoal": {
    "targetXp": 500,
    "currentXp": 350,
    "startDate": "2025-11-01T00:00:00Z",
    "endDate": "2025-11-07T23:59:59Z",
    "reward": "주말 영화 보러 가기",
    "completed": false
  },
  "managerRotation": {
    "enabled": true,
    "currentManagerId": "user_abc123",
    "rotationDay": 0,
    "nextRotationDate": "2025-11-10T00:00:00Z"
  },
  "createdAt": "2024-11-01T10:30:00Z",
  "updatedAt": "2025-11-03T09:15:00Z"
}
```

---

### 2.3 chores Collection

#### Document Structure

```typescript
/chores/{choreId}

{
  // 기본 정보
  id: string,                    // 집안일 ID (UUID)
  title: string,                 // 제목 (예: "설거지")
  description?: string,          // 상세 설명 (선택)
  category?: string,             // 카테고리 (예: "주방", "거실") (Phase 2)

  // 가구 정보
  householdId: string,           // 소속 가구 ID (외래키, 필수)

  // 난이도 및 보상
  difficulty: 'easy' | 'medium' | 'hard',  // 난이도
  xpReward: number,              // XP 보상 (easy: 10, medium: 25, hard: 50)

  // 할당 정보
  assignedTo?: string,           // 담당자 User ID (null이면 자유 업무)
  assignedBy?: string,           // 할당한 User ID

  // 일정 정보
  dueDate: Timestamp,            // 마감일
  dueTime?: string,              // 마감 시간 (HH:mm 형식)

  // 반복 설정 (Phase 2)
  recurring?: {
    enabled: boolean,
    pattern: 'daily' | 'weekly' | 'biweekly' | 'monthly' | 'custom',
    interval: number,            // 간격 (예: 2 = 2일마다)
    daysOfWeek?: number[],       // 요일 (0~6, 일~토)
    endDate?: Timestamp,         // 반복 종료일
    rotation?: {                 // 담당자 순환
      enabled: boolean,
      memberIds: string[],       // 순환할 멤버 ID 배열
      currentIndex: number,
    },
  },

  // 상태 관리
  status: 'pending' | 'in_progress' | 'completed' | 'overdue',
  completedAt?: Timestamp,
  completedBy?: string,          // 완료한 User ID

  // 첨부 파일 (Phase 3)
  attachments?: {
    url: string,
    type: 'image' | 'file',
    name: string,
  }[],

  // 댓글 (Phase 4)
  commentCount: number,          // 댓글 수 (중복 저장)

  // 메타데이터
  createdAt: Timestamp,
  createdBy: string,             // 생성자 User ID
  updatedAt: Timestamp,
}
```

#### Indexes

```javascript
// 가구별 집안일 조회 (메인 쿼리)
chores
  .where('householdId', '==', householdId)
  .where('status', '==', 'pending')
  .orderBy('dueDate', 'asc')

// 사용자별 집안일 조회
chores
  .where('assignedTo', '==', userId)
  .where('status', 'in', ['pending', 'in_progress'])
  .orderBy('dueDate', 'asc')

// 마감일 지난 집안일 (Cloud Function용)
chores
  .where('status', '==', 'pending')
  .where('dueDate', '<', now)

// 날짜 범위 쿼리 (캘린더 뷰)
chores
  .where('householdId', '==', householdId)
  .where('dueDate', '>=', startDate)
  .where('dueDate', '<=', endDate)
  .orderBy('dueDate')
```

#### 예시 데이터

```json
{
  "id": "chore_111",
  "title": "설거지",
  "description": "저녁 식사 후 설거지",
  "category": "주방",
  "householdId": "household_xyz789",
  "difficulty": "easy",
  "xpReward": 10,
  "assignedTo": "user_def456",
  "assignedBy": "user_abc123",
  "dueDate": "2025-11-03T20:00:00Z",
  "dueTime": "20:00",
  "recurring": {
    "enabled": true,
    "pattern": "daily",
    "interval": 1,
    "rotation": {
      "enabled": true,
      "memberIds": ["user_abc123", "user_def456", "user_ghi789"],
      "currentIndex": 1
    }
  },
  "status": "completed",
  "completedAt": "2025-11-03T19:45:00Z",
  "completedBy": "user_def456",
  "attachments": [],
  "commentCount": 0,
  "createdAt": "2025-11-01T10:00:00Z",
  "createdBy": "user_abc123",
  "updatedAt": "2025-11-03T19:45:00Z"
}
```

---

### 2.4 templates Collection (한국형 집안일 템플릿)

#### Document Structure

```typescript
/templates/{templateId}

{
  // 기본 정보
  id: string,                    // 템플릿 ID
  name: string,                  // 템플릿 이름 (예: "신혼부부 2인 가구")
  description: string,           // 설명
  category: 'household_type' | 'seasonal' | 'event',

  // 타겟 가구 유형
  targetHouseholdSize: number,   // 권장 인원 수
  tags: string[],                // 태그 (예: ["신혼", "맞벌이"])

  // 템플릿 집안일 목록
  chores: {
    title: string,
    description: string,
    difficulty: 'easy' | 'medium' | 'hard',
    category: string,            // "주방", "거실", "화장실" 등
    recurring: {
      pattern: 'daily' | 'weekly' | 'biweekly' | 'monthly',
      daysOfWeek?: number[],
    },
  }[],

  // 메타데이터
  featured: boolean,             // 추천 템플릿 여부
  usageCount: number,            // 사용 횟수
  createdAt: Timestamp,
}
```

#### 예시 데이터 (신혼부부 템플릿)

```json
{
  "id": "template_newlywed_2p",
  "name": "신혼부부 2인 가구",
  "description": "맞벌이 신혼부부를 위한 기본 집안일 템플릿",
  "category": "household_type",
  "targetHouseholdSize": 2,
  "tags": ["신혼", "맞벌이", "2인"],
  "chores": [
    {
      "title": "설거지",
      "description": "식후 설거지 및 싱크대 정리",
      "difficulty": "easy",
      "category": "주방",
      "recurring": {
        "pattern": "daily"
      }
    },
    {
      "title": "음식물 쓰레기 버리기",
      "description": "음식물 쓰레기 배출",
      "difficulty": "easy",
      "category": "주방",
      "recurring": {
        "pattern": "daily"
      }
    },
    {
      "title": "분리수거",
      "description": "플라스틱, 종이, 유리 분리수거",
      "difficulty": "medium",
      "category": "현관",
      "recurring": {
        "pattern": "weekly",
        "daysOfWeek": [0, 3]
      }
    },
    {
      "title": "화장실 청소",
      "description": "변기, 세면대, 거울 닦기",
      "difficulty": "medium",
      "category": "화장실",
      "recurring": {
        "pattern": "weekly",
        "daysOfWeek": [6]
      }
    },
    {
      "title": "빨래",
      "description": "세탁 및 건조",
      "difficulty": "medium",
      "category": "베란다",
      "recurring": {
        "pattern": "weekly",
        "daysOfWeek": [0, 3]
      }
    },
    {
      "title": "김치냉장고 정리",
      "description": "유통기한 확인 및 정리",
      "difficulty": "easy",
      "category": "주방",
      "recurring": {
        "pattern": "monthly"
      }
    }
  ],
  "featured": true,
  "usageCount": 1547,
  "createdAt": "2024-10-01T00:00:00Z"
}
```

#### 예시 데이터 (명절 준비 템플릿)

```json
{
  "id": "template_chuseok",
  "name": "추석 대청소 체크리스트",
  "description": "명절 전 집 대청소를 위한 체크리스트",
  "category": "event",
  "targetHouseholdSize": 4,
  "tags": ["추석", "명절", "대청소"],
  "chores": [
    {
      "title": "베란다 환기 및 청소",
      "difficulty": "medium",
      "category": "베란다",
      "recurring": null
    },
    {
      "title": "냉장고 대청소",
      "difficulty": "hard",
      "category": "주방",
      "recurring": null
    },
    {
      "title": "현관 신발장 정리",
      "difficulty": "medium",
      "category": "현관",
      "recurring": null
    },
    {
      "title": "에어컨 필터 청소",
      "difficulty": "medium",
      "category": "거실",
      "recurring": null
    }
  ],
  "featured": true,
  "usageCount": 823,
  "createdAt": "2024-09-01T00:00:00Z"
}
```

---

### 2.5 invites Collection (초대 코드 - Phase 2)

```typescript
/invites/{inviteCode}

{
  code: string,                  // 6자리 초대 코드
  householdId: string,           // 가구 ID
  createdBy: string,             // 생성자 User ID
  createdAt: Timestamp,
  expiresAt: Timestamp,          // 만료일 (생성 후 7일)
  used: boolean,                 // 사용 여부
  usedBy?: string,               // 사용자 User ID
  usedAt?: Timestamp,
}
```

#### Indexes

```javascript
invites
  .where('code', '==', inviteCode)
  .where('used', '==', false)
  .where('expiresAt', '>', now)
```

---

### 2.6 subscriptions Collection (구독 관리 - Phase 2)

```typescript
/subscriptions/{subscriptionId}

{
  id: string,                    // 구독 ID
  userId: string,                // 사용자 ID
  plan: 'free' | 'monthly' | 'yearly',
  status: 'active' | 'inactive' | 'cancelled' | 'past_due',
  price: number,                 // 결제 금액 (KRW)

  // 결제 정보
  paymentMethod: 'card' | 'bank_transfer' | 'kakao_pay',
  paymentGateway: string,        // PG사 (예: "toss", "iamport")
  paymentId?: string,            // PG사 결제 ID

  // 기간
  startedAt: Timestamp,
  expiresAt: Timestamp,
  cancelledAt?: Timestamp,

  // 결제 이력
  billingHistory: {
    date: Timestamp,
    amount: number,
    status: 'success' | 'failed',
  }[],

  // 메타데이터
  createdAt: Timestamp,
  updatedAt: Timestamp,
}
```

---

## 3. 데이터 관계도 (ER Diagram)

```
┌─────────────────┐         ┌─────────────────┐
│     users       │ ◄─────┐ │   households    │
│                 │        │ │                 │
│ id (PK)         │        └─┤ memberIds[]     │
│ householdId (FK)├─────────►│ id (PK)         │
│ xp              │          │ creatorId (FK)  │
│ level           │          │ adminIds[]      │
└─────────────────┘          └─────────────────┘
        ▲                            │
        │                            │
        │                            ▼
        │                    ┌─────────────────┐
        │                    │   invites       │
        │                    │                 │
        │                    │ householdId (FK)│
        │                    │ createdBy (FK)  │
        │                    └─────────────────┘
        │
        │
┌───────┴──────────┐
│     chores       │
│                  │
│ id (PK)          │
│ householdId (FK) ├─────► households
│ assignedTo (FK)  ├─────► users
│ completedBy (FK) ├─────► users
│ createdBy (FK)   ├─────► users
└──────────────────┘

┌──────────────────┐
│   templates      │
│                  │
│ id (PK)          │
│ chores[]         │
└──────────────────┘

┌──────────────────┐
│  subscriptions   │
│                  │
│ id (PK)          │
│ userId (FK)      ├─────► users
└──────────────────┘
```

---

## 4. 쿼리 패턴 및 최적화

### 4.1 자주 사용되는 쿼리

#### 1) 대시보드: 오늘의 할 일 조회

```dart
FirebaseFirestore.instance
  .collection('chores')
  .where('householdId', isEqualTo: householdId)
  .where('status', whereIn: ['pending', 'in_progress'])
  .where('dueDate', isGreaterThanOrEqualTo: todayStart)
  .where('dueDate', isLessThan: todayEnd)
  .orderBy('dueDate')
  .get();

// 필요 Index:
// householdId ASC, status ASC, dueDate ASC
```

#### 2) 리더보드: 가구 멤버 순위

```dart
// 방법 1: users 컬렉션 직접 조회
FirebaseFirestore.instance
  .collection('users')
  .where('householdId', isEqualTo: householdId)
  .orderBy('xp', descending: true)
  .get();

// 필요 Index:
// householdId ASC, xp DESC
```

#### 3) 집안일 히스토리: 완료된 집안일 조회

```dart
FirebaseFirestore.instance
  .collection('chores')
  .where('householdId', isEqualTo: householdId)
  .where('status', isEqualTo: 'completed')
  .where('completedAt', isGreaterThanOrEqualTo: startDate)
  .orderBy('completedAt', descending: true)
  .limit(50)
  .get();

// 필요 Index:
// householdId ASC, status ASC, completedAt DESC
```

#### 4) 내 할 일: 나에게 할당된 집안일

```dart
FirebaseFirestore.instance
  .collection('chores')
  .where('assignedTo', isEqualTo: userId)
  .where('status', whereIn: ['pending', 'in_progress'])
  .orderBy('dueDate')
  .get();

// 필요 Index:
// assignedTo ASC, status ASC, dueDate ASC
```

### 4.2 복합 인덱스 목록

Firebase Console에서 자동으로 생성 안내되지만, 미리 정의:

```javascript
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "chores",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "householdId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "dueDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "chores",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "assignedTo", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "dueDate", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "chores",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "householdId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "householdId", "order": "ASCENDING" },
        { "fieldPath": "xp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### 4.3 쿼리 최적화 팁

#### 1) 데이터 비정규화

```dart
// ❌ 비효율적: 가구 멤버 조회 후 각각 User 정보 조회
final household = await getHousehold(householdId);
for (final memberId in household.memberIds) {
  final user = await getUser(memberId); // N+1 쿼리 문제
}

// ✅ 효율적: memberCount 중복 저장
final household = await getHousehold(householdId);
print('멤버 수: ${household.memberCount}'); // 추가 쿼리 불필요
```

#### 2) 배치 읽기 (Batch Get)

```dart
// ✅ 여러 문서를 한 번에 조회
final batch = FirebaseFirestore.instance.batch();
final userRefs = memberIds.map((id) =>
  FirebaseFirestore.instance.collection('users').doc(id)
).toList();

// 한 번의 네트워크 요청으로 여러 문서 조회
final users = await Future.wait(
  userRefs.map((ref) => ref.get())
);
```

#### 3) 리스너 최적화

```dart
// ✅ 특정 필드만 감시 (includeMetadataChanges: false)
FirebaseFirestore.instance
  .collection('chores')
  .where('householdId', isEqualTo: householdId)
  .snapshots(includeMetadataChanges: false) // 메타데이터 변경 무시
  .listen((snapshot) {
    // ...
  });
```

---

## 5. 보안 규칙 (Security Rules)

### 5.1 Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // === Helper Functions ===
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isMemberOf(householdId) {
      return isAuthenticated() &&
        request.auth.uid in get(/databases/$(database)/documents/households/$(householdId)).data.memberIds;
    }

    function isCreatorOf(householdId) {
      return isAuthenticated() &&
        request.auth.uid == get(/databases/$(database)/documents/households/$(householdId)).data.creatorId;
    }

    function isPremiumUser() {
      let user = get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
      return user.subscription.status == 'active';
    }

    // === Users Collection ===
    match /users/{userId} {
      // 본인 데이터만 읽기/쓰기
      allow read: if isAuthenticated() && isOwner(userId);
      allow create: if isAuthenticated() && isOwner(userId);
      allow update: if isAuthenticated() && isOwner(userId);
      allow delete: if false; // 사용자 삭제 불가 (Cloud Functions에서만)

      // 통계 서브컬렉션
      match /stats/{statId} {
        allow read: if isOwner(userId);
        allow write: if false; // Cloud Functions에서만 쓰기
      }
    }

    // === Households Collection ===
    match /households/{householdId} {
      // 멤버만 읽기
      allow read: if isMemberOf(householdId);

      // 인증된 사용자만 생성 가능
      allow create: if isAuthenticated();

      // 생성자만 수정/삭제
      allow update, delete: if isCreatorOf(householdId);

      // 초대 서브컬렉션
      match /invites/{inviteCode} {
        allow read: if isAuthenticated();
        allow create: if isCreatorOf(householdId);
        allow delete: if isCreatorOf(householdId);
      }
    }

    // === Chores Collection ===
    match /chores/{choreId} {
      // 가구 멤버만 읽기/쓰기
      allow read: if isMemberOf(resource.data.householdId);
      allow create: if isAuthenticated() &&
                      isMemberOf(request.resource.data.householdId);
      allow update: if isMemberOf(resource.data.householdId);
      allow delete: if isMemberOf(resource.data.householdId);
    }

    // === Templates Collection ===
    match /templates/{templateId} {
      // 모두 읽기 가능
      allow read: if isAuthenticated();
      // 쓰기는 Admin SDK에서만
      allow write: if false;
    }

    // === Invites Collection ===
    match /invites/{inviteCode} {
      // 모두 읽기 가능 (코드로 가구 찾기)
      allow read: if isAuthenticated();
      // 쓰기는 Cloud Functions에서만
      allow write: if false;
    }

    // === Subscriptions Collection ===
    match /subscriptions/{subscriptionId} {
      // 본인 구독 정보만 읽기
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      // 쓰기는 Cloud Functions에서만 (결제 처리)
      allow write: if false;
    }
  }
}
```

### 5.2 Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // 아바타 이미지
    match /avatars/{userId}/{fileName} {
      // 모두 읽기 가능
      allow read: if request.auth != null;

      // 본인만 업로드
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // 5MB 제한
                   && request.resource.contentType.matches('image/.*'); // 이미지만
    }

    // 집안일 첨부 파일
    match /chores/{choreId}/attachments/{fileName} {
      allow read, write: if request.auth != null;
      // TODO: 가구 멤버 권한 체크 (Firestore 참조 필요)
    }

    // 가구 대표 이미지
    match /households/{householdId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
      // TODO: 생성자 권한 체크
    }
  }
}
```

---

## 6. 마이그레이션 계획 (Hive → Firestore)

### 6.1 마이그레이션 전략

```dart
// lib/services/migration_service.dart
class MigrationService {
  final Box<UserModel> _usersBox;
  final Box<HouseholdModel> _householdsBox;
  final Box<ChoreModel> _choresBox;
  final FirestoreService _firestoreService;

  Future<void> migrateToFirestore(String userId) async {
    // 1. 사용자 데이터 마이그레이션
    final user = _usersBox.get(userId);
    if (user != null) {
      await _firestoreService.setDocument('users', userId, user.toJson());
    }

    // 2. 가구 데이터 마이그레이션
    if (user?.householdId != null) {
      final household = _householdsBox.get(user!.householdId);
      if (household != null) {
        await _firestoreService.setDocument(
          'households',
          household.id,
          household.toJson(),
        );
      }
    }

    // 3. 집안일 데이터 마이그레이션
    final chores = _choresBox.values
        .where((chore) => chore.householdId == user?.householdId)
        .toList();

    final batch = FirebaseFirestore.instance.batch();
    for (final chore in chores) {
      final ref = FirebaseFirestore.instance.collection('chores').doc(chore.id);
      batch.set(ref, chore.toJson());
    }
    await batch.commit();

    // 4. 로컬 캐시 유지 (오프라인 모드용)
    // Hive 데이터는 삭제하지 않음
  }
}
```

### 6.2 데이터 검증

```dart
Future<bool> validateMigration(String userId) async {
  // Hive와 Firestore 데이터 비교
  final hiveUser = _usersBox.get(userId);
  final firestoreUser = await _firestoreService.getDocument('users', userId);

  return hiveUser?.xp == firestoreUser?['xp'] &&
         hiveUser?.level == firestoreUser?['level'];
}
```

---

## 7. 비용 추정 및 최적화

### 7.1 Firestore 가격 (2025년 기준)

- **문서 읽기**: $0.06 / 100,000회
- **문서 쓰기**: $0.18 / 100,000회
- **문서 삭제**: $0.02 / 100,000회
- **저장소**: $0.18 / GB/월

### 7.2 비용 시뮬레이션 (10,000 MAU 가정)

```
일일 사용 패턴 (사용자당):
- 앱 실행 (대시보드 로드): 20 읽기
- 집안일 완료: 2 쓰기, 4 읽기
- 리더보드 조회: 5 읽기
- 총: 29 읽기, 2 쓰기

월간:
- 읽기: 10,000 users × 29 reads × 30 days = 8,700,000 reads
  → $5.22
- 쓰기: 10,000 users × 2 writes × 30 days = 600,000 writes
  → $1.08
- 저장소: 10,000 users × 10KB × 3 (user, household, chores) = 300MB
  → $0.05

**월 총 비용: ~$6.35**
```

### 7.3 비용 최적화 전략

#### 1) 캐싱

```dart
// Hive 로컬 캐시 적극 활용
// Firestore 읽기 전에 항상 캐시 먼저 확인
final cachedUser = _usersBox.get(userId);
if (cachedUser != null && !needsFreshData) {
  return cachedUser; // Firestore 읽기 비용 0
}
```

#### 2) 배치 쓰기

```dart
// ❌ 개별 쓰기 (N번의 쓰기 비용)
for (final chore in chores) {
  await FirebaseFirestore.instance.collection('chores').doc(chore.id).set(chore.toJson());
}

// ✅ 배치 쓰기 (1번의 쓰기 비용)
final batch = FirebaseFirestore.instance.batch();
for (final chore in chores) {
  batch.set(FirebaseFirestore.instance.collection('chores').doc(chore.id), chore.toJson());
}
await batch.commit();
```

#### 3) 불필요한 리스너 제거

```dart
// ❌ 화면 벗어나도 리스너 유지
StreamSubscription subscription = FirebaseFirestore.instance
  .collection('chores')
  .snapshots()
  .listen((snapshot) { /* ... */ });

// ✅ dispose에서 리스너 취소
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

---

## 8. 부록

### 8.1 Dart Model 클래스 예시

```dart
// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? householdId;
  final int xp;
  final int level;
  final List<String> achievements;
  final int currentStreak;
  final int longestStreak;
  final UserSettings settings;
  final Subscription? subscription;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime lastActivityAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.householdId,
    this.xp = 0,
    this.level = 1,
    this.achievements = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.settings,
    this.subscription,
    required this.createdAt,
    required this.lastLoginAt,
    required this.lastActivityAt,
  });

  // Firestore → Dart
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      householdId: data['householdId'],
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      achievements: List<String>.from(data['achievements'] ?? []),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      settings: UserSettings.fromJson(data['settings']),
      subscription: data['subscription'] != null
          ? Subscription.fromJson(data['subscription'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      lastActivityAt: (data['lastActivityAt'] as Timestamp).toDate(),
    );
  }

  // Dart → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'householdId': householdId,
      'xp': xp,
      'level': level,
      'achievements': achievements,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'settings': settings.toJson(),
      'subscription': subscription?.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  // XP 획득 및 레벨업 로직
  UserModel gainXp(int amount) {
    final newXp = xp + amount;
    int newLevel = level;

    while (newXp >= _getRequiredXpForLevel(newLevel + 1)) {
      newLevel++;
    }

    return copyWith(xp: newXp, level: newLevel);
  }

  static int _getRequiredXpForLevel(int targetLevel) {
    return (100 * pow(targetLevel, 1.5)).round();
  }

  UserModel copyWith({/* ... */}) {
    // ...
  }
}
```

### 8.2 Firebase 프로젝트 설정

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 프로젝트 초기화
firebase init

# Firestore, Functions, Hosting 선택
# - Firestore: 데이터베이스
# - Functions: Cloud Functions (TypeScript)
# - Hosting: Flutter Web 호스팅

# 배포
firebase deploy
```

---

<div align="center">
  <strong>ChoreQuest Database Schema</strong> v2.0<br>
  Firebase Firestore for Phase 2+
</div>
