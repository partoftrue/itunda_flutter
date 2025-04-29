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
import 'domain/models/category.dart';
import 'domain/constants/neighborhood_categories.dart';
import 'widgets/category_circle.dart';
import 'widgets/location_filter_bar.dart';
import '../../core/providers/location_provider.dart';
import 'screens/location_selector_screen.dart';

class NeighborhoodScreen extends StatefulWidget {
  const NeighborhoodScreen({super.key});

  @override
  State<NeighborhoodScreen> createState() => _NeighborhoodScreenState();
}

class _NeighborhoodScreenState extends State<NeighborhoodScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isFabVisible = true;
  bool _showAnalytics = false;
  String _selectedDistance = '전체';
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _categoryFadeAnimation;
  
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

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
    await provider.refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.background : Colors.white,
      body: Column(
        children: [
          // Category circles
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: NeighborhoodCategories.categories.length,
              itemBuilder: (context, index) {
                final category = NeighborhoodCategories.categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < NeighborhoodCategories.categories.length - 1 ? 24 : 0,
                  ),
                  child: CategoryCircle(
                    category: category,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Handle category tap
                    },
                  ),
                );
              },
            ),
          ),
          // Location filter
          LocationFilterBar(
            selectedLocation: Provider.of<NeighborhoodProvider>(context).currentLocation,
            selectedCategory: NeighborhoodCategories.categories[_selectedIndex],
            categories: NeighborhoodCategories.categories,
            onCategorySelected: (category) {
              if (category != null) {
                setState(() {
                  _selectedIndex = NeighborhoodCategories.categories.indexOf(category);
                });
              }
            },
            onLocationTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSelectorScreen(),
                ),
              );
            },
          ),
          // Filter tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.background : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Consumer<NeighborhoodProvider>(
                builder: (context, provider, child) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        SelectableBadge(
                          label: '추천',
                          isSelected: _selectedIndex == 0,
                          onTap: () => _onFilterTap(0),
                        ),
                        const SizedBox(width: 8),
                        SelectableBadge(
                          label: '인기',
                          isSelected: _selectedIndex == 1,
                          onTap: () => _onFilterTap(1),
                          icon: Icons.local_fire_department_rounded,
                          iconColor: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        SelectableBadge(
                          label: '동네행사',
                          isSelected: _selectedIndex == 2,
                          onTap: () => _onFilterTap(2),
                        ),
                        const SizedBox(width: 8),
                        SelectableBadge(
                          label: '맛집',
                          isSelected: _selectedIndex == 3,
                          onTap: () => _onFilterTap(3),
                        ),
                        const SizedBox(width: 8),
                        SelectableBadge(
                          label: '반려동물',
                          isSelected: _selectedIndex == 4,
                          onTap: () => _onFilterTap(4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Post list
          Expanded(
            child: Consumer2<NeighborhoodProvider, LocationProvider>(
              builder: (context, provider, locationProvider, child) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  strokeWidth: 2.5,
                  displacement: 80,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    slivers: [
                      _buildPostList(provider),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostEditorScreen(),
                ),
              );
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: isDark ? Colors.white : Colors.white,
            elevation: 2,
            shape: const CircleBorder(),
            child: const Icon(Icons.edit_rounded, size: 24),
          ),
        ),
      ),
    );
  }

  void _onFilterTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  Widget _buildPostList(NeighborhoodProvider provider) {
    if (provider.posts.isEmpty && provider.status != NeighborhoodStatus.loading) {
      return SliverFillRemaining(
        child: _buildEmptyState(Theme.of(context)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == provider.posts.length) {
            return _buildLoadingIndicator(provider);
          }

          final post = provider.posts[index];
          return FadeTransition(
            opacity: _categoryFadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(_categoryFadeAnimation),
              child: PostCard(
                post: post,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FadeTransition(
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
        childCount: provider.posts.length + (provider.hasMorePosts || provider.status == NeighborhoodStatus.loading ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingIndicator(NeighborhoodProvider provider) {
    return Column(
      children: [
        if (provider.status == NeighborhoodStatus.loading)
          ...[1, 2].map((_) => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const SkeletonPostCard(),
              );
            },
          )).toList(),
        if (provider.hasMorePosts && provider.status != NeighborhoodStatus.loading)
          SizedBox(
            height: 80,
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
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
} 