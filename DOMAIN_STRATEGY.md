# ChoreQuest - 도메인명 및 브랜딩 전략

## 📄 문서 정보

- **버전**: 1.0
- **작성일**: 2025-11-03
- **목적**: 도메인명 선정, 브랜딩, 마케팅 전략 수립

---

## 1. 브랜드 네이밍 전략

### 1.1 글로벌명: ChoreQuest

**의미**:
- **Chore** (집안일) + **Quest** (모험, 퀘스트)
- RPG 게임의 퀘스트처럼 집안일을 재미있는 미션으로 만든다는 컨셉

**장점**:
- ✅ 직관적: 서비스 내용이 즉시 이해됨
- ✅ 기억하기 쉬움: 2단어 조합, 발음 용이
- ✅ SEO 친화적: "chore app", "quest gamification" 키워드 포함
- ✅ 글로벌 확장 가능: 영어권에서 자연스러움
- ✅ 차별화: 게임화 컨셉을 이름에 반영

**단점**:
- ⚠️ 경쟁사와 유사 가능성 (ChoreMonster, ChoreBuster 등 존재)
- ⚠️ .com 도메인 이미 등록되어 있을 가능성

### 1.2 한국명: 홈챌린저 (HomeChallenger)

**의미**:
- **Home** (가정) + **Challenger** (도전자)
- 집안일에 도전하는 사람들이라는 긍정적 의미

**장점**:
- ✅ 한국어 발음 자연스러움
- ✅ Summary.md의 비즈니스 분석 문서에서 이미 사용 중
- ✅ 도전, 성취라는 긍정적 이미지

**대안 검토**:
- **집퀘** (짧고 귀여운 애칭)
- **홈퀘스트** (ChoreQuest 직역)
- **가사왕** (게임화 느낌 강조)

**최종 선택**: **홈챌린저** (공식 한국명)
- 이유: Summary.md 문서와 일관성 유지

---

## 2. 도메인명 전략

### 2.1 우선순위 도메인 목록

#### Tier 1: 최우선 도메인
```
1. chorequest.app          (추천, .app은 앱 전용 TLD)
2. chorequest.io           (테크 스타트업 이미지)
3. home-challenger.com     (한국명 영문)
4. homechallenger.app
```

#### Tier 2: 대안 도메인
```
5. chorequest.co
6. chorequest.kr           (한국 시장 특화)
7. getchorequest.com       (get + 서비스명)
8. joinchor equest.com     (join + 서비스명)
```

#### Tier 3: 창의적 대안
```
9. chorehq.io              (HQ = Headquarters)
10. questfor.home
11. mychorequest.com
```

### 2.2 도메인 검증 체크리스트

```bash
# 도메인 가용성 확인
whois chorequest.app
whois chorequest.io
whois home-challenger.com

# 추천 도메인 등록 대행사
- Namecheap: https://www.namecheap.com
- GoDaddy: https://www.godaddy.com
- Google Domains: https://domains.google

# 가격대 (연간)
.com: $10-15
.app: $15-20 (HTTPS 필수)
.io: $30-50
.kr: ₩15,000-20,000
```

### 2.3 최종 추천

**주 도메인**: `chorequest.app`
- 이유:
  - 모바일 앱 전용 TLD
  - 기억하기 쉬움
  - Firebase Hosting + Custom Domain 연동 용이

**보조 도메인**: `homechallenger.kr`
- 이유:
  - 한국 시장 현지화
  - 카카오톡 공유 시 신뢰도 향상
  - 리다이렉트: homechallenger.kr → chorequest.app

---

## 3. 브랜딩 아이덴티티

### 3.1 로고 컨셉

#### 주 로고 아이디어
```
Option 1: 방패 + 빗자루
- 방패: 퀘스트, 도전, RPG 느낌
- 빗자루: 집안일

Option 2: 체크리스트 + 검
- 체크리스트: 할 일 관리
- 검: 게임 요소

Option 3: 집 + 별
- 집: Home
- 별: 성취, 경험치, 레벨업
```

**최종 추천**: **Option 3 - 집 + 별**
- 이유: 가장 직관적이고 따뜻한 이미지

#### 로고 디자인 가이드
- 스타일: 플랫 디자인, 미니멀
- 색상: Primary Color 기반 (아래 참조)
- 형태: 원형 아이콘 (앱 아이콘 최적화)

### 3.2 컬러 팔레트

#### Primary Color
```
Purple (현재 사용 중)
- HEX: #673AB7 (Material Deep Purple)
- RGB: 103, 58, 183
- 의미: 창의성, 게임, 혁신
- 사용: 앱 주 색상, CTA 버튼
```

#### Secondary Colors
```
Green (성공, 완료)
- HEX: #4CAF50 (Material Green)
- 사용: 완료 상태, 성취 메시지

Orange (중간 난이도)
- HEX: #FF9800 (Material Orange)
- 사용: 중간 난이도 배지

Red (어려움, 긴급)
- HEX: #F44336 (Material Red)
- 사용: 어려움 난이도, 마감 임박
```

#### Neutral Colors
```
Background Light: #FAFAFA
Background Dark: #121212
Text Primary: #212121
Text Secondary: #757575
```

### 3.3 타이포그래피

```
한글: Noto Sans KR (Google Fonts)
- Regular: 본문
- Medium: 부제목
- Bold: 제목, 강조

영문: Roboto (Material Design 기본)
- Regular: 본문
- Medium: 부제목
- Bold: 제목

숫자: Roboto Mono (XP, 레벨 표시)
```

### 3.4 아이콘 스타일

- **Material Icons** (현재 사용 중)
- **대안**: Heroicons, Feather Icons (더 모던한 느낌)

---

## 4. 앱 스토어 최적화 (ASO)

### 4.1 앱 이름

#### iOS App Store
```
ChoreQuest - 가족 집안일 관리
```
- 최대 30자
- 주요 키워드 포함: "가족", "집안일", "관리"

#### Google Play Store
```
ChoreQuest: 가족 집안일 게임화 관리
```
- 최대 50자
- 추가 키워드: "게임화"

### 4.2 부제목 (Subtitle)

```
집안일을 재미있는 퀘스트로! 가족과 함께하는 게임화 집안일 관리
```
- 최대 80자
- 핵심 가치 강조

### 4.3 키워드 전략

#### 한국어 키워드 (우선순위)
```
1차: 집안일, 가사분담, 할일관리
2차: 게임화, 가족협업, 집안일앱
3차: 맞벌이, 신혼부부, 육아
4차: 리더보드, 포인트, 레벨업
```

#### ASO 키워드 조합
```
"집안일 관리 앱"
"가사 분담 앱"
"가족 협업 앱"
"할일 게임화"
"집안일 포인트"
```

### 4.4 스크린샷 전략

#### 필수 스크린샷 (6장)
```
1. 대시보드 (오늘의 할 일)
   - 캡션: "오늘 할 일을 한눈에"

2. 집안일 완료 + XP 획득
   - 캡션: "집안일 완료하고 경험치 획득!"

3. 리더보드
   - 캡션: "가족 구성원과 즐거운 경쟁"

4. 캘린더 뷰
   - 캡션: "캘린더로 한눈에 보는 집안일"

5. 프로필 & 레벨
   - 캡션: "레벨업하며 성장하는 재미"

6. 협업 온보딩
   - 캡션: "가족이 함께 만드는 우리 집 규칙"
```

---

## 5. 소셜 미디어 전략

### 5.1 핸들(Handle) 확보

```
Instagram: @chorequest.app
Twitter/X: @ChoreQuest
Facebook: /ChoreQuestApp
YouTube: @ChoreQuestOfficial
카카오톡 채널: 홈챌린저
```

### 5.2 콘텐츠 전략

#### 콘텐츠 카테고리
```
1. 살림 노하우 (40%)
   - "겨울철 물때 제거 꿀팁"
   - "빨래 냄새 없애는 방법"

2. 가족 스토리 (30%)
   - 사용자 후기
   - "우리 집 집안일 분담 비법"

3. 제품 업데이트 (20%)
   - 신기능 소개
   - 팁 & 트릭

4. 재미 요소 (10%)
   - 밈, 공감 콘텐츠
   - "집안일 안 하는 배우자 vs 나"
```

#### 해시태그 전략
```
브랜드: #홈챌린저 #ChoreQuest
카테고리: #집안일 #가사분담 #할일관리
타겟: #맞벌이부부 #신혼부부 #육아맘
트렌드: #살림스타그램 #오늘의집
```

---

## 6. 파트너십 전략

### 6.1 잠재 파트너

#### 1) 오늘의집 (버킷플레이스)
- **협업 아이디어**: 커뮤니티 탭에서 오늘의집 콘텐츠 연동
- **Win-Win**: ChoreQuest 사용자가 청소용품 구매 → 오늘의집 수수료
- **접근**: 비즈니스 제휴 제안

#### 2) 카카오 (Kakao)
- **협업 아이디어**:
  - 카카오톡 미니앱 진출
  - 카카오 로그인 연동
  - 카카오페이 결제
- **Win-Win**: 카카오 생활 서비스 확장, ChoreQuest 사용자 급증
- **접근**: 카카오 벤처스 IR

#### 3) 삼성 SmartThings
- **협업 아이디어**: IoT 기기 연동 (Phase 3)
- **Win-Win**: 스마트홈 생태계 강화, ChoreQuest 차별화
- **접근**: SmartThings 파트너 프로그램

#### 4) 육아 커뮤니티 (맘카페, 아이돌봄)
- **협업 아이디어**: 커뮤니티 마케팅, 사용자 인터뷰
- **Win-Win**: 실사용자 피드백, 구전 효과
- **접근**: 커뮤니티 매니저 직접 접촉

---

## 7. 도메인 및 인프라 설정 가이드

### 7.1 도메인 구매 및 연결

```bash
# 1. 도메인 구매 (Namecheap 예시)
# https://www.namecheap.com
# chorequest.app 검색 → 구매

# 2. Firebase Hosting에 커스텀 도메인 연결
firebase hosting:channel:deploy production

# Firebase Console에서:
# Hosting → Custom Domain → Add Domain
# chorequest.app 입력
# TXT 레코드로 소유권 인증

# 3. DNS 설정 (Namecheap)
Type: A
Host: @
Value: (Firebase가 제공한 IP)
TTL: Automatic

Type: A
Host: www
Value: (Firebase가 제공한 IP)
TTL: Automatic
```

### 7.2 이메일 설정

```bash
# Google Workspace (구 G Suite) 추천
# chorequest.app 도메인으로 이메일 생성

이메일 주소 예시:
- hello@chorequest.app (고객 문의)
- support@chorequest.app (기술 지원)
- team@chorequest.app (팀 내부)
- no-reply@chorequest.app (시스템 발신 전용)
```

### 7.3 SSL 인증서

```bash
# Firebase Hosting은 자동으로 Let's Encrypt SSL 적용
# HTTPS 강제 리다이렉트 자동 활성화

# .app TLD는 HTTPS 필수
# HTTP 접근 시 자동으로 HTTPS로 리다이렉트
```

---

## 8. 상표 등록 전략

### 8.1 상표 출원 우선순위

#### 1단계: 한국 출원
```
출원 대상: 홈챌린저 (HomeChallenger)
구분: 제9류 (컴퓨터 소프트웨어), 제42류 (SaaS)
비용: 약 ₩150,000 (출원료 + 대리인 수수료)
기간: 6-12개월
```

#### 2단계: 국제 출원 (마드리드 의정서)
```
출원 대상: ChoreQuest
구분: 미국, 일본, EU
비용: 국가당 $500-1,000
조건: 한국 출원 후 6개월 이내
```

### 8.2 상표 검색

```bash
# 한국 특허청 KIPRIS
http://www.kipris.or.kr

# 검색어
- "홈챌린저"
- "HomeChallenger"
- "ChoreQuest"
- "집안일 관리"

# 유사 상표 확인
- 유사 상표가 있다면 대안 이름 고려
```

---

## 9. 실행 체크리스트

### Phase 1: 즉시 실행 (1주 내)
- [ ] 도메인 가용성 확인 (chorequest.app, homechallenger.kr)
- [ ] 도메인 구매 및 Firebase 연결
- [ ] 소셜 미디어 핸들 확보 (@chorequest.app)
- [ ] Google Workspace 이메일 설정

### Phase 2: 앱 출시 전 (1개월 내)
- [ ] 로고 디자인 의뢰 (Fiverr, 크몽)
- [ ] 앱 스토어 스크린샷 제작
- [ ] 한국 상표 출원 (홈챌린저)
- [ ] 카카오톡 채널 개설

### Phase 3: 앱 출시 후 (3개월 내)
- [ ] 콘텐츠 마케팅 시작 (주 2회 포스팅)
- [ ] 육아 커뮤니티 마케팅
- [ ] 오늘의집 제휴 제안
- [ ] 국제 상표 출원 (ChoreQuest)

---

## 10. 예산 계획

| 항목 | 비용 | 주기 | 연간 비용 |
|------|------|------|----------|
| 도메인 (.app) | $20 | 연간 | $20 |
| 도메인 (.kr) | ₩20,000 | 연간 | ₩20,000 |
| Google Workspace | $6/월 | 월간 | $72 |
| Firebase Hosting | ~$5/월 | 월간 | $60 |
| 로고 디자인 | ₩100,000 | 일회성 | ₩100,000 |
| 상표 출원 (한국) | ₩150,000 | 일회성 | ₩150,000 |
| 소셜 미디어 광고 | ₩500,000 | 분기 | ₩2,000,000 |
| **총 1년차 비용** | | | **약 ₩2,350,000** |

---

## 11. 참고 자료

### 도메인 관련
- Namecheap: https://www.namecheap.com
- Firebase Custom Domain: https://firebase.google.com/docs/hosting/custom-domain

### 브랜딩 리소스
- Google Fonts: https://fonts.google.com
- Material Icons: https://fonts.google.com/icons
- Figma (디자인 툴): https://www.figma.com

### 상표 출원
- 한국 특허청 KIPRIS: http://www.kipris.or.kr
- 상표 출원 대행: 윈브이피(winbvip.com), 특허법인

### ASO 도구
- App Annie (앱 순위 분석)
- Sensor Tower (키워드 분석)

---

<div align="center">
  <strong>ChoreQuest Domain & Branding Strategy</strong> v1.0
</div>
