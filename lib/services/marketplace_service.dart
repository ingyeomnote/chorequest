import '../models/chore_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

/// 마켓플레이스 서비스
/// 가사 도우미 매칭, 제품 추천, 수수료 관리
class MarketplaceService {
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  // 가사 도우미 찾기
  List<HelperProfile> findHelpers({
    required String location,
    required List<String> requiredServices,
    double? maxBudget,
    int? minRating,
  }) {
    logger.i('Finding helpers in $location for services: $requiredServices');

    // 실제 구현: Firestore 쿼리 또는 외부 API 연동
    // 여기서는 샘플 데이터 반환

    final allHelpers = _getSampleHelpers();

    return allHelpers.where((helper) {
      // 지역 필터
      if (!helper.serviceAreas.contains(location)) return false;

      // 서비스 필터
      final hasRequiredServices = requiredServices.every(
        (service) => helper.services.contains(service),
      );
      if (!hasRequiredServices) return false;

      // 예산 필터
      if (maxBudget != null && helper.hourlyRate > maxBudget) return false;

      // 평점 필터
      if (minRating != null && helper.rating < minRating) return false;

      return true;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // 도우미 예약 요청
  Future<BookingResult> requestHelperBooking({
    required String helperId,
    required DateTime scheduledDate,
    required Duration duration,
    required List<String> services,
    required String location,
    String? specialRequests,
  }) async {
    logger.i('Requesting booking for helper: $helperId');

    try {
      // 실제 구현: Firestore에 예약 생성
      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      return BookingResult(
        success: true,
        bookingId: bookingId,
        message: '예약 요청이 전송되었습니다. 도우미의 승인을 기다려주세요.',
      );
    } catch (e) {
      logger.e('Failed to create booking: $e');
      return BookingResult(
        success: false,
        message: '예약 요청에 실패했습니다: $e',
      );
    }
  }

  // 추천 제품 (AI 기반)
  Future<List<ProductRecommendation>> recommendProducts({
    required List<ChoreModel> recentChores,
    required String householdType,
  }) async {
    logger.i('Recommending products for household type: $householdType');

    // 최근 집안일 패턴 분석
    final choreCategories = <String, int>{};
    for (final chore in recentChores) {
      final category = chore.category ?? 'general';
      choreCategories[category] = (choreCategories[category] ?? 0) + 1;
    }

    // 가장 많이 하는 집안일 카테고리
    final topCategories = choreCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendations = <ProductRecommendation>[];

    for (final category in topCategories.take(3)) {
      recommendations.addAll(_getProductsForCategory(category.key));
    }

    // 중복 제거 및 평점 순 정렬
    final uniqueProducts = <String, ProductRecommendation>{};
    for (final product in recommendations) {
      if (!uniqueProducts.containsKey(product.id) ||
          product.rating > uniqueProducts[product.id]!.rating) {
        uniqueProducts[product.id] = product;
      }
    }

    return uniqueProducts.values.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // 제품 구매 링크 생성 (제휴 링크)
  String generateAffiliateLink({
    required String productId,
    required String userId,
    required AffiliatePlatform platform,
  }) {
    // 실제 구현: 제휴 플랫폼 API 연동
    final baseUrl = _getAffiliatePlatformUrl(platform);
    return '$baseUrl/product/$productId?ref=chorequest&user=$userId';
  }

  // 수수료 추적
  CommissionReport trackCommissions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    logger.i('Tracking commissions from $startDate to $endDate');

    // 실제 구현: Firestore 쿼리
    // 여기서는 샘플 데이터

    return CommissionReport(
      startDate: startDate,
      endDate: endDate,
      totalHelperBookings: 45,
      helperCommissionEarned: 675000, // 예약당 15,000원
      totalProductSales: 123,
      productCommissionEarned: 1230000, // 판매액의 5%
      totalCommission: 1905000,
      topProducts: [
        CommissionItem(
          name: '다이슨 무선청소기 V15',
          sales: 8,
          commission: 320000,
        ),
        CommissionItem(
          name: 'LG 스타일러',
          sales: 5,
          commission: 250000,
        ),
        CommissionItem(
          name: '샤오미 로봇청소기',
          sales: 12,
          commission: 180000,
        ),
      ],
    );
  }

  // 제휴 파트너 추가
  Future<bool> addAffiliatePartner({
    required AffiliatePartner partner,
  }) async {
    logger.i('Adding affiliate partner: ${partner.name}');

    try {
      // 실제 구현: Firestore에 저장
      return true;
    } catch (e) {
      logger.e('Failed to add partner: $e');
      return false;
    }
  }

  // Private helpers

  List<HelperProfile> _getSampleHelpers() {
    return [
      HelperProfile(
        id: 'helper1',
        name: '김미영',
        rating: 4.9,
        reviewCount: 127,
        hourlyRate: 15000,
        services: ['청소', '빨래', '설거지'],
        serviceAreas: ['강남구', '서초구'],
        yearsExperience: 5,
        bio: '꼼꼼하고 친절한 서비스를 제공합니다.',
        certifications: ['가사관리사 1급'],
        availability: ['월', '화', '수', '목'],
      ),
      HelperProfile(
        id: 'helper2',
        name: '박선희',
        rating: 4.8,
        reviewCount: 89,
        hourlyRate: 18000,
        services: ['청소', '요리', '정리정돈'],
        serviceAreas: ['마포구', '서대문구'],
        yearsExperience: 8,
        bio: '요리 전문 가사 도우미입니다.',
        certifications: ['조리사 자격증', '가사관리사 2급'],
        availability: ['화', '수', '금', '토'],
      ),
    ];
  }

  List<ProductRecommendation> _getProductsForCategory(String category) {
    final products = <String, List<ProductRecommendation>>{
      'cleaning': [
        ProductRecommendation(
          id: 'dyson-v15',
          name: '다이슨 무선청소기 V15',
          description: '강력한 흡입력과 긴 사용시간',
          price: 899000,
          rating: 4.7,
          reviewCount: 1523,
          imageUrl: 'https://example.com/dyson-v15.jpg',
          affiliateLink: 'https://coupang.com/...',
          platform: AffiliatePlatform.coupang,
          commissionRate: 0.05,
        ),
        ProductRecommendation(
          id: 'xiaomi-robot',
          name: '샤오미 로봇청소기',
          description: '자동 청소로 편리함을',
          price: 299000,
          rating: 4.5,
          reviewCount: 892,
          imageUrl: 'https://example.com/xiaomi-robot.jpg',
          affiliateLink: 'https://coupang.com/...',
          platform: AffiliatePlatform.coupang,
          commissionRate: 0.05,
        ),
      ],
      'laundry': [
        ProductRecommendation(
          id: 'lg-styler',
          name: 'LG 스타일러',
          description: '옷 관리를 한 번에',
          price: 1990000,
          rating: 4.8,
          reviewCount: 456,
          imageUrl: 'https://example.com/lg-styler.jpg',
          affiliateLink: 'https://coupang.com/...',
          platform: AffiliatePlatform.coupang,
          commissionRate: 0.05,
        ),
      ],
      'cooking': [
        ProductRecommendation(
          id: 'tefal-pot',
          name: '테팔 인제니오 냄비세트',
          description: '탈부착 손잡이로 수납 간편',
          price: 89000,
          rating: 4.6,
          reviewCount: 2341,
          imageUrl: 'https://example.com/tefal-pot.jpg',
          affiliateLink: 'https://coupang.com/...',
          platform: AffiliatePlatform.coupang,
          commissionRate: 0.05,
        ),
      ],
    };

    return products[category] ?? [];
  }

  String _getAffiliatePlatformUrl(AffiliatePlatform platform) {
    switch (platform) {
      case AffiliatePlatform.coupang:
        return 'https://www.coupang.com';
      case AffiliatePlatform.naver:
        return 'https://shopping.naver.com';
      case AffiliatePlatform.elevenst:
        return 'https://www.11st.co.kr';
    }
  }
}

// 가사 도우미 프로필
class HelperProfile {
  final String id;
  final String name;
  final double rating;
  final int reviewCount;
  final int hourlyRate;
  final List<String> services;
  final List<String> serviceAreas;
  final int yearsExperience;
  final String bio;
  final List<String> certifications;
  final List<String> availability;
  final String? profileImageUrl;

  HelperProfile({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.services,
    required this.serviceAreas,
    required this.yearsExperience,
    required this.bio,
    required this.certifications,
    required this.availability,
    this.profileImageUrl,
  });

  bool isAvailableOn(DateTime date) {
    final dayOfWeek = ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
    return availability.contains(dayOfWeek);
  }
}

// 예약 결과
class BookingResult {
  final bool success;
  final String? bookingId;
  final String message;

  BookingResult({
    required this.success,
    this.bookingId,
    required this.message,
  });
}

// 제품 추천
class ProductRecommendation {
  final String id;
  final String name;
  final String description;
  final int price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String affiliateLink;
  final AffiliatePlatform platform;
  final double commissionRate;

  ProductRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.affiliateLink,
    required this.platform,
    required this.commissionRate,
  });

  int get estimatedCommission => (price * commissionRate).round();
}

enum AffiliatePlatform {
  coupang,
  naver,
  elevenst,
}

// 수수료 보고서
class CommissionReport {
  final DateTime startDate;
  final DateTime endDate;
  final int totalHelperBookings;
  final int helperCommissionEarned;
  final int totalProductSales;
  final int productCommissionEarned;
  final int totalCommission;
  final List<CommissionItem> topProducts;

  CommissionReport({
    required this.startDate,
    required this.endDate,
    required this.totalHelperBookings,
    required this.helperCommissionEarned,
    required this.totalProductSales,
    required this.productCommissionEarned,
    required this.totalCommission,
    required this.topProducts,
  });

  double get helperCommissionPercentage =>
      totalCommission == 0 ? 0.0 : helperCommissionEarned / totalCommission;

  double get productCommissionPercentage =>
      totalCommission == 0 ? 0.0 : productCommissionEarned / totalCommission;
}

// 수수료 항목
class CommissionItem {
  final String name;
  final int sales;
  final int commission;

  CommissionItem({
    required this.name,
    required this.sales,
    required this.commission,
  });
}

// 제휴 파트너
class AffiliatePartner {
  final String id;
  final String name;
  final AffiliatePlatform platform;
  final double commissionRate;
  final String contactEmail;
  final String apiKey;
  final bool isActive;

  AffiliatePartner({
    required this.id,
    required this.name,
    required this.platform,
    required this.commissionRate,
    required this.contactEmail,
    required this.apiKey,
    required this.isActive,
  });
}

// 마켓플레이스 통계
class MarketplaceStats {
  final int totalHelpers;
  final int activeHelpers;
  final int totalProducts;
  final int thisMonthBookings;
  final int thisMonthSales;
  final int totalRevenue;

  MarketplaceStats({
    required this.totalHelpers,
    required this.activeHelpers,
    required this.totalProducts,
    required this.thisMonthBookings,
    required this.thisMonthSales,
    required this.totalRevenue,
  });
}
