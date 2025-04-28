import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'controllers/restaurant_controller.dart';
import 'controllers/cart_controller.dart';
import 'models/restaurant.dart';
import 'models/menu_item.dart';
import 'models/menu_item_option.dart';
import 'utils/constants.dart';
import 'utils/formatters.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

// Constants for better memory management
const double _kAppBarHeight = 300.0;
const double _kTabBarHeight = 56.0;
const Duration _kAnimationDuration = Duration(milliseconds: 200);
const Duration _kLoadingDelay = Duration(milliseconds: 800);

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> with TickerProviderStateMixin {
  late final RestaurantController _restaurantController;
  late final CartController _cartController;
  Restaurant? _restaurant;
  String _selectedCategory = '';
  bool _isLoading = true;
  
  late final ScrollController _scrollController;
  late final ScrollController _menuScrollController;
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _showFloatingCart = ValueNotifier<bool>(false);
  
  late final AnimationController _cartAnimationController;
  late final Animation<double> _cartAnimation;
  
  // Lazy initialize tab controller
  TabController? _tabController;
  final List<String> _categories = [];
  
  bool _isScrolled = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  
  Map<String, List<MenuItem>> _menuItems = {};
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _onReady();
  }

  void _initializeControllers() {
    _restaurantController = RestaurantController();
    _cartController = CartController();
    // Initialize cart from storage
    _cartController.initialize().then((_) {
      if (mounted) setState(() {});
    });
    
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: EatsConstants.animationDuration,
    );
    _cartAnimation = CurvedAnimation(
      parent: _cartAnimationController,
      curve: Curves.easeInOut,
    );
    
    _scrollController = ScrollController()..addListener(_onScroll);
    _menuScrollController = ScrollController()..addListener(_onMenuScroll);
    
    // Initialize tab controller after getting categories
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }
  
  void _onScroll() {
    // Use header height as threshold
    const double threshold = 200;
    final isScrolled = _scrollController.offset > threshold;
    
    if (_isScrolled != isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
      
      // Update system UI for scrolled state
      _updateSystemUI();
    }
  }
  
  void _onMenuScroll() {
    final showFloating = _menuScrollController.offset > 100;
    if (_showFloatingCart.value != showFloating) {
      _showFloatingCart.value = showFloating;
    }
  }
  
  @override
  void dispose() {
    _cartAnimationController.dispose();
    _scrollController.dispose();
    _menuScrollController.dispose();
    _scrollProgress.dispose();
    _showFloatingCart.dispose();
    _cartController.dispose();
    _fadeController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _onReady() {
    _fetchMenuItems();
    
    // Load the restaurant by ID instead of using widget.restaurant
    _loadRestaurantWithCache();
  }

  Future<void> _loadRestaurantWithCache() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulating network fetch with cached data pattern
      final restaurant = await Future.delayed(
        const Duration(milliseconds: 800),
        () => _restaurantController.getRestaurantById(widget.restaurantId),
      );
      
      if (!mounted) return;
      
      final categories = <String>[];
      final menuItems = _createMockMenuItems();
      
      // Group menu items by category
      final menuItemsByCategory = <String, List<MenuItem>>{};
      for (var item in menuItems) {
        final category = item.category;
        if (!menuItemsByCategory.containsKey(category)) {
          menuItemsByCategory[category] = <MenuItem>[];
        }
        menuItemsByCategory[category]!.add(item);
      }
      
      // Extract unique categories with null safety
      categories.addAll(menuItemsByCategory.keys);
      
      // Initialize tab controller after getting categories
      _tabController = TabController(
        length: categories.length,
        vsync: this,
      );
      
      setState(() {
        _restaurant = restaurant;
        // Safely assign _selectedCategory
        _selectedCategory = menuItemsByCategory.keys.first;
        _categories.addAll(categories);
        _menuItems = menuItemsByCategory;
        _isLoading = false;
      });
      
      // Start animation after data is loaded
      _fadeController.forward();
      
      // Apply optimized system UI
      _updateSystemUI();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load restaurant: $e')),
      );
    }
  }
  
  void _updateSystemUI() {
    // Optimize system UI overlay for better performance
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isScrolled ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));
  }

  void _addToCart(MenuItem item) {
    _cartController.addToCart(item);
    _cartAnimationController.forward(from: 0.0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} 가 장바구니에 추가되었습니다'),
        duration: EatsConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '장바구니 보기',
          onPressed: _showCartBottomSheet,
        ),
      ),
    );
  }

  void _removeFromCart(MenuItem item) {
    _cartController.removeFromCart(item);
    _cartAnimationController.forward(from: 0.0);
  }

  Widget _buildHeader() {
    final restaurant = _restaurant;
    if (restaurant == null) return const SizedBox.shrink();
    
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: _isScrolled ? Theme.of(context).colorScheme.surface : Colors.transparent,
      elevation: _isScrolled ? 4 : 0,
      title: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          restaurant.name,
          style: TextStyle(
            color: _isScrolled ? Theme.of(context).colorScheme.onSurface : Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: _isScrolled ? Theme.of(context).colorScheme.onSurface : Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Use CachedNetworkImage for better performance
            CachedNetworkImage(
              imageUrl: restaurant.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(Icons.error_outline),
              ),
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Restaurant info - positioned for better performance
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    if (_restaurant == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: Color(EatsConstants.starColor),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                EatsFormatters.formatRating(_restaurant!.rating),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${EatsFormatters.formatReviewCount(_restaurant!.reviewCount)})',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            '배달시간 ${_restaurant!.deliveryTime}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.local_shipping_outlined,
            '배달비 ${_restaurant!.deliveryFee}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            _restaurant!.address,
          ),
          if (_restaurant!.businessHours.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule_outlined,
              _restaurant!.businessHours.join('\n'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCategories() {
    if (_restaurant == null) return const SizedBox.shrink();
    
    return Container(
      height: _kTabBarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // Fix null safety issues with the menuCategories
        itemCount: _restaurant?.menuCategories?.keys.length ?? 0,
        itemBuilder: (context, index) {
          // Safely get category with null checks
          final categories = _restaurant?.menuCategories?.keys.toList() ?? [];
          if (categories.isEmpty || index >= categories.length) {
            return const SizedBox.shrink();
          }
          
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            child: TextButton(
              onPressed: () => setState(() => _selectedCategory = category),
              style: TextButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItems() {
    if (_restaurant == null) return const SizedBox.shrink();
    
    return ListView.builder(
      controller: _menuScrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final categoryItems = _menuItems[category] ?? [];
        
        if (categoryItems.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryItems.length,
              itemBuilder: (context, itemIndex) {
                final item = categoryItems[itemIndex];
                final quantity = _cartController.getQuantity(item.id);
                
                return _MenuItem(
                  item: item,
                  quantity: quantity,
                  onAdd: () => _addToCart(item),
                  onRemove: () => _removeFromCart(item),
                  onTap: () => _showItemDetail(item),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildFloatingCart() {
    return AnimatedBuilder(
      animation: _showFloatingCart,
      builder: (context, child) {
        final showFloating = _showFloatingCart.value;
        return AnimatedPositioned(
          duration: EatsConstants.animationDuration,
          right: 20,
          bottom: showFloating ? 20 : -80,
          child: Consumer<CartController>(
            builder: (context, cartController, _) {
              final totalItems = cartController.totalItems;
              if (totalItems == 0) return const SizedBox.shrink();
              
              return FloatingActionButton.extended(
                onPressed: _showCartBottomSheet,
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 4,
                label: Row(
                  children: [
                    Text(
                      '장바구니 보기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        totalItems.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartBottomSheet(
        cartController: _cartController,
        restaurant: _restaurant!,
      ),
    );
  }

  void _showItemDetail(MenuItem item) {
    final quantity = _cartController.getQuantity(item.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${EatsFormatters.formatPrice(item.price)}원',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 0 
                        ? () {
                            _removeFromCart(item);
                            Navigator.pop(context);
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _addToCart(item);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (quantity == 0) {
                    _addToCart(item);
                  }
                  Navigator.pop(context);
                  _showCartBottomSheet();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  quantity > 0 ? '장바구니로 이동' : '장바구니에 추가',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // TODO: Implement favorite functionality
              },
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildInfo(),
              _buildMenuCategories(),
              Expanded(
                child: _buildMenuItems(),
              ),
            ],
          ),
          _buildFloatingCart(),
        ],
      ),
    );
  }

  void _fetchMenuItems() {
    // Simulated fetching of menu items
    setState(() {
      _isLoading = false;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Widget _buildCategoryBar() {
    if (_restaurant == null) return const SizedBox.shrink();
    
    // Extract all menu categories or use empty list if null
    final categories = _menuItems.keys.toList();
    
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<MenuItem> _createMockMenuItems() {
    return [
      MenuItem(
        id: '1',
        name: '불고기',
        description: '맛있는 불고기입니다.',
        price: 15000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '메인',
        isPopular: true,
        options: [
          MenuItemOption(
            id: 'opt1',
            name: '사이즈',
            required: true,
            multiSelect: false,
            items: [
              OptionItem(id: 'size1', name: '소', price: 0),
              OptionItem(id: 'size2', name: '중', price: 3000),
              OptionItem(id: 'size3', name: '대', price: 5000),
            ],
          ),
          MenuItemOption(
            id: 'opt2',
            name: '추가 토핑',
            required: false,
            multiSelect: true,
            items: [
              OptionItem(id: 'top1', name: '치즈', price: 1000),
              OptionItem(id: 'top2', name: '버섯', price: 1500),
              OptionItem(id: 'top3', name: '야채', price: 1000),
            ],
          ),
        ],
      ),
      MenuItem(
        id: '2',
        name: '김치찌개',
        description: '매콤한 김치찌개입니다.',
        price: 12000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '메인',
        options: [
          MenuItemOption(
            id: 'opt1',
            name: '사이즈',
            required: true,
            multiSelect: false,
            items: [
              OptionItem(id: 'size1', name: '1인분', price: 0),
              OptionItem(id: 'size2', name: '2인분', price: 10000),
            ],
          ),
        ],
      ),
      MenuItem(
        id: '3',
        name: '된장찌개',
        description: '구수한 된장찌개입니다.',
        price: 10000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '메인',
      ),
      MenuItem(
        id: '4',
        name: '공기밥',
        description: '뜨끈한 공기밥입니다.',
        price: 1000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '사이드',
      ),
      MenuItem(
        id: '5',
        name: '김치',
        description: '아삭한 김치입니다.',
        price: 1000,
        imageUrl: 'https://via.placeholder.com/150',
        categoryId: '사이드',
      ),
    ];
  }
}

class _MenuItem extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _MenuItem({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0.3 : 1,
                        duration: EatsConstants.animationDuration,
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (item.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              EatsConstants.popularTag,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${EatsFormatters.formatPrice(item.price)}원',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (quantity > 0)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: onRemove,
                                  icon: const Icon(Icons.remove),
                                  iconSize: 18,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: onAdd,
                                  icon: const Icon(Icons.add),
                                  iconSize: 18,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          )
                        else
                          TextButton(
                            onPressed: onAdd,
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              EatsConstants.addToCartText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}

class _CartBottomSheet extends StatelessWidget {
  final CartController cartController;
  final Restaurant restaurant;

  const _CartBottomSheet({
    required this.cartController,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Consumer<CartController>(
                builder: (context, cartController, _) {
                  final items = cartController.items;
                  
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            if (item.imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₩${item.price}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      cartController.removeFromCart(item);
                                    },
                                    icon: const Icon(Icons.remove),
                                    iconSize: 18,
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${item.quantity ?? 0}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cartController.addToCart(item);
                                    },
                                    icon: const Icon(Icons.add),
                                    iconSize: 18,
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
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
              ),
            ),
            const SizedBox(height: 20),
            Consumer<CartController>(
              builder: (context, cartController, _) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총 주문금액',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₩${cartController.totalPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      EatsConstants.cancelText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: cartController.hasItems ? () async {
                      // Place order
                      final success = await cartController.placeOrder();
                      
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? EatsConstants.orderCompleteMessage
                                  : '주문에 실패했습니다. 다시 시도해 주세요.'
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      EatsConstants.orderText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// Add a helper extension for flattening lists
extension IterableExtension<T> on Iterable<Iterable<T>> {
  List<T> get flattened => expand((element) => element).toList();
}

// Add an extension for firstOrNull (outside the class)
extension IterableExtensions<T> on Iterable<T>? {
  T? get firstOrNull {
    if (this == null || this!.isEmpty) return null;
    return this!.first;
  }
}

extension MenuItemExtension on MenuItem {
  String get category => categoryId ?? '기타'; // Default category if not specified
} 