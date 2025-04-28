import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/market_item.dart';
import '../providers/market_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/filter_bar.dart';
import '../utils/formatters.dart';
import 'item_detail_screen.dart';
import 'search_screen.dart';
import 'add_item_screen.dart';

class MarketHomeScreen extends StatefulWidget {
  const MarketHomeScreen({Key? key}) : super(key: key);

  @override
  State<MarketHomeScreen> createState() => _MarketHomeScreenState();
}

class _MarketHomeScreenState extends State<MarketHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFilterSheetOpen = false;
  final List<String> _tabs = ['전체 상품', '내 근처', '북마크'];
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Update state when tab changes
      });
    });

    // Load market items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).loadItems();
      
      // Request focus for keyboard shortcuts
      _keyboardFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  // Add keyboard navigation
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final provider = Provider.of<MarketProvider>(context, listen: false);
      
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // Navigate to next category
        final nextIndex = (provider.selectedCategoryIndex + 1) % provider.categories.length;
        provider.setSelectedCategoryIndex(nextIndex);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // Navigate to previous category
        final prevIndex = (provider.selectedCategoryIndex - 1) % provider.categories.length;
        provider.setSelectedCategoryIndex(prevIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MarketProvider>(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: _handleKeyEvent,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: theme.scaffoldBackgroundColor,
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
            toolbarHeight: 48,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
              IconButton(
                icon: Icon(
                  Icons.copyright_rounded,
                  color: provider.showAttributedOnly 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onBackground.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () {
                  provider.toggleShowAttributedOnly();
                },
                tooltip: 'Show properly attributed items only',
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: _isFilterSheetOpen
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filter items',
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () => _navigateToSearch(),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(49),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // All items tab
              Column(
                children: [
                  _buildFilterBar(provider),
                  _buildTrendingItems(provider),
                  _buildSortBar(provider),
                  Expanded(
                    child: provider.isLoading
                        ? _buildLoadingState()
                        : provider.error.isNotEmpty
                            ? _buildErrorState(provider.error)
                            : _buildMarketList(
                                items: provider.filteredItems,
                                emptyMessage: '조건에 맞는 상품이 없습니다',
                                emptyDescription: '다른 필터 조건을 적용해보세요',
                                emptyIcon: Icons.filter_list_off_rounded,
                              ),
                  ),
                ],
              ),
              // Near Me tab
              Column(
                children: [
                  _buildSortBar(provider),
                  Expanded(
                    child: provider.isLoading
                        ? _buildLoadingState()
                        : provider.error.isNotEmpty
                            ? _buildErrorState(provider.error)
                            : _buildMarketList(
                                items: provider.nearbyItems,
                                emptyMessage: '주변에 있는 상품이 없습니다',
                                emptyDescription: '주변에서 상품을 찾아보세요',
                                emptyIcon: Icons.location_on_rounded,
                                showDistance: true,
                              ),
                  ),
                ],
              ),
              // Bookmarks tab
              Column(
                children: [
                  _buildSortBar(provider),
                  Expanded(
                    child: provider.isLoading
                        ? _buildLoadingState()
                        : provider.error.isNotEmpty
                            ? _buildErrorState(provider.error)
                            : _buildMarketList(
                                items: provider.bookmarkedItems,
                                emptyMessage: '북마크한 상품이 없습니다',
                                emptyDescription: '관심있는 상품을 북마크해보세요',
                                emptyIcon: Icons.bookmark_border_rounded,
                              ),
                  ),
                ],
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
              _navigateToAddItem();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(MarketProvider provider) {
    final sortOptions = {
      'latest': {'label': '최신순', 'icon': Icons.access_time_rounded},
      'price_low': {'label': '가격 낮은순', 'icon': Icons.arrow_upward_rounded},
      'price_high': {'label': '가격 높은순', 'icon': Icons.arrow_downward_rounded},
      'popular': {'label': '인기순', 'icon': Icons.favorite_rounded},
    };
    
    return SortBar(
      selectedOption: provider.sortOption,
      onSortSelected: (option) {
        provider.setSortOption(option);
      },
      sortOptions: sortOptions,
    );
  }

  Widget _buildMarketList({
    required List<MarketItem> items,
    required String emptyMessage,
    required String emptyDescription,
    required IconData emptyIcon,
    bool showDistance = false,
  }) {
    final theme = Theme.of(context);
    final provider = Provider.of<MarketProvider>(context);

    if (provider.isLoading) {
      return Shimmer.fromColors(
        baseColor: theme.brightness == Brightness.dark 
            ? Colors.grey[800]! 
            : Colors.grey[300]!,
        highlightColor: theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[100]!,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100, top: 10),
          itemCount: 6,
          itemBuilder: (context, index) => _buildItemSkeleton(),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              emptyDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }
        
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<MarketProvider>(context, listen: false).loadItems();
      },
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 100, top: 10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MarketItemCard(
            item: item,
            onTap: () => _navigateToDetail(item),
            onBookmarkToggle: (isBookmarked) {
              Provider.of<MarketProvider>(context, listen: false).toggleBookmark(item);
            },
            showDistance: showDistance && item.distanceInKm != null,
          );
        },
        separatorBuilder: (context, index) => SizedBox.shrink(),
      ),
    );
  }

  Widget _buildItemSkeleton() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Content placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 16,
                  width: double.infinity,
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
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                    const Spacer(),
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
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Shimmer.fromColors(
      baseColor: theme.brightness == Brightness.dark 
          ? Colors.grey[800]! 
          : Colors.grey[300]!,
      highlightColor: theme.brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 80),
        itemCount: 6,
        itemBuilder: (context, index) => _buildItemSkeleton(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            '데이터를 불러오는 중 오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<MarketProvider>(context, listen: false).loadItems();
            },
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<MarketProvider>(context, listen: false);
    
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
            RangeValues currentPriceRange = provider.priceRange;
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '필터',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              currentPriceRange = RangeValues(0, 2000000);
                            });
                          },
                          child: Text('초기화'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '가격 범위',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_formatPrice(currentPriceRange.start.toInt())}원',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_formatPrice(currentPriceRange.end.toInt())}원',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        RangeSlider(
                          values: currentPriceRange,
                          min: 0,
                          max: 2000000,
                          divisions: 20,
                          activeColor: theme.colorScheme.primary,
                          labels: RangeLabels(
                            '${_formatPrice(currentPriceRange.start.toInt())}원',
                            '${_formatPrice(currentPriceRange.end.toInt())}원',
                          ),
                          onChanged: (values) {
                            setSheetState(() {
                              currentPriceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: FilledButton(
                      onPressed: () {
                        provider.setPriceRange(currentPriceRange);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('필터 적용하기'),
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  void _navigateToDetail(MarketItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(),
      ),
    );
  }

  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(),
      ),
    );
  }

  // Add the trending items section
  Widget _buildTrendingItems(MarketProvider provider) {
    final theme = Theme.of(context);
    
    // Show shimmer loading effect if trending items are loading
    if (provider.isLoading) {
      return Container(
        padding: EdgeInsets.only(top: 20, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '요즘 뜨는 상품',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 16, right: 8),
                itemCount: 5, // Show 5 shimmer placeholders
                itemBuilder: (context, index) {
                  return _buildTrendingItemSkeleton();
                },
              ),
            ),
          ],
        ),
      );
    }
    
    if (provider.trendingItems.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '요즘 뜨는 상품',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('더보기', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 30),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16, right: 8),
              itemCount: provider.trendingItems.length,
              itemBuilder: (context, index) {
                final item = provider.trendingItems[index];
                return Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _navigateToDetail(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Hero(
                              tag: 'trending-image-${item.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    item.images.isNotEmpty ? item.images.first : '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: theme.colorScheme.surfaceVariant,
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded) return child;
                                      return AnimatedOpacity(
                                        opacity: frame == null ? 0 : 1,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                        child: child,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => provider.toggleBookmark(item),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: item.isBookmarked ? theme.colorScheme.primary : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      color: theme.colorScheme.error,
                                      size: 10,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          Formatters.formatPrice(item.price.toInt()),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (item.timeAgo.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              item.timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingItemSkeleton() {
    final theme = Theme.of(context);
    
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Shimmer.fromColors(
        baseColor: theme.brightness == Brightness.dark 
            ? Colors.grey[800]! 
            : Colors.grey[300]!,
        highlightColor: theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8),
            // Title placeholder
            Container(
              height: 14,
              width: 130,
              color: Colors.white,
            ),
            SizedBox(height: 4),
            // Price placeholder
            Container(
              height: 16,
              width: 80,
              color: Colors.white,
            ),
            SizedBox(height: 4),
            // Time placeholder
            Container(
              height: 10,
              width: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(MarketProvider provider) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip(
                  label: '전체',
                  isSelected: provider.selectedCategory == null,
                  onTap: () => provider.setCategory(null),
                ),
                ...provider.categories.map((category) => _buildFilterChip(
                      label: category.name,
                      isSelected: provider.selectedCategory == category,
                      onTap: () => provider.setCategory(category),
                    )),
              ],
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.sort,
                  label: provider.currentSortLabel,
                  onTap: _showSortOptions,
                ),
                SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.price_change_outlined,
                  label: provider.currentPriceRangeLabel,
                  onTap: _showPriceRangeOptions,
                ),
                SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.filter_alt_outlined,
                  label: '필터',
                  onTap: () {
                    // Show additional filters
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketItemList(MarketProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingShimmer();
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '다른 검색어를 시도해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) => _buildMarketItem(provider.items[index]),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 18,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
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
} 