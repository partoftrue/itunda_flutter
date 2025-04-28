import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' show sin, pi;
import 'restaurant_detail_screen.dart';
import 'controllers/cart_controller.dart';
import 'models/restaurant.dart';
import 'utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:itunda/core/components/shimmer_box.dart';
import 'package:itunda/features/eats/controllers/cart_controller.dart';
import 'package:itunda/features/eats/models/restaurant.dart';
import 'package:itunda/features/eats/restaurant_detail_screen.dart';
import 'models/menu_item.dart';

// Constants for better memory management and reusability
const double _kSearchBarHeight = 52.0;
const double _kCategoryBarHeight = 48.0;
const double _kPromotionBannerHeight = 140.0;
const double _kRestaurantItemAspectRatio = 1.6;
const Duration _kAnimationDuration = Duration(milliseconds: 200);
const Duration _kLoadingDelay = Duration(milliseconds: 800);

@immutable
class Restaurant {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final double distance;
  final bool isPromoted;
  final List<String> tags;
  final String imageAttribution;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.distance,
    this.isPromoted = false,
    this.tags = const [],
    this.imageAttribution = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(id, name, category, imageUrl);
}

class EatsHomeScreen extends StatefulWidget {
  const EatsHomeScreen({super.key});

  @override
  State<EatsHomeScreen> createState() => _EatsHomeScreenState();
}

class _EatsHomeScreenState extends State<EatsHomeScreen> with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final CartController _cartController;
  List<String> _searchHistory = [];
  bool _showSearchHistory = false;
  bool _isSearchHistoryLoading = false;
  final _searchFocusNode = FocusNode();
  
  // Add filter states
  bool _showFilters = false;
  final Map<String, bool> _activeFilters = {
    '배달 가능': false,
    '픽업 가능': false,
    '프로모션': false,
    '높은 평점': false,
  };
  
  // Add selected category index
  int _selectedCategoryIndex = 0;
  
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isScrolled = ValueNotifier<bool>(false);
  
  final List<Restaurant> _restaurantList = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  
  static const List<String> _categories = [
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

  Timer? _debounceTimer;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSearchHistory();
    _loadRestaurants();
  }
  
  void _initializeControllers() {
    _searchController = TextEditingController();
    _cartController = CartController();
    _cartController.initialize();
    _searchFocusNode.addListener(_onSearchFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
    
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_loadingController);

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }
  
  void _onScroll() {
    _isScrolled.value = _scrollController.offset > 0;
  }
  
  void _onSearchChanged() {
    _searchQuery.value = _searchController.text;
    _isSearching.value = _searchController.text.isNotEmpty;
    
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();
    
    // Set a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isNotEmpty && _searchController.text.length > 1) {
        _performSearch(_searchController.text);
      }
    });
  }
  
  void _loadRestaurants() async {
    // Simulate loading restaurants
    Future.delayed(_kLoadingDelay, () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generateMockRestaurants();
        });
        _animationController.forward();
      }
    });
  }

  void _generateMockRestaurants() {
    // Generate mock restaurants
    final List<Restaurant> restaurants = List.generate(
      10,
      (index) => Restaurant(
        id: (index + 1).toString(),
        name: 'Restaurant ${index + 1}',
        category: index % 3 == 0 ? '한식' : (index % 3 == 1 ? '일식' : '중식'),
        imageUrl: 'https://picsum.photos/id/${200 + index}/800/400',
        imageAttribution: 'Photo by Lorem Picsum',
        rating: 4.0 + (index % 10) / 10,
        reviewCount: 100 + (index * 10),
        deliveryTime: '${25 + (index * 5)}분',
        deliveryFee: index % 3 == 0 ? '무료' : '${1000 + (index * 500)}원',
        distance: 0.5 + (index * 0.2),
        isPromoted: index % 4 == 0,
        tags: [
          '지역맛집',
          if (index % 2 == 0) '신규',
          if (index % 3 == 0) '단골할인',
          if (index % 5 == 0) '쿠폰',
        ],
      ),
    );
    
    if (mounted) {
      setState(() {
        _restaurantList.addAll(restaurants);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _cartController.dispose();
    _animationController.dispose();
    _loadingController.dispose();
    _scrollController.dispose();
    _isScrolled.dispose();
    _isSearching.dispose();
    _searchQuery.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showSearchHistory = true;
      });
    }
  }
  
  Future<void> _loadSearchHistory() async {
    setState(() {
      _isSearchHistoryLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      
      setState(() {
        _searchHistory = history;
        _isSearchHistoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSearchHistoryLoading = false;
      });
    }
  }
  
  Future<void> _saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = _searchHistory.toList();
      
      // Remove if exists to avoid duplicates
      history.remove(query);
      
      // Add to beginning of list
      history.insert(0, query);
      
      // Limit history to 10 items
      while (history.length > 10) {
        history.removeLast();
      }
      
      await prefs.setStringList('search_history', history);
      
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      // Ignore errors
    }
  }
  
  void _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
      
      setState(() {
        _searchHistory = [];
      });
    } catch (e) {
      // Ignore errors
    }
  }
  
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    _saveSearchQuery(query);
    
    // Reset UI state
    setState(() {
      _showSearchHistory = false;
    });
    
    // TODO: Implement actual search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('검색: $query'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _toggleFilter(String filter) {
    setState(() {
      _activeFilters[filter] = !_activeFilters[filter]!;
    });
    
    // TODO: Apply filters to restaurant list
  }
  
  void _toggleFilterPanel() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getSystemUiOverlayStyle(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isScrolled,
            builder: (context, isScrolled, _) {
              return _buildAppBar(isScrolled);
            },
          ),
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: _isScrolled,
          builder: (context, isScrolled, child) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverPersistentHeader(
                  delegate: _SliverCategoryBarDelegate(
                    child: _buildCategoryBar(),
                    isScrolled: isScrolled,
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(child: _buildPromotionBanner()),
                _buildRestaurantList(),
              ],
            );
          },
        ),
      ),
    );
  }

  SystemUiOverlayStyle _getSystemUiOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SystemUiOverlayStyle(
      statusBarColor: theme.scaffoldBackgroundColor,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: EatsConstants.searchHint,
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _showSearchHistory = true;
                                });
                              },
                            )
                          : null,
                    ),
                    onSubmitted: _performSearch,
                    onChanged: (value) {
                      setState(() {
                        // Show history only when field is empty and focused
                        _showSearchHistory = value.isEmpty && _searchFocusNode.hasFocus;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _activeFilters.values.any((active) => active)
                    ? Theme.of(context).colorScheme.primary
                    : null,
                ),
                onPressed: _toggleFilterPanel,
              ),
            ],
          ),
          if (_showSearchHistory) _buildSearchHistory(),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    final theme = Theme.of(context);
    return Container(
      height: _kCategoryBarHeight,
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: -0.3,
                      ),
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

  Widget _buildRestaurantList() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimatedBuilder(
            animation: _loadingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, sin(_loadingAnimation.value + index) * 2),
                child: child,
              );
            },
            child: _RestaurantItemSkeleton(),
          ),
          childCount: 5,
        ),
      );
    }
    
    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, query, child) {
        final filteredRestaurants = _getFilteredRestaurants(query);
        
        if (filteredRestaurants.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '검색 결과가 없습니다',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '다른 검색어를 입력해보세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == filteredRestaurants.length - 3 && !_isLoadingMore && filteredRestaurants.length >= 10) {
                _loadMoreRestaurants();
              }
              
              final restaurant = filteredRestaurants[index];
              
              return RepaintBoundary(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.05,
                        0.5 + index * 0.05,
                        curve: Curves.easeOut,
                      ),
                    )),
                    child: _RestaurantItem(
                      restaurant: restaurant,
                      onTap: () => _navigateToRestaurantDetail(restaurant),
                    ),
                  ),
                ),
              );
            },
            childCount: filteredRestaurants.length,
          ),
        );
      },
    );
  }

  List<Restaurant> _getFilteredRestaurants(String query) {
    if (query.isEmpty) return _restaurantList;
    
    final lowerCaseQuery = query.toLowerCase();
    return _restaurantList.where((restaurant) {
      return restaurant.name.toLowerCase().contains(lowerCaseQuery) ||
             restaurant.category.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  void _loadMoreRestaurants() {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _generateMockRestaurants();
      
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _navigateToRestaurantDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurantId: restaurant.id,
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isScrolled) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: isScrolled ? 1 : 0,
      centerTitle: false,
      titleSpacing: 20,
      toolbarHeight: 48,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '강남구 역삼동',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onBackground,
            size: 20,
          ),
        ],
      ),
      actions: [
        _buildAppBarActions(),
        _buildOrderHistoryButton(),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      children: [
        // Shopping cart icon with badge
        Badge(
          alignment: AlignmentDirectional.topEnd,
          offset: const Offset(-3, 3),
          label: Text(_cartController.totalItems.toString()),
          isLabelVisible: _cartController.totalItems > 0,
          child: IconButton(
            icon: const Icon(
              Icons.shopping_basket_outlined,
              size: 24,
            ),
            onPressed: () => _showCartBottomSheet(context),
          ),
        ),
        // User profile icon
        IconButton(
          icon: const Icon(
            Icons.person_outline,
            size: 24,
          ),
          onPressed: () => _navigateToProfile(),
        ),
      ],
    );
  }

  Widget _buildOrderHistoryButton() {
    return Badge(
      alignment: AlignmentDirectional.topEnd,
      offset: const Offset(-3, 3),
      label: Text(_cartController.orderHistory.length.toString()),
      isLabelVisible: _cartController.orderHistory.isNotEmpty,
      child: IconButton(
        icon: const Icon(Icons.receipt_long_outlined),
        onPressed: () {
          Navigator.pushNamed(context, '/order-history');
        },
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    if (_cartController.totalItems == 0) {
      // Show empty cart message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('장바구니가 비어있습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartBottomSheet(cartController: _cartController),
    );
  }

  void _navigateToProfile() {
    // TODO: Implement profile navigation
  }

  void _navigateToCheckout() {
    Navigator.of(context).pushNamed('/checkout');
  }

  Widget _buildPromotionBanner() {
    return Container(
      height: _kPromotionBannerHeight,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        padEnds: false,
        children: [
          _buildPromotionCard(
            "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800",
            "신규 가입 프로모션",
            "첫 주문 시 배달비 무료!",
            Colors.orange.shade700,
          ),
          _buildPromotionCard(
            "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
            "추천 맛집 모음",
            "에디터 픽 레스토랑 할인",
            Colors.blue.shade700,
          ),
          _buildPromotionCard(
            "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800",
            "샐러드 전문점",
            "건강한 한 끼 20% 할인",
            Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(String imageUrl, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: _kRestaurantItemAspectRatio,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const ShimmerBox(),
                    errorWidget: (context, url, error) => const Icon(Icons.restaurant, size: 40),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isSearchHistoryLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('최근 검색어가 없습니다'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchHistory.length > 5 ? 5 : _searchHistory.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final query = _searchHistory[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.history),
                          title: Text(query),
                          onTap: () {
                            _searchController.text = query;
                            _performSearch(query);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _searchHistory.removeAt(index);
                              });
                              _saveSearchQuery('');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                if (_searchHistory.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearSearchHistory,
                        child: const Text('전체 삭제'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
  
  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        children: _activeFilters.entries.map((entry) {
          final isActive = entry.value;
          return FilterChip(
            label: Text(entry.key),
            selected: isActive,
            onSelected: (_) => _toggleFilter(entry.key),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
          );
        }).toList(),
      ),
    );
  }

  void _navigateToRecommendations() {
    // Navigate to first restaurant if available
    if (_restaurantList.isNotEmpty) {
      _navigateToRestaurantDetail(_restaurantList.first);
    }
  }
}

class _RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _RestaurantItem({
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: _kRestaurantItemAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: restaurant.imageUrl,
                        placeholder: (context, url) => const ShimmerBox(),
                        errorWidget: (context, url, error) => const Icon(Icons.restaurant, size: 40),
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      if (restaurant.isPromoted)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '프로모션',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4, top: 16, bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          restaurant.rating.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  '${restaurant.deliveryTime} • ${restaurant.deliveryFee}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: _kRestaurantItemAspectRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 140,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SliverCategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isScrolled;

  _SliverCategoryBarDelegate({
    required this.child,
    required this.isScrolled,
  });

  @override
  double get minExtent => _kCategoryBarHeight;

  @override
  double get maxExtent => _kCategoryBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          if (isScrolled)
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.03),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
        ],
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverCategoryBarDelegate oldDelegate) {
    return child != oldDelegate.child || isScrolled != oldDelegate.isScrolled;
  }
}

class _CartBottomSheet extends StatelessWidget {
  final CartController cartController;

  const _CartBottomSheet({required this.cartController});

  void _navigateToCheckout(BuildContext context) {
    Navigator.of(context).pushNamed('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        final cartItems = cartController.items;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Cart header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_basket_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '장바구니 (${cartController.totalItems})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            cartController.clearCart();
                            Navigator.pop(context);
                          },
                          child: const Text('비우기'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Restaurant info
                  if (cartController.restaurant != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            cartController.restaurant!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '배달 ${cartController.restaurant!.deliveryFee}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Cart items list
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _CartItemWidget(
                          item: item,
                          cartController: cartController,
                        );
                      },
                    ),
                  ),
                  // Total price and checkout button
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + mediaQuery.padding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '총액',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₩${_formatNumber(cartController.totalPrice.toInt())}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToCheckout(context);
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('주문하기'),
                          ),
                        ),
                      ],
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _CartItemWidget extends StatelessWidget {
  final MenuItem item;
  final CartController cartController;

  const _CartItemWidget({
    required this.item,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerBox(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              ),
            ),
          )
        else
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.grey),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₩${_formatNumber(item.price)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => cartController.removeFromCart(item),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            Text(
              '${item.quantity ?? 0}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => cartController.addToCart(item),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}