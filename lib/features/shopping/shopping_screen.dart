import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Product model for shopping items
class ShoppingProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int discountPercentage;
  final double rating;
  final int reviewCount;
  final String seller;
  final bool isFreeShipping;
  final bool isExpress;
  final String category;
  final bool isNew;
  
  ShoppingProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountPercentage = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.seller,
    this.isFreeShipping = false,
    this.isExpress = false,
    required this.category,
    this.isNew = false,
  });
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  bool _isScrolled = false;
  late TabController _tabController;
  int _currentBannerIndex = 0;
  bool _isLoading = false;
  
  // Add timer for countdown
  int _remainingSeconds = 3600; // 1 hour
  
  // Sample product data
  final List<ShoppingProduct> _flashDeals = [
    ShoppingProduct(
      id: 'p1',
      name: '프리미엄 블루투스 이어폰',
      imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800',
      price: 59000,
      originalPrice: 129000,
      discountPercentage: 54,
      rating: 4.7,
      reviewCount: 254,
      seller: '오디오샵',
      isFreeShipping: true,
      isExpress: true,
      category: '전자제품',
      isNew: true,
    ),
    ShoppingProduct(
      id: 'p2',
      name: '향균 세탁 세제 대용량 3.5L',
      imageUrl: 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=800',
      price: 12900,
      originalPrice: 21000,
      discountPercentage: 38,
      rating: 4.9,
      reviewCount: 1245,
      seller: '생활마트',
      isFreeShipping: true,
      category: '생활용품',
    ),
    ShoppingProduct(
      id: 'p3',
      name: '프리미엄 면 베개 세트',
      imageUrl: 'https://images.unsplash.com/photo-1629949009765-718043e02062?w=800',
      price: 32000,
      originalPrice: 45000,
      discountPercentage: 29,
      rating: 4.8,
      reviewCount: 521,
      seller: '홈데코',
      category: '가구/인테리어',
    ),
    ShoppingProduct(
      id: 'p4',
      name: '올인원 멀티 비타민 영양제',
      imageUrl: 'https://images.unsplash.com/photo-1584362917165-526a968579e8?w=800',
      price: 28000,
      originalPrice: 42000,
      discountPercentage: 33,
      rating: 4.6,
      reviewCount: 682,
      seller: '건강마켓',
      isFreeShipping: true,
      category: '건강식품',
    ),
    ShoppingProduct(
      id: 'p5',
      name: '스마트 무선 충전기',
      imageUrl: 'https://images.unsplash.com/photo-1574944985070-8f3ebc6b79d2?w=800',
      price: 24500,
      originalPrice: 35000,
      discountPercentage: 30,
      rating: 4.5,
      reviewCount: 423,
      seller: '테크몰',
      isFreeShipping: true,
      isExpress: true,
      category: '전자제품',
    ),
  ];
  
  final List<ShoppingProduct> _recommendations = [
    ShoppingProduct(
      id: 'r1',
      name: '프리미엄 가죽 백팩',
      imageUrl: 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=800',
      price: 89000,
      rating: 4.8,
      reviewCount: 154,
      seller: '레더샵',
      isFreeShipping: true,
      category: '패션/잡화',
      isNew: true,
    ),
    ShoppingProduct(
      id: 'r2',
      name: '유기농 스킨케어 세트',
      imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=800',
      price: 68000,
      originalPrice: 85000,
      discountPercentage: 20,
      rating: 4.9,
      reviewCount: 320,
      seller: '오가닉뷰티',
      category: '뷰티',
    ),
    ShoppingProduct(
      id: 'r3',
      name: '스마트 체중계',
      imageUrl: 'https://images.unsplash.com/photo-1576155934049-a5a42e43ff2e?w=800',
      price: 45000,
      rating: 4.7,
      reviewCount: 275,
      seller: '스마트라이프',
      isExpress: true,
      category: '전자제품',
    ),
    ShoppingProduct(
      id: 'r4',
      name: '퀼팅 침대 패드',
      imageUrl: 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=800',
      price: 49900,
      originalPrice: 69000,
      discountPercentage: 28,
      rating: 4.8,
      reviewCount: 189,
      seller: '베딩스토어',
      isFreeShipping: true,
      category: '가구/인테리어',
    ),
    ShoppingProduct(
      id: 'r5',
      name: '프리미엄 사무용 의자',
      imageUrl: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=800',
      price: 159000,
      originalPrice: 199000,
      discountPercentage: 20,
      rating: 4.9,
      reviewCount: 425,
      seller: '오피스마트',
      category: '가구/인테리어',
    ),
  ];
  
  // Promotion banners
  final List<Map<String, dynamic>> _promotionBanners = [
    {
      'title': '여름 쇼핑 특가',
      'subtitle': '인기 여름 상품 최대 50% 할인',
      'color': Colors.blue,
      'iconData': Icons.wb_sunny,
    },
    {
      'title': '신규 고객 혜택',
      'subtitle': '첫 구매 시 15% 추가 할인',
      'color': Colors.green,
      'iconData': Icons.card_giftcard,
    },
    {
      'title': '무료 배송 이벤트',
      'subtitle': '오늘만 전 상품 무료 배송',
      'color': Colors.orange,
      'iconData': Icons.local_shipping,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    
    // Add scroll listener to track scroll position
    _scrollController.addListener(() {
      if (_scrollController.offset > 10 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 10 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
    
    // Simulate loading data
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate network delay
    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: _isScrolled ? 1 : 0,
        title: Text(
          '쇼핑',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onBackground),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.colorScheme.onBackground),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(theme)
          : RefreshIndicator(
              onRefresh: () async {
                _loadData();
                return Future.delayed(Duration(milliseconds: 1200));
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategories(context),
                    _buildPromoBanner(context),
                    _buildFlashDealSection(context),
                    const SizedBox(height: 16),
                    _buildRecommendationSection(context),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            '쇼핑 정보를 불러오는 중...',
            style: TextStyle(
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ['모두', '특가', '식품', '의류', '전자제품', '뷰티'];
    
    return Container(
      height: 60,
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.6),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final theme = Theme.of(context);
    final banner = _promotionBanners[_currentBannerIndex];
    
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            banner['color'].withOpacity(0.8),
            banner['color'].withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: banner['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner['subtitle'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              banner['iconData'],
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashDealSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 특가',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildCountdownTimer(theme),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _flashDeals.length,
            itemBuilder: (context, index) {
              return _buildFlashDealItem(_flashDeals[index], theme);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCountdownTimer(ThemeData theme) {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;
    
    return Row(
      children: [
        _buildTimeDigit(hours.toString().padLeft(2, '0'), theme),
        Text(':', style: TextStyle(color: theme.colorScheme.primary)),
        _buildTimeDigit(minutes.toString().padLeft(2, '0'), theme),
        Text(':', style: TextStyle(color: theme.colorScheme.primary)),
        _buildTimeDigit(seconds.toString().padLeft(2, '0'), theme),
      ],
    );
  }
  
  Widget _buildTimeDigit(String digits, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        digits,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
  
  Widget _buildFlashDealItem(ShoppingProduct product, ThemeData theme) {
    return Container(
      width: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              if (product.discountPercentage > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.discountPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              if (product.isNew)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${_formatPrice(product.price)}원',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${_formatPrice(product.originalPrice!)}',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (product.rating > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating} (${product.reviewCount})',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '추천 상품',
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            return _buildRecommendationItem(_recommendations[index], theme);
          },
        ),
      ],
    );
  }
  
  Widget _buildRecommendationItem(ShoppingProduct product, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              if (product.discountPercentage > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.discountPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.seller,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${_formatPrice(product.price)}원',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${product.discountPercentage}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.isFreeShipping)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '무료배송',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    if (product.isFreeShipping && product.isExpress)
                      const SizedBox(width: 4),
                    if (product.isExpress)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          '당일배송',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
} 