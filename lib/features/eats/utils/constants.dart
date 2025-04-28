class EatsConstants {
  // Dimensions
  static const double searchBarHeight = 52.0;
  static const double categoryBarHeight = 48.0;
  static const double promotionBannerHeight = 140.0;
  static const double restaurantItemAspectRatio = 1.6;
  static const double appBarHeight = 300.0;
  static const double tabBarHeight = 56.0;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration loadingDelay = Duration(milliseconds: 800);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // Categories
  static const List<String> categories = [
    '전체',
    '한식',
    '중식',
    '일식',
    '양식',
    '분식',
    '카페',
    '패스트푸드',
    '치킨',
    '피자',
  ];

  // Colors
  static const int starColor = 0xFFFFB800;

  // Text
  static const String searchHint = '맛집을 검색해보세요';
  static const String noResultsTitle = '검색 결과가 없습니다';
  static const String noResultsSubtitle = '다른 검색어를 입력해보세요';
  static const String promotionTag = '프로모션';
  static const String popularTag = '인기';
  static const String addToCartText = '장바구니 담기';
  static const String modifyCartText = '수량 변경';
  static const String orderConfirmTitle = '주문 확인';
  static const String orderCompleteMessage = '주문이 완료되었습니다';
  static const String cancelText = '취소';
  static const String orderText = '주문하기';
} 