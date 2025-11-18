import '../models/chore_model.dart';

// 한국형 집안일 템플릿
class KoreanChoreTemplates {
  // 템플릿 카테고리
  static const String newlywed = 'newlywed'; // 신혼부부
  static const String family = 'family'; // 유자녀 가정
  static const String roommate = 'roommate'; // 룸메이트
  static const String seasonal = 'seasonal'; // 계절별
  static const String holiday = 'holiday'; // 명절

  // 맞벌이 신혼부부 (2인) 템플릿
  static List<ChoreTemplate> getNewlywedTemplates() {
    return [
      // 일일 집안일
      ChoreTemplate(
        title: '설거지',
        category: '주방',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 15,
        recurrenceType: RecurrenceType.daily,
        rotateAssignees: true,
        description: '식사 후 설거지하기',
        tags: ['일일', '주방', '기본'],
      ),
      ChoreTemplate(
        title: '음식물 쓰레기 버리기',
        category: '청소',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 5,
        recurrenceType: RecurrenceType.daily,
        description: '음식물 쓰레기통 비우기',
        tags: ['일일', '쓰레기'],
      ),
      ChoreTemplate(
        title: '쓰레기 분리수거',
        category: '청소',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 10,
        recurrenceType: RecurrenceType.custom,
        customRecurrenceDays: [1, 3, 5], // 월, 수, 금
        description: '요일별 분리수거 (종이, 플라스틱, 캔 등)',
        tags: ['분리수거', '환경'],
      ),

      // 주간 집안일
      ChoreTemplate(
        title: '화장실 청소',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.weekly,
        preferredDay: 7, // 일요일
        description: '화장실 청소 및 소독',
        tags: ['주간', '청소', '위생'],
      ),
      ChoreTemplate(
        title: '빨래하기',
        category: '세탁',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 20,
        recurrenceType: RecurrenceType.custom,
        customRecurrenceDays: [3, 6], // 수, 토
        description: '빨래 돌리기 및 널기',
        tags: ['주간', '세탁'],
      ),
      ChoreTemplate(
        title: '청소기 돌리기',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 25,
        recurrenceType: RecurrenceType.weekly,
        preferredDay: 6, // 토요일
        description: '집 전체 청소기 돌리기',
        tags: ['주간', '청소'],
      ),
      ChoreTemplate(
        title: '침구 세탁',
        category: '세탁',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.biweekly,
        description: '이불커버, 베개커버 세탁',
        tags: ['격주', '세탁', '위생'],
      ),

      // 월간 집안일
      ChoreTemplate(
        title: '베란다 정리',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 40,
        recurrenceType: RecurrenceType.monthly,
        description: '베란다 청소 및 환기',
        tags: ['월간', '정리'],
      ),
      ChoreTemplate(
        title: '김치냉장고 정리',
        category: '주방',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 20,
        recurrenceType: RecurrenceType.monthly,
        description: '김치냉장고 청소 및 정리',
        tags: ['월간', '한국형', '주방'],
      ),
      ChoreTemplate(
        title: '에어컨/공기청정기 필터 청소',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.monthly,
        description: '필터 청소 또는 교체',
        tags: ['월간', '가전', '위생'],
      ),
      ChoreTemplate(
        title: '현관 신발장 정리',
        category: '정리',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 15,
        recurrenceType: RecurrenceType.monthly,
        description: '신발 정리 및 신발장 청소',
        tags: ['월간', '한국형', '정리'],
      ),
    ];
  }

  // 유자녀 가정 (4인) 템플릿
  static List<ChoreTemplate> getFamilyTemplates() {
    return [
      ...getNewlywedTemplates(), // 기본 템플릿 포함

      // 육아 관련
      ChoreTemplate(
        title: '아이 도시락 준비',
        category: '주방',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 25,
        recurrenceType: RecurrenceType.custom,
        customRecurrenceDays: [1, 2, 3, 4, 5], // 평일
        description: '아이 도시락 만들기',
        tags: ['일일', '육아', '주방'],
      ),
      ChoreTemplate(
        title: '아이 방 정리 (자녀 참여)',
        category: '정리',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 15,
        recurrenceType: RecurrenceType.daily,
        description: '아이와 함께 방 정리하기',
        tags: ['일일', '육아', '정리', '교육'],
      ),
      ChoreTemplate(
        title: '아이 옷 정리',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.weekly,
        description: '아이 옷장 정리',
        tags: ['주간', '육아', '정리'],
      ),
      ChoreTemplate(
        title: '장보기',
        category: '장보기',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 60,
        recurrenceType: RecurrenceType.weekly,
        preferredDay: 6, // 토요일
        description: '장보기 (식료품, 생필품)',
        tags: ['주간', '장보기'],
      ),

      // 학기별 (계절)
      ChoreTemplate(
        title: '개학 준비',
        category: '이벤트',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 90,
        recurrenceType: RecurrenceType.never, // 수동 추가
        description: '학용품 준비, 교복 정리 등',
        tags: ['이벤트', '육아', '학기'],
      ),
    ];
  }

  // 자취생/룸메이트 템플릿
  static List<ChoreTemplate> getRoommateTemplates() {
    return [
      ChoreTemplate(
        title: '공용 공간 청소 (거실)',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.weekly,
        rotateAssignees: true,
        description: '거실 청소 및 정리',
        tags: ['주간', '청소', '공용'],
      ),
      ChoreTemplate(
        title: '공용 화장실 청소',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 25,
        recurrenceType: RecurrenceType.weekly,
        rotateAssignees: true,
        description: '화장실 청소 및 소독',
        tags: ['주간', '청소', '공용', '위생'],
      ),
      ChoreTemplate(
        title: '공용 주방 설거지',
        category: '주방',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 15,
        recurrenceType: RecurrenceType.daily,
        rotateAssignees: true,
        description: '공용 식기 설거지',
        tags: ['일일', '주방', '공용'],
      ),
      ChoreTemplate(
        title: '쓰레기 분리수거',
        category: '청소',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 10,
        recurrenceType: RecurrenceType.custom,
        customRecurrenceDays: [1, 3, 5],
        rotateAssignees: true,
        description: '요일별 분리수거',
        tags: ['분리수거', '공용'],
      ),
      ChoreTemplate(
        title: '공과금 정산',
        category: '관리',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 20,
        recurrenceType: RecurrenceType.monthly,
        description: '월별 공과금 나누기',
        tags: ['월간', '관리', '공용'],
      ),
      ChoreTemplate(
        title: '생필품 구매 (공용)',
        category: '장보기',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.monthly,
        description: '휴지, 세제 등 공용 생필품 구매',
        tags: ['월간', '장보기', '공용'],
      ),
    ];
  }

  // 계절별 집안일
  static List<ChoreTemplate> getSeasonalTemplates() {
    return [
      // 봄 (3-5월)
      ChoreTemplate(
        title: '봄맞이 대청소',
        category: '청소',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 180,
        recurrenceType: RecurrenceType.never,
        description: '집 전체 대청소',
        tags: ['계절', '봄', '청소', '이벤트'],
      ),
      ChoreTemplate(
        title: '환절기 옷 정리 (봄)',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 60,
        recurrenceType: RecurrenceType.never,
        description: '겨울옷 정리, 봄옷 꺼내기',
        tags: ['계절', '봄', '정리'],
      ),
      ChoreTemplate(
        title: '미세먼지 대비 필터 청소',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.never,
        description: '에어컨, 공기청정기 필터 청소',
        tags: ['계절', '봄', '가전', '위생'],
      ),

      // 여름 (6-8월)
      ChoreTemplate(
        title: '에어컨 청소',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 40,
        recurrenceType: RecurrenceType.never,
        description: '에어컨 필터 및 내부 청소',
        tags: ['계절', '여름', '가전', '청소'],
      ),
      ChoreTemplate(
        title: '제습 및 곰팡이 방지',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.never,
        description: '화장실, 베란다 곰팡이 제거',
        tags: ['계절', '여름', '위생'],
      ),

      // 가을 (9-11월)
      ChoreTemplate(
        title: '환절기 옷 정리 (가을)',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 60,
        recurrenceType: RecurrenceType.never,
        description: '여름옷 정리, 겨울옷 꺼내기',
        tags: ['계절', '가을', '정리'],
      ),
      ChoreTemplate(
        title: '김장 준비',
        category: '주방',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 300,
        recurrenceType: RecurrenceType.never,
        description: '김장 담그기 (11월)',
        tags: ['계절', '가을', '한국형', '주방', '이벤트'],
      ),
      ChoreTemplate(
        title: '난방 기구 점검',
        category: '관리',
        difficulty: ChoreDifficulty.easy,
        estimatedMinutes: 20,
        recurrenceType: RecurrenceType.never,
        description: '보일러, 히터 점검',
        tags: ['계절', '가을', '관리'],
      ),

      // 겨울 (12-2월)
      ChoreTemplate(
        title: '눈 치우기',
        category: '청소',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 30,
        recurrenceType: RecurrenceType.never,
        description: '집 앞 눈 치우기',
        tags: ['계절', '겨울', '청소'],
      ),
      ChoreTemplate(
        title: '보일러 청소',
        category: '관리',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 60,
        recurrenceType: RecurrenceType.never,
        description: '보일러 필터 청소 또는 점검',
        tags: ['계절', '겨울', '가전', '관리'],
      ),
    ];
  }

  // 명절 준비 템플릿
  static List<ChoreTemplate> getHolidayTemplates() {
    return [
      ChoreTemplate(
        title: '명절 음식 준비',
        category: '주방',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 240,
        recurrenceType: RecurrenceType.never,
        description: '명절 음식 만들기 (떡, 전, 나물 등)',
        tags: ['이벤트', '명절', '한국형', '주방'],
      ),
      ChoreTemplate(
        title: '명절 대청소',
        category: '청소',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 180,
        recurrenceType: RecurrenceType.never,
        description: '명절 전 집 대청소',
        tags: ['이벤트', '명절', '한국형', '청소'],
      ),
      ChoreTemplate(
        title: '손님 맞이 준비',
        category: '정리',
        difficulty: ChoreDifficulty.medium,
        estimatedMinutes: 60,
        recurrenceType: RecurrenceType.never,
        description: '거실 정리, 손님방 준비',
        tags: ['이벤트', '명절', '정리'],
      ),
      ChoreTemplate(
        title: '제사 준비',
        category: '주방',
        difficulty: ChoreDifficulty.hard,
        estimatedMinutes: 180,
        recurrenceType: RecurrenceType.never,
        description: '제사 음식 및 상차림 준비',
        tags: ['이벤트', '명절', '한국형', '주방'],
      ),
    ];
  }

  // 모든 템플릿 가져오기
  static Map<String, List<ChoreTemplate>> getAllTemplates() {
    return {
      newlywed: getNewlywedTemplates(),
      family: getFamilyTemplates(),
      roommate: getRoommateTemplates(),
      seasonal: getSeasonalTemplates(),
      holiday: getHolidayTemplates(),
    };
  }
}

// 집안일 템플릿 클래스
class ChoreTemplate {
  final String title;
  final String category;
  final ChoreDifficulty difficulty;
  final int estimatedMinutes;
  final RecurrenceType recurrenceType;
  final int? preferredDay; // 1=월, 7=일
  final List<int>? customRecurrenceDays; // 커스텀 요일
  final bool rotateAssignees; // 담당자 순환 여부
  final String? description;
  final List<String> tags;

  const ChoreTemplate({
    required this.title,
    required this.category,
    required this.difficulty,
    this.estimatedMinutes = 30,
    this.recurrenceType = RecurrenceType.never,
    this.preferredDay,
    this.customRecurrenceDays,
    this.rotateAssignees = false,
    this.description,
    this.tags = const [],
  });

  // ChoreModel로 변환
  ChoreModel toChoreModel({
    required String householdId,
    String? assignedTo,
    DateTime? dueDate,
  }) {
    return ChoreModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      householdId: householdId,
      title: title,
      description: description,
      difficulty: difficulty,
      assignedTo: assignedTo,
      dueDate: dueDate,
      status: ChoreStatus.pending,
      recurrenceType: recurrenceType,
      tags: tags,
    );
  }
}

// 반복 타입 enum (이미 ChoreModel에 있을 수 있음)
enum RecurrenceType {
  never,
  daily,
  weekly,
  biweekly,
  monthly,
  custom,
}
