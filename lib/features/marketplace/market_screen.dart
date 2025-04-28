import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/market_item.dart';
import 'models/market_profile.dart';
import 'models/review.dart';
import '../chat/chat_screen.dart';
import 'screens/basic_item_detail_screen.dart';
import 'screens/item_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Seller {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewCount;
  final int itemCount;
  final DateTime joinDate;

  const Seller({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewCount, 
    required this.itemCount,
    required this.joinDate,
  });
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  // Example seller profiles
  final Seller _defaultSeller = Seller(
    id: 'seller1',
    name: '김판매자',
    avatar: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
    rating: 4.8,
    reviewCount: 57,
    itemCount: 12,
    joinDate: DateTime(2022, 3, 15),
  );
  
  final Seller _seller2 = Seller(
    id: 'seller2',
    name: '이재판',
    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
    rating: 4.5,
    reviewCount: 32,
    itemCount: 8,
    joinDate: DateTime(2022, 5, 10),
  );
  
  // Example reviews
  final List<Review> _reviews = [
    Review(
      id: 'rev1',
      userId: 'user1',
      userName: '구매자A',
      userAvatar: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200',
      itemId: 'item1',
      rating: 5.0,
      comment: '물건 상태 좋고 배송도 빨라요. 친절하게 응대해주셔서 감사합니다.',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    Review(
      id: 'rev2',
      userId: 'user2',
      userName: '구매자B',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      itemId: 'item1',
      rating: 4.5,
      comment: '좋은 물건 감사합니다. 다음에도 거래하고 싶어요.',
      createdAt: DateTime.now().subtract(Duration(days: 7)),
    ),
    Review(
      id: 'rev3',
      userId: 'user3',
      userName: '구매자C',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      itemId: 'item1',
      rating: 5.0,
      comment: '정확한 정보와 빠른 거래 감사합니다. 매우 만족합니다.',
      createdAt: DateTime.now().subtract(Duration(days: 14)),
    ),
  ];

  final List<MarketItem> _items = [
    MarketItem(
      id: '1',
      sellerId: 'seller1',
      title: '아이폰 13 프로 128GB 그래파이트',
      description: '아이폰 13 프로 128GB 그래파이트 색상입니다. 구매 후 1개월 사용했으며 상태 좋습니다. 기스 없이 깨끗합니다. 액세서리 모두 포함되어 있습니다.',
      price: 750000,
      category: '디지털기기',
      images: ['https://images.unsplash.com/photo-1591337676887-a217a6970a8a?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(hours: 2)),
      condition: '거의 새 것',
      location: '서울시 강남구',
      postDate: DateTime.now().subtract(Duration(hours: 2)),
      likes: 8,
      chats: 3,
      sellerName: '김판매자',
      sellerAvatar: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
      imageAttribution: 'Photo by Szabo Viktor on Unsplash',
    ),
    MarketItem(
      id: '2',
      sellerId: 'seller2',
      title: '스타벅스 텀블러 신형 500ml',
      description: '스타벅스 신형 텀블러입니다. 선물 받았는데 이미 같은 제품이 있어서 판매합니다. 새상품, 개봉 안 했습니다.',
      price: 18000,
      category: '생활/가공식품',
      images: ['https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(hours: 5)),
      condition: '새 상품',
      location: '서울시 송파구',
      postDate: DateTime.now().subtract(Duration(hours: 5)),
      likes: 5,
      chats: 2,
      sellerName: '이재판',
      sellerAvatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
      imageAttribution: 'Photo by Nathan Dumlao on Unsplash',
    ),
    MarketItem(
      id: '3',
      sellerId: 'seller3',
      title: '닌텐도 스위치 OLED 흰색 풀박스',
      description: '닌텐도 스위치 OLED 모델입니다. 풀박스로 구성품 모두 포함되어 있습니다.',
      price: 340000,
      category: '디지털기기',
      images: ['https://images.unsplash.com/photo-1589241062272-c0a000072661?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      condition: '거의 새 것',
      location: '서울시 마포구',
      postDate: DateTime.now().subtract(Duration(days: 1)),
      likes: 12,
      chats: 6,
      sellerName: '닌텐도팬',
      sellerAvatar: 'https://randomuser.me/api/portraits/men/3.jpg',
      imageAttribution: 'Photo by Ehimetalor Akhere Unuabona on Unsplash',
    ),
    MarketItem(
      id: '4',
      sellerId: 'seller4',
      title: '맥북 프로 M1 13인치 스페이스그레이',
      description: '맥북 프로 M1 13인치 모델입니다. 배터리 사이클 50회 미만이며 상태 매우 좋습니다.',
      price: 1050000,
      category: '디지털기기',
      images: ['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 4)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      condition: '좋음',
      location: '서울시 서초구',
      postDate: DateTime.now().subtract(Duration(days: 2)),
      likes: 23,
      chats: 9,
      sellerName: '맥북러버',
      sellerAvatar: 'https://randomuser.me/api/portraits/women/3.jpg',
      imageAttribution: 'Photo by Alen Rojnic on Unsplash',
    ),
    MarketItem(
      id: '5',
      sellerId: 'seller5',
      title: '에어팟 프로 2세대 미개봉',
      description: '에어팟 프로 2세대 새상품입니다. 선물 받았으나 이미 사용 중인 제품이 있어 판매합니다.',
      price: 280000,
      category: '디지털기기',
      images: ['https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      updatedAt: DateTime.now().subtract(Duration(days: 3)),
      condition: '새 상품',
      location: '서울시 강남구',
      postDate: DateTime.now().subtract(Duration(days: 3)),
      likes: 17,
      chats: 5,
      sellerName: '애플맨',
      sellerAvatar: 'https://randomuser.me/api/portraits/men/4.jpg',
      imageAttribution: 'Photo by Suganth on Unsplash',
    ),
    MarketItem(
      id: '6',
      sellerId: 'seller6',
      title: '캠핑 텐트 4인용 방수 처음사용',
      description: '캠핑 텐트 4인용입니다. 한 번 사용했으며 상태 매우 좋습니다. 방수 기능 우수합니다.',
      price: 120000,
      category: '스포츠/레저',
      images: ['https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800'],
      createdAt: DateTime.now().subtract(Duration(days: 4)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      condition: '거의 새 것',
      location: '서울시 은평구',
      postDate: DateTime.now().subtract(Duration(days: 2)),
      likes: 7,
      chats: 2,
      sellerName: '캠핑맨',
      sellerAvatar: 'https://randomuser.me/api/portraits/women/4.jpg',
      imageAttribution: 'Photo by Daan Weijers on Unsplash',
    ),
  ];

  int _selectedCategoryIndex = 0;
  bool _showAttributedOnly = false;
  String _sortOption = 'latest'; // Options: latest, price_low, price_high, popular
  bool _isFilterSheetOpen = false;
  RangeValues _priceRange = RangeValues(0, 2000000);
  
  late TabController _tabController;
  final List<String> _tabs = ['All Items'];
  
  final TextEditingController _searchController = TextEditingController();
  List<MarketItem> _searchResults = [];
  List<String> _recentSearches = ['아이폰', '맥북', '에어팟', '텀블러'];

  // Add a new property for loading state
  bool _isLoading = false;

  // Add bookmarked items map
  final Map<String, bool> _bookmarkedItems = {};

  // Add these fields for filter functionality
  final Set<String> _selectedFilters = <String>{};
  final List<String> _availableFilters = ['전체', '디지털기기', '생활/가공식품', '의류', '가구/인테리어', '도서/음반', '스포츠/레저'];
  final List<String> _priceFilters = ['가격 전체', '10만원 이하', '10-30만원', '30-50만원', '50만원 이상'];
  final List<String> _sortOptions = ['최신순', '인기순', '저가순', '고가순', '거리순'];
  String _selectedPriceFilter = '가격 전체';
  String _selectedSortOption = '최신순';
  final List<String> _wishlistItemIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Update state when tab changes
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          toolbarHeight: 56,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '강남구 역삼동',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onBackground,
                size: 22,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onBackground,
                size: 24,
              ),
              onPressed: () => _showSearchScreen(),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: _isFilterSheetOpen
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onBackground,
                size: 24,
              ),
              onPressed: _showFilterBottomSheet,
              tooltip: 'Filter items',
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            const SizedBox(width: 12),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2),
            child: Container(
              height: 1,
              color: theme.dividerColor.withOpacity(0.1),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(theme),
            Expanded(
              child: _items.isEmpty 
                  ? _buildEmptyState() 
                  : _buildMarketList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add_rounded, color: theme.colorScheme.onPrimary, size: 30),
          onPressed: () {
            _showAddItemDialog();
          },
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('상품 등록'),
          content: Text('상품 등록 기능이 곧 추가될 예정입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '등록된 상품이 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '지금 첫 상품을 등록해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showAddItemDialog, 
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('상품 등록하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          _buildFilterButton(
            theme,
            '카테고리',
            () => _showFilterSheet(context, '카테고리', _availableFilters, (value) {
              setState(() {
                if (value == '전체') {
                  _selectedFilters.clear();
                } else if (_selectedFilters.contains(value)) {
                  _selectedFilters.remove(value);
                } else {
                  _selectedFilters.add(value);
                }
              });
            }),
          ),
          _buildFilterButton(
            theme,
            _selectedPriceFilter,
            () => _showFilterSheet(context, '가격대', _priceFilters, (value) {
              setState(() {
                _selectedPriceFilter = value;
              });
            }),
          ),
          _buildFilterButton(
            theme,
            _selectedSortOption,
            () => _showFilterSheet(context, '정렬', _sortOptions, (value) {
              setState(() {
                _selectedSortOption = value;
              });
            }),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: theme.colorScheme.onBackground,
              size: 24,
            ),
            onPressed: () => _showWishlist(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onBackground,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final isSelected = title == '카테고리' 
                      ? (_selectedFilters.contains(options[index]) || (options[index] == '전체' && _selectedFilters.isEmpty))
                      : (title == '가격대' ? _selectedPriceFilter == options[index] : _selectedSortOption == options[index]);
                      
                  return ListTile(
                    title: Text(options[index]),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () {
                      onSelect(options[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWishlist(BuildContext context) {
    if (_wishlistItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('찜 목록이 비어 있습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final wishlistItems = _items.where((item) => _wishlistItemIds.contains(item.id)).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '찜 목록',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: wishlistItems.length,
                      itemBuilder: (context, index) {
                        final item = wishlistItems[index];
                        return _buildWishlistItem(item, context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWishlistItem(MarketItem item, BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'ko_KR');
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: item.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceVariant,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currencyFormat.format(item.price)}원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.location ?? '위치 정보 없음',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _wishlistItemIds.remove(item.id);
              });
              Navigator.pop(context);
              _showWishlist(context);
            },
          ),
        ],
      ),
    );
  }

  // Add this method to toggle wishlist items
  void _toggleWishlist(String itemId) {
    setState(() {
      if (_wishlistItemIds.contains(itemId)) {
        _wishlistItemIds.remove(itemId);
      } else {
        _wishlistItemIds.add(itemId);
        // Animate heart icon
        HapticFeedback.lightImpact();
      }
    });
  }
  
  // Modify your existing item card to include wishlist functionality
  Widget _buildItemCard(MarketItem item, BuildContext context) {
    // ... existing code ...
    final isWishlisted = _wishlistItemIds.contains(item.id);
    
    return GestureDetector(
      // ... existing code ...
      child: Column(
        // ... existing code ...
        children: [
          // ... existing code ...
          // Add this to your existing item cards
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleWishlist(item.id),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          // ... rest of existing code ...
        ],
      ),
    );
  }

  void _sortItems() {
    final filteredItems = _showAttributedOnly
        ? _items.where((item) => item.imageAttribution?.isNotEmpty ?? false).toList()
        : List<MarketItem>.from(_items);
    
    switch (_sortOption) {
      case 'latest':
        filteredItems.sort((a, b) => 
            (b.postDate ?? b.createdAt).compareTo(a.postDate ?? a.createdAt));
        break;
      case 'price_low':
        filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        filteredItems.sort((a, b) => b.likes.compareTo(a.likes));
        break;
    }
    
    setState(() {
      _items.clear();
      _items.addAll(filteredItems);
    });
  }

  void _showFilterBottomSheet() {
    setState(() {
      _isFilterSheetOpen = true;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle and title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '필터',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  _priceRange = const RangeValues(0, 2000000);
                                });
                              },
                              child: const Text('초기화'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Price range filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '가격 범위',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_formatNumber(_priceRange.start)}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              '~',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_formatNumber(_priceRange.end)}원',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveTrackColor: theme.colorScheme.surfaceVariant,
                            thumbColor: theme.colorScheme.primary,
                            overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 2000000,
                            divisions: 20,
                            onChanged: (values) {
                              setSheetState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Additional filter options can be added here
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Category Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '카테고리',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Chips (simplified version)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            '전체', '디지털기기', '가구/인테리어', '유아동', 
                            '생활/가공식품', '의류', '스포츠/레저', '도서'
                          ].map((category) {
                            final isSelected = category == '전체' && _selectedCategoryIndex == 0 || 
                                               _selectedCategoryIndex > 0 && 
                                               category == ['전체', '디지털기기', '가구/인테리어', '유아동', 
                                                          '생활/가공식품', '의류', '스포츠/레저', '도서'][_selectedCategoryIndex];
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                final index = ['전체', '디지털기기', '가구/인테리어', '유아동', 
                                              '생활/가공식품', '의류', '스포츠/레저', '도서', 
                                              '뷰티/미용'].indexOf(category);
                                if (index >= 0) {
                                  setSheetState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                }
                              },
                              labelStyle: TextStyle(
                                color: isSelected 
                                    ? theme.colorScheme.onPrimary 
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary,
                              checkmarkColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelected 
                                      ? Colors.transparent 
                                      : theme.colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Apply button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Apply filters and simulate loading
                          _isLoading = true;
                        });
                        Navigator.pop(context);
                        
                        // Simulate loading state
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '필터 적용하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isFilterSheetOpen = false;
      });
    });
  }

  Widget _buildMarketList() {
    final filteredItems = _showAttributedOnly
        ? _items.where((item) => item.imageAttribution?.isNotEmpty ?? false).toList()
        : List<MarketItem>.from(_items);
        
    final priceFilteredItems = filteredItems
        .where((item) => item.price >= _priceRange.start && item.price <= _priceRange.end)
        .toList();
        
    if (_isLoading) {
      // Show skeleton loading state
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: 6, // Number of skeleton items to show
        itemBuilder: (context, index) => _buildSkeletonItem(),
      );
    }
    
    if (priceFilteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_off_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '조건에 맞는 상품이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 필터 조건을 적용해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategoryIndex = 0;
                  _priceRange = const RangeValues(0, 2000000);
                  _sortOption = 'latest';
                  _showAttributedOnly = false;
                  
                  // Show loading state briefly
                  _isLoading = true;
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  });
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('필터 초기화'),
            ),
          ],
        ),
      );
    }
        
    return RefreshIndicator(
      onRefresh: () async {
        // Show loading state on refresh
        setState(() {
          _isLoading = true;
        });
        
        // Simulate refresh delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        setState(() {
          _isLoading = false;
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: priceFilteredItems.length,
        itemBuilder: (context, index) {
          final item = priceFilteredItems[index];
          return _buildMarketItem(context, item);
        },
      ),
    );
  }

  Widget _buildMarketItem(BuildContext context, MarketItem item) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.images[0],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error_outline, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Location
                      if (item.location != null && item.location!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Price
                      Text(
                        '₩${NumberFormat('#,###').format(item.price)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Interaction stats
                      Row(
                        children: [
                          // Likes
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.likes.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          // Chat count
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.chatCount.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Bookmark button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _bookmarkedItems[item.id] = !(_bookmarkedItems[item.id] ?? false);
                              });
                              
                              // Show temporary snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _bookmarkedItems[item.id] ?? false
                                        ? '찜 목록에 추가되었습니다'
                                        : '찜 목록에서 제거되었습니다',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Icon(
                              _bookmarkedItems[item.id] ?? false
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _bookmarkedItems[item.id] ?? false
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider between items
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildInteractionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    // Format price with thousand separators
    int intPrice = price is double ? price.toInt() : price;
    return intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }
  
  String _formatNumber(double value) {
    // Format with commas for thousands
    final formatter = NumberFormat('#,###');
    return formatter.format(value.toInt());
  }
  
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  void _showSearchScreen() {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.94,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle and search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Search field row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: '찾고 있는 상품을 검색해보세요',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  setSheetState(() {
                                    if (value.isEmpty) {
                                      _searchResults.clear();
                                    } else {
                                      _searchResults = _items
                                          .where((item) => 
                                              item.title.toLowerCase().contains(value.toLowerCase()) ||
                                              item.description.toLowerCase().contains(value.toLowerCase())
                                          )
                                          .toList();
                                    }
                                  });
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty && !_recentSearches.contains(value)) {
                                    setState(() {
                                      _recentSearches.insert(0, value);
                                      if (_recentSearches.length > 10) {
                                        _recentSearches.removeLast();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.onSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(40, 40),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  
                  Expanded(
                    child: _searchController.text.isEmpty
                        ? _buildRecentSearches(setSheetState)
                        : _searchResults.isEmpty
                            ? _buildEmptySearchResults()
                            : _buildSearchResults(_searchResults),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches(StateSetter setSheetState) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setSheetState(() {
                      _recentSearches.clear();
                    });
                    setState(() {});
                  },
                  child: Text('전체 삭제'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        if (_recentSearches.isEmpty)
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                '최근 검색어가 없습니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return Padding(
                padding: EdgeInsets.only(left: 20),
                child: Chip(
                  label: Text(search),
                  deleteIcon: Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setSheetState(() {
                      _recentSearches.remove(search);
                    });
                    setState(() {});
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptySearchResults() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '검색 결과가 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어를 입력해보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<MarketItem> results) {
    final theme = Theme.of(context);
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, endIndent: 16),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
          title: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '₩${_formatNumber(item.price)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.location ?? 'Unknown Location',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: () {
            Navigator.pop(context);
            _openItemDetail(item);
          },
        );
      },
    );
  }

  Widget _buildSkeletonItem() {
    final theme = Theme.of(context);
    
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.dark 
          ? Colors.grey[800]! 
          : Colors.grey[300]!,
      highlightColor: theme.brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Content placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder (2 lines)
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.4,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Location placeholder
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 120,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price placeholder
                  Container(
                    height: 18,
                    width: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  // Interaction stats
                  Row(
                    children: [
                      // Likes
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      // Chat count
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      // Bookmark
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareItem(MarketItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('상품 공유 기능이 준비 중입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _startChat(MarketItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: item.sellerId,
          recipientName: item.sellerName ?? '판매자',
          recipientAvatar: item.sellerAvatar ?? '',
          initialMessage: '${item.title}에 관심이 있습니다. 거래 가능할까요?',
          productInfo: {
            'id': item.id,
            'title': item.title,
            'price': item.price,
            'image': item.images.isNotEmpty ? item.images.first : null,
          },
        ),
      ),
    );
  }
  
  void _callSeller(MarketItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('전화 연결 기능이 준비 중입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Function to get first image from items images array
  String _getFirstImage(MarketItem item) {
    return item.images.isNotEmpty ? item.images.first : '';
  }

  void _openItemDetail(MarketItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
  }
} 