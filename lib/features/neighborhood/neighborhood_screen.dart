import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_detail_screen.dart';
import 'domain/models/post.dart';
import 'presentation/providers/neighborhood_provider.dart';
import 'post_editor_screen.dart';
import 'widgets/skeleton_loading.dart';
import 'widgets/location_selector.dart';
import 'widgets/badge_label.dart';
import 'widgets/post_card.dart';
import 'widgets/selectable_badge.dart';
import 'widgets/shimmer_loading_image.dart';
import 'widgets/error_retry_widget.dart';
import 'domain/models/category.dart' as neighborhood_models;

class NeighborhoodScreen extends StatefulWidget {
  const NeighborhoodScreen({super.key});

  @override
  State<NeighborhoodScreen> createState() => _NeighborhoodScreenState();
}

class _NeighborhoodScreenState extends State<NeighborhoodScreen> with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  bool _isFabVisible = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _categoryFadeAnimation;
  
  // Add these new variables
  bool _showAnalytics = false;
  String _selectedFilterDistance = '전체';
  final List<String> _distanceFilters = ['전체', '1km 이내', '3km 이내', '5km 이내', '10km 이내'];
  final Map<String, int> _analyticsData = {
    '이웃 소식': 32,
    '동네 질문': 18,
    '동네 맛집': 24,
    '취미 생활': 15,
    '분실/실종': 7,
    '동네 사건사고': 10,
    '해주세요': 14,
  };
  
  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _categoryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Add scroll listener to handle FAB visibility
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
      
      // Load more posts when reaching the end of the list
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
        if (provider.hasMorePosts && provider.status != NeighborhoodStatus.loading) {
          provider.fetchPosts();
        }
      }
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NeighborhoodProvider>(context, listen: false).fetchInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 56,
        automaticallyImplyLeading: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: GestureDetector(
          onTap: () {
            // Open location selector
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const LocationSelector(),
            );
          },
          child: Consumer<NeighborhoodProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.currentLocation,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
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
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.onBackground,
              size: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.colorScheme.onBackground,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NeighborhoodProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostEditorScreen(),
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              '글쓰기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NeighborhoodProvider provider) {
    final status = provider.status;
    
    if (status == NeighborhoodStatus.initial) {
      return _buildLoadingLayout();
    }
    
    if (status == NeighborhoodStatus.error && provider.posts.isEmpty) {
      return ErrorRetryWidget(
        message: '게시물을 불러오는데 실패했습니다.\n${provider.errorMessage}',
        onRetry: () => provider.fetchInitialData(),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await provider.refreshPosts();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildDistanceFilter(provider, Theme.of(context)),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _categoryFadeAnimation,
              child: _buildCategoryTabs(provider),
            ),
          ),
          // Add analytics section
          _showAnalytics ? _buildAnalyticsSection() : const SliverToBoxAdapter(child: SizedBox.shrink()),
          SliverToBoxAdapter(
            child: provider.posts.isEmpty && provider.status != NeighborhoodStatus.loading
              ? _buildEmptyState(Theme.of(context))
              : const SizedBox.shrink(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Show skeleton loading when loading more posts
                if (index == provider.posts.length) {
                  return Column(
                    children: [
                      if (provider.status == NeighborhoodStatus.loading)
                        ...[1, 2].map((_) => const SkeletonPostCard()).toList(),
                      if (provider.hasMorePosts && provider.status != NeighborhoodStatus.loading)
                        SizedBox(
                          height: 80,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }
                
                final post = provider.posts[index];
                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index / 20).clamp(0.0, 1.0),
                      ((index + 1) / 20).clamp(0.0, 1.0),
                      curve: Curves.easeInOut,
                    ),
                  ),
                );
                
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: PostCard(
                      post: post,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                              opacity: animation,
                              child: PostDetailScreen(postId: post.id),
                            ),
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: provider.posts.isEmpty ? 0 :
                provider.posts.length + (provider.hasMorePosts || provider.status == NeighborhoodStatus.loading ? 1 : 0),
            ),
          ),
          if (provider.posts.isEmpty && provider.status != NeighborhoodStatus.loading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '게시물이 없습니다',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '첫 번째 게시물을 작성해보세요!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingLayout() {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildCategoryTabsLoading(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const SkeletonPostCard(),
            childCount: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabsLoading() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SkeletonLoading(
              width: index == 0 ? 50 : 70,
              height: 34,
              borderRadius: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            '아직 게시물이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '첫 번째 게시물을 작성해보세요',
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostEditorScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('글쓰기'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(NeighborhoodProvider provider) {
    final theme = Theme.of(context);
    final categories = provider.categories.isNotEmpty
        ? provider.categories.map((cat) => cat.name).toList()
        : ['전체', '동네질문', '동네소식', '동네맛집', '같이해요', '동네생활', '분실/실종', '해주세요', '일상'];
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = provider.selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SelectableBadge(
              text: category,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategoryIndex = index;
                });
                provider.setSelectedCategory(category);
              },
            ),
          );
        },
      ),
    );
  }

  // Add new distance filter widget
  Widget _buildDistanceFilter(NeighborhoodProvider provider, ThemeData theme) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '거리',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedFilterDistance,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onBackground,
                ),
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onBackground,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFilterDistance = newValue;
                    });
                    // Apply distance filter
                    provider.filterByDistance(_getDistanceValue(newValue));
                  }
                },
                items: _distanceFilters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          // Add analytics toggle
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAnalytics = !_showAnalytics;
              });
            },
            icon: Icon(
              _showAnalytics ? Icons.analytics : Icons.analytics_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              _showAnalytics ? '분석 닫기' : '동네 현황',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Analytics section
  SliverToBoxAdapter _buildAnalyticsSection() {
    final theme = Theme.of(context);
    
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '지난 7일간 동네 활동',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                Text(
                  '총 ${_analyticsData.values.reduce((a, b) => a + b)}개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: _analyticsData.entries.map((entry) {
                    final percentage = entry.value / _analyticsData.values.reduce((a, b) => a + b) * 100;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                '${entry.value}개',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Stack(
                            children: [
                              Container(
                                width: constraints.maxWidth,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: constraints.maxWidth * (percentage / 100),
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert filter text to actual distance value
  double? _getDistanceValue(String filter) {
    switch (filter) {
      case '1km 이내':
        return 1.0;
      case '3km 이내':
        return 3.0;
      case '5km 이내':
        return 5.0;
      case '10km 이내':
        return 10.0;
      case '전체':
      default:
        return null; // No filter
    }
  }
} 