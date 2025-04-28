import '../models/market_item.dart';
import '../models/seller.dart';
import '../models/review.dart';

/// Service class for handling marketplace operations
class MarketService {
  // Mock data - This would be replaced with real API calls in a production app
  final List<MarketItem> _items = [
    MarketItem(
      title: '아이폰 13 프로 128GB 그래파이트',
      location: '서울시 강남구',
      price: 750000,
      image: 'https://images.unsplash.com/photo-1591337676887-a217a6970a8a?w=800',
      imageAttribution: 'Photo by Szabo Viktor on Unsplash',
      likes: 8,
      chats: 3,
      category: '디지털기기',
      postDate: DateTime.now().subtract(Duration(hours: 2)),
      description: '아이폰 13 프로 128GB 그래파이트 색상입니다. 구매 후 1개월 사용했으며 상태 좋습니다. 기스 없이 깨끗합니다. 액세서리 모두 포함되어 있습니다.',
      tags: ['애플', '아이폰', '스마트폰'],
      specifications: {
        '색상': '그래파이트',
        '용량': '128GB',
        '구매일': '2023년 3월',
        '보증기간': '2024년 3월까지',
      },
      lat: 37.498095,
      lng: 127.027610,
      seller: Seller(
        id: 'seller1',
        name: '김판매자',
        avatar: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
        rating: 4.8,
        reviewCount: 57,
        itemCount: 12,
        joinDate: DateTime(2022, 3, 15),
      ),
    ),
    MarketItem(
      title: '스타벅스 텀블러 신형 500ml',
      location: '서울시 송파구',
      price: 18000,
      image: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800',
      imageAttribution: 'Photo by Nathan Dumlao on Unsplash',
      likes: 5,
      chats: 2,
      category: '생활/가공식품',
      postDate: DateTime.now().subtract(Duration(hours: 5)),
      description: '스타벅스 신형 텀블러입니다. 선물 받았는데 이미 같은 제품이 있어서 판매합니다. 새상품, 개봉 안 했습니다.',
      tags: ['스타벅스', '텀블러', '머그컵'],
      lat: 37.514219, 
      lng: 127.105909,
      seller: Seller(
        id: 'seller2',
        name: '이재판',
        avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
        rating: 4.5,
        reviewCount: 32,
        itemCount: 8,
        joinDate: DateTime(2022, 5, 10),
      ),
    ),
    // Additional items would be here
  ];

  // Mock reviews - This would be replaced with real API calls
  final List<Review> _reviews = [
    Review(
      id: 'rev1',
      user: '구매자A',
      userAvatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200',
      rating: 5.0,
      comment: '물건 상태 좋고 배송도 빨라요. 친절하게 응대해주셔서 감사합니다.',
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
    Review(
      id: 'rev2',
      user: '구매자B',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      rating: 4.5,
      comment: '좋은 물건 감사합니다. 다음에도 거래하고 싶어요.',
      date: DateTime.now().subtract(Duration(days: 7)),
    ),
    Review(
      id: 'rev3',
      user: '구매자C',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      rating: 5.0,
      comment: '정확한 정보와 빠른 거래 감사합니다. 매우 만족합니다.',
      date: DateTime.now().subtract(Duration(days: 14)),
    ),
  ];

  // Singleton pattern
  static final MarketService _instance = MarketService._internal();
  factory MarketService() => _instance;
  MarketService._internal();

  /// Get all marketplace items
  List<MarketItem> getAllItems() {
    return List.from(_items);
  }

  /// Get bookmarked items
  List<MarketItem> getBookmarkedItems() {
    return _items.where((item) => item.isBookmarked).toList();
  }

  /// Get items by category
  List<MarketItem> getItemsByCategory(String category) {
    if (category == '전체') {
      return List.from(_items);
    }
    return _items.where((item) => item.category == category).toList();
  }

  /// Get related items
  List<MarketItem> getRelatedItems(MarketItem item, {int limit = 3}) {
    return _items
        .where((relItem) => 
            relItem.category == item.category && 
            relItem != item)
        .take(limit)
        .toList();
  }

  /// Search items
  List<MarketItem> searchItems(String query) {
    if (query.isEmpty) return [];
    
    return _items.where((item) => 
      item.title.toLowerCase().contains(query.toLowerCase()) ||
      item.description.toLowerCase().contains(query.toLowerCase()) ||
      item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  /// Get item by ID
  MarketItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Toggle bookmark status
  void toggleBookmark(MarketItem item, bool isBookmarked) {
    final index = _items.indexWhere((i) => i == item);
    if (index != -1) {
      _items[index] = item.copyWith(isBookmarked: isBookmarked);
    }
  }

  /// Get reviews for a seller
  List<Review> getSellerReviews(String sellerId) {
    // In a real app, this would filter by seller ID
    return List.from(_reviews);
  }

  /// Sort items
  List<MarketItem> sortItems(List<MarketItem> items, String sortOption) {
    final sortedItems = List<MarketItem>.from(items);
    
    switch (sortOption) {
      case 'latest':
        sortedItems.sort((a, b) => b.postDate.compareTo(a.postDate));
        break;
      case 'price_low':
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        sortedItems.sort((a, b) => b.likes.compareTo(a.likes));
        break;
    }
    
    return sortedItems;
  }

  /// Filter items by price range
  List<MarketItem> filterByPriceRange(List<MarketItem> items, double minPrice, double maxPrice) {
    return items.where((item) => 
      item.price >= minPrice && item.price <= maxPrice
    ).toList();
  }
} 