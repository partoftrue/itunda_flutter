import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'dashboard_widget.dart';
import '../marketplace/market_screen.dart';
import '../marketplace/models/market_item.dart';
import '../jobs/jobs_screen.dart';
import '../eats/eats_home_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;
  late AnimationController _animationController;
  
  // Get time-based greeting
  String get _timeBasedGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요';
    } else if (hour < 17) {
      return '안녕하세요';
    } else {
      return '좋은 저녁이에요';
    }
  }
  
  // Add notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'title': '신용카드 결제 예정',
      'message': '신한카드 결제일이 3일 남았습니다.',
      'time': '1시간 전',
      'isNew': true,
    },
    {
      'icon': Icons.trending_up,
      'color': Colors.green,
      'title': '금융 인사이트',
      'message': '이번 달 지출이 평소보다 15% 감소했습니다!',
      'time': '오늘',
      'isNew': true,
    },
    {
      'icon': Icons.local_offer,
      'color': Colors.orange,
      'title': '맞춤 혜택',
      'message': '자주 이용하는 가맹점 할인 쿠폰이 도착했습니다',
      'time': '어제',
      'isNew': false,
    },
  ];

  // Add marketplace items list
  final List<MarketItem> _marketplaceItems = [
    MarketItem(
      id: '1',
      sellerId: 'seller1',
      title: '아이폰 13 프로 128GB 그래파이트',
      description: '아이폰 13 프로 128GB 그래파이트 색상입니다. 구매 후 1개월 사용했으며 상태 좋습니다. 기스 없이 깨끗합니다.',
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
    ),
  ];

  // Add community activity data
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'post',
      'userName': '동네주민123',
      'title': '배달 오토바이 소음 문제',
      'time': '10분 전',
      'category': '동네질문',
      'replyCount': 8,
      'icon': Icons.help_outline,
      'color': Colors.orange,
    },
    {
      'type': 'event',
      'userName': '동네모임',
      'title': '주말 공원 청소 봉사활동',
      'time': '1시간 전',
      'category': '동네소식',
      'participantCount': 12,
      'icon': Icons.event_note,
      'color': Colors.green,
    },
    {
      'type': 'review',
      'userName': '맛집탐험가',
      'title': '역삼동 새로 생긴 카페',
      'time': '3시간 전',
      'category': '동네맛집',
      'likeCount': 24,
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
  ];

  // Add mock weather data
  final Map<String, dynamic> _weatherData = {
    'location': '강남구 역삼동',
    'currentTemp': 24,
    'weatherStatus': '맑음',
    'weatherIcon': Icons.wb_sunny_outlined,
    'minTemp': 19,
    'maxTemp': 26,
    'humidity': 45,
    'windSpeed': '3m/s',
    'forecast': [
      {
        'day': '오늘',
        'icon': Icons.wb_sunny_outlined,
        'maxTemp': 26,
        'minTemp': 19,
      },
      {
        'day': '내일',
        'icon': Icons.cloud_outlined,
        'maxTemp': 25,
        'minTemp': 18,
      },
      {
        'day': '수',
        'icon': Icons.water_drop_outlined,
        'maxTemp': 23,
        'minTemp': 17,
      },
      {
        'day': '목',
        'icon': Icons.cloudy_snowing,
        'maxTemp': 22, 
        'minTemp': 16,
      },
      {
        'day': '금',
        'icon': Icons.wb_sunny_outlined,
        'maxTemp': 24,
        'minTemp': 18,
      },
    ],
  };

  // Add Today's Deals data
  final List<Map<String, dynamic>> _todaysDeals = [
    {
      'id': 'd1',
      'title': '한정판 스니커즈 30% 할인',
      'shop': '스포츠마켓',
      'originalPrice': 89000,
      'discountPrice': 62300,
      'discountPercent': 30,
      'imageUrl': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=500',
      'color': Colors.blue,
      'expiryTime': '오늘 마감',
    },
    {
      'id': 'd2',
      'title': '유기농 채소 박스 첫 주문 50% 할인',
      'shop': '동네마켓',
      'originalPrice': 32000,
      'discountPrice': 16000,
      'discountPercent': 50,
      'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      'color': Colors.green,
      'expiryTime': '3일 남음',
    },
    {
      'id': 'd3',
      'title': '스마트워치 신제품 출시 기념 15% 할인',
      'shop': '가전랜드',
      'originalPrice': 199000,
      'discountPrice': 169150,
      'discountPercent': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=500',
      'color': Colors.purple,
      'expiryTime': '24시간 남음',
    },
  ];

  // Add neighborhood events data
  final List<Map<String, dynamic>> _neighborhoodEvents = [
    {
      'id': 'e1',
      'title': '동네 벼룩시장',
      'location': '강남구 역삼동 공원',
      'date': DateTime.now().add(Duration(days: 2)),
      'startTime': '10:00',
      'endTime': '16:00',
      'category': '장터',
      'organizer': '역삼동 주민회',
      'participantCount': 32,
      'image': 'https://images.unsplash.com/photo-1506706435692-290e0c5b4505?w=500',
      'color': Colors.orange,
    },
    {
      'id': 'e2',
      'title': '공원 청소 봉사활동',
      'location': '강남구 역삼동 근린공원',
      'date': DateTime.now().add(Duration(days: 5)),
      'startTime': '09:00',
      'endTime': '12:00',
      'category': '봉사활동',
      'organizer': '그린 커뮤니티',
      'participantCount': 18,
      'image': 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=500',
      'color': Colors.green,
    },
    {
      'id': 'e3',
      'title': '동네 독서모임',
      'location': '역삼동 카페 북스페이스',
      'date': DateTime.now().add(Duration(days: 7)),
      'startTime': '19:00',
      'endTime': '21:00',
      'category': '취미모임',
      'organizer': '책읽는 이웃들',
      'participantCount': 12,
      'image': 'https://images.unsplash.com/photo-1521056787327-266200e66e17?w=500',
      'color': Colors.blue,
    },
    {
      'id': 'e4',
      'title': '반려동물 산책 번개모임',
      'location': '역삼동 공원 분수대 앞',
      'date': DateTime.now().add(Duration(hours: 26)),
      'startTime': '17:00',
      'endTime': '18:30',
      'category': '번개모임',
      'organizer': '강남 애견인 모임',
      'participantCount': 8,
      'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=500',
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_showDivider) {
        setState(() {
          _showDivider = true;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_showDivider) {
        setState(() {
          _showDivider = false;
        });
      }
    }
  }

  // Add method to simulate refresh of data
  Future<void> _refreshData() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() {
      // Update weather data with simulated changes
      _weatherData['currentTemp'] = (_weatherData['currentTemp'] as int) + (math.Random().nextBool() ? 1 : -1);
      
      // Shuffle today's deals
      _todaysDeals.shuffle();
      
      // Shuffle marketplace items
      _marketplaceItems.shuffle();
      
      // Shuffle recent activities
      _recentActivities.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: _showDivider ? Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.2),
                width: 1,
              ),
            ) : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 20,
            toolbarHeight: 48,
            automaticallyImplyLeading: false,
            systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            title: AnimatedOpacity(
              opacity: _showDivider ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                '이툰다',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      _showNotificationPanel(context);
                    },
                  ),
                  if (_hasNewNotifications())
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            bottom: null,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom pull-to-refresh indicator
                CupertinoSliverRefreshControl(
                  refreshTriggerPullDistance: 100.0,
                  refreshIndicatorExtent: 60.0,
                  onRefresh: _refreshData,
                  builder: (
                    BuildContext context,
                    RefreshIndicatorMode refreshState,
                    double pulledExtent,
                    double refreshTriggerPullDistance,
                    double refreshIndicatorExtent,
                  ) {
                    final theme = Theme.of(context);
                    final percentComplete = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
                    
                    return Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating refresh icon for pull animation
                            if (refreshState != RefreshIndicatorMode.refresh &&
                                refreshState != RefreshIndicatorMode.armed)
                              Transform.rotate(
                                angle: 2 * math.pi * percentComplete,
                                child: Icon(
                                  Icons.refresh,
                                  color: theme.colorScheme.primary.withOpacity(0.7),
                                  size: 24,
                                ),
                              ),
                            
                            // Progress indicator for active refresh
                            if (refreshState == RefreshIndicatorMode.refresh ||
                                refreshState == RefreshIndicatorMode.armed)
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Large Welcome Header - Toss style
                SliverToBoxAdapter(
                  child: _buildTossWelcomeHeader(context),
                ),
                // Add weather widget
                SliverToBoxAdapter(
                  child: _buildWeatherWidget(context),
                ),
                // Add story section after weather widget
                SliverToBoxAdapter(
                  child: _buildStorySection(context),
                ),
                // Smart notifications
                SliverToBoxAdapter(
                  child: _buildSmartNotifications(context),
                ),
                // Main Balance Card
                SliverToBoxAdapter(
                  child: _buildCommunityHighlights(context),
                ),
                // Add new recent activity section
                SliverToBoxAdapter(
                  child: _buildRecentActivitySection(context),
                ),
                // Add neighborhood events section
                SliverToBoxAdapter(
                  child: _buildNeighborhoodEventsSection(context),
                ),
                // Quick Access Buttons - Toss style
                SliverToBoxAdapter(
                  child: _buildQuickAccessButtons(context),
                ),
                // Services Section
                SliverToBoxAdapter(
                  child: _buildTossServicesSection(context),
                ),
                // Popular Communities
                SliverToBoxAdapter(
                  child: _buildPopularCommunities(context),
                ),
                // Nearby Activities
                SliverToBoxAdapter(
                  child: _buildNearbyActivities(context),
                ),
                // Add marketplace items section
                SliverToBoxAdapter(
                  child: _buildMarketplaceSection(context),
                ),
                // Add today's deals section
                SliverToBoxAdapter(
                  child: _buildTodaysDealsSection(context),
                ),
                // Promotion Section
                SliverToBoxAdapter(
                  child: _buildTossPromotions(context),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
          // Floating balance card
        ],
      ),
    );
  }

  // Update the welcome header method with dynamic greeting
  Widget _buildTossWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _timeBasedGreeting,
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'TUYIZERE ERIC',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '님',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 활기찬 동네 생활을 시작하세요!',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Community Highlights Card (replacing balance card)
  Widget _buildCommunityHighlights(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '우리 동네 둘러보기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '강남구',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Active community stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘 동네생활',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: 128),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                        Text(
                          '개',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '24%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Divider(height: 1, color: theme.dividerColor),
          
          // Quick actions for community
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCommunityQuickAction('동네생활', Icons.people_outline, Colors.orange, theme),
                _buildCommunityQuickAction('동네마켓', Icons.storefront_outlined, Colors.green, theme),
                _buildCommunityQuickAction('동네톡', Icons.chat_outlined, Colors.blue, theme),
                _buildCommunityQuickAction('게시판', Icons.article_outlined, Colors.purple, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunityQuickAction(String label, IconData icon, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Modified Quick access buttons to focus on main services
  Widget _buildQuickAccessButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 0, 16),
          child: Text(
            '주요 서비스',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTossServiceCard('동네생활', Icons.people_outline, Colors.orange, context, () {
                Navigator.pushNamed(context, '/neighborhood');
              }),
              _buildTossServiceCard('동네마켓', Icons.storefront_outlined, Colors.green, context, () {
                Navigator.pushNamed(context, '/marketplace');
              }),
              _buildTossServiceCard('동네알바', Icons.work_outline, Colors.blue, context, () {
                Navigator.pushNamed(context, '/jobs');
              }),
              _buildTossServiceCard('이츠', Icons.restaurant_outlined, Colors.red, context, () {
                Navigator.pushNamed(context, '/eats');
              }),
              _buildTossServiceCard('쇼핑', Icons.shopping_bag_outlined, Colors.purple, context, () {
                Navigator.pushNamed(context, '/shopping');
              }),
              _buildTossServiceCard('동네톡', Icons.chat_bubble_outline, Colors.amber, context, () {
                Navigator.pushNamed(context, '/chat');
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Modified service card with callback parameter
  Widget _buildTossServiceCard(String label, IconData icon, Color color, BuildContext context, [VoidCallback? onTap]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 90,
      height: 100, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use min size
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42, // Slightly smaller
                  height: 42, // Slightly smaller
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22, // Slightly smaller
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1, // Limit to 1 line
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modified services section to focus on community features
  Widget _buildTossServicesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '추천 서비스',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '전체보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Row 1
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTossServiceTile(
                      '동네생활',
                      Icons.people_outline,
                      Colors.orange,
                      '우리동네 소식 알아보기',
                      () => Navigator.pushNamed(context, '/neighborhood'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTossServiceTile(
                      '동네마켓',
                      Icons.storefront_outlined,
                      Colors.green,
                      '중고거래 시작하기',
                      () => Navigator.pushNamed(context, '/marketplace'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTossServiceTile(
                      '이츠',
                      Icons.restaurant_outlined,
                      Colors.red,
                      '맛있는 음식 빠르게',
                      () => Navigator.pushNamed(context, '/eats'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildTossServiceTile(
                      '동네알바',
                      Icons.work_outline,
                      Colors.blue,
                      '내 주변 일자리 찾기',
                      () => Navigator.pushNamed(context, '/jobs'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Modified service tile with callback parameter
  Widget _buildTossServiceTile(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    [VoidCallback? onTap]
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      height: 120, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min size
            children: [
              Container(
                width: 38, // Slightly smaller
                height: 38, // Slightly smaller
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20, // Slightly smaller
                ),
              ),
              const SizedBox(height: 8), // Less spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: 14, // Smaller font
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1, // Limit lines
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12, // Smaller font
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1, // Limit lines
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New Popular Communities Section
  Widget _buildPopularCommunities(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            '인기 동네생활',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCommunityPostCard(
                '맛집 추천해주세요',
                '강남역 근처에 점심 먹기 좋은 맛집 추천 부탁드려요. 혼자 먹기 좋은 곳이면 더 좋겠어요!',
                '10분 전',
                Icons.restaurant,
                Colors.redAccent,
                32,
                14,
                context,
              ),
              _buildCommunityPostCard(
                '길고양이에게 밥을 주면 안되나요?',
                '아파트 단지에 길고양이들이 많은데, 밥을 주면 안된다고 하시는 분들이 계셔서요. 다른 분들은 어떻게 생각하시나요?',
                '1시간 전',
                Icons.pets,
                Colors.amber,
                48,
                22,
                context,
              ),
              _buildCommunityPostCard(
                '헬스장 추천해주세요',
                '이사 온 지 얼마 안 됐는데 동네에 괜찮은 헬스장 있을까요? 24시간 운영하는 곳이면 더 좋겠어요.',
                '3시간 전',
                Icons.fitness_center,
                Colors.blue,
                19,
                7,
                context,
              ),
              _buildCommunityPostCard(
                '플리마켓 함께 하실 분!',
                '이번 주말에 강남역 근처에서 열리는 플리마켓에 참여하실 분 있으신가요? 수공예품을 판매할 예정입니다.',
                '5시간 전',
                Icons.shopping_bag,
                Colors.green,
                26,
                9,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCommunityPostCard(
    String title,
    String content,
    String time,
    IconData icon,
    Color color,
    int commentCount,
    int likeCount,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/neighborhood/post');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '동네질문',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commentCount.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likeCount.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New Nearby Activities Section
  Widget _buildNearbyActivities(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Text(
            '내 주변 인기 활동',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildActivityCard(
                '주말 러닝 메이트',
                '매주 토요일 오전 7시',
                Icons.directions_run,
                Colors.blue,
                context,
              ),
              _buildActivityCard(
                '사진 동호회',
                '월 2회 정기 모임',
                Icons.camera_alt,
                Colors.purple,
                context,
              ),
              _buildActivityCard(
                '보드게임 모임',
                '매주 금요일 저녁',
                Icons.sports_esports,
                Colors.orange,
                context,
              ),
              _buildActivityCard(
                '독서 토론회',
                '격주 수요일 저녁',
                Icons.menu_book,
                Colors.teal,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivityCard(
    String title,
    String schedule,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 140,
      height: 160, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced padding
            child: SingleChildScrollView( // Make content scrollable to handle potential overflow
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use min size instead of center alignment
                children: [
                  Container(
                    width: 48, // Reduced size
                    height: 48, // Reduced size
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24, // Reduced size
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule,
                    style: TextStyle(
                      fontSize: 12, // Reduced font size
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [Color(0xFF1A237E), Color(0xFF303F9F)]
              : [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weather
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _weatherData['location'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData['currentTemp']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '°C',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _weatherData['weatherStatus'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '최저 ${_weatherData['minTemp']}° / 최고 ${_weatherData['maxTemp']}°',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _weatherData['weatherIcon'],
                  color: Colors.white,
                  size: 80,
                ),
              ],
            ),
          ),
          
          // Weather details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather details
                Row(
                  children: [
                    _buildWeatherDetailItem(
                      Icons.water_drop_outlined, 
                      '습도', 
                      '${_weatherData['humidity']}%'
                    ),
                    const SizedBox(width: 24),
                    _buildWeatherDetailItem(
                      Icons.air, 
                      '풍속', 
                      _weatherData['windSpeed']
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Forecast
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final day in _weatherData['forecast'])
                        _buildForecastItem(day),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 18,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForecastItem(Map<String, dynamic> forecast) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            forecast['day'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            forecast['icon'],
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${forecast['minTemp']}°',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${forecast['maxTemp']}°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartNotifications(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_notifications.isEmpty || !_hasNewNotifications()) {
      return const SizedBox.shrink();
    }
    
    // Find the first new notification
    final newNotification = _notifications.firstWhere(
      (notification) => notification['isNew'] == true,
      orElse: () => _notifications.first,
    );
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showNotificationPanel(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (newNotification['color'] as Color).withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    newNotification['icon'] as IconData,
                    color: newNotification['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newNotification['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        newNotification['message'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasNewNotifications() {
    return _notifications.any((notification) => notification['isNew'] == true);
  }
  
  void _showNotificationPanel(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '알림',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '모두 읽음',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List of notifications
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    color: theme.dividerColor.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification, theme);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildNotificationItem(Map<String, dynamic> notification, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (notification['color'] as Color).withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: notification['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      notification['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (notification['isNew'] as bool)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Toss-style promotions with dark mode support
  Widget _buildTossPromotions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Text(
            '혜택',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPromotionItem(
                '신규 가입 혜택',
                '첫 거래 시 3,000원 캐시백',
                isDark ? Colors.blue.shade600 : Colors.blue.shade700,
                context,
                'assets/images/promo1.jpg',
              ),
              _buildPromotionItem(
                '7월 쇼핑 혜택',
                '최대 5% 할인 + 추가 캐시백',
                isDark ? Colors.purple.shade600 : Colors.purple.shade700,
                context,
                'assets/images/promo2.jpg',
              ),
              _buildPromotionItem(
                '여름 시즌 프로모션',
                '한정 기간 특별 할인',
                isDark ? Colors.orange.shade600 : Colors.orange.shade700,
                context,
                'assets/images/promo3.jpg',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPromotionItem(
    String title,
    String subtitle,
    Color color,
    BuildContext context,
    String? imagePath,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 280,
      height: 150, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? color.withOpacity(0.4) : color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Stack(
            children: [
              // Background image with overlay
              if (imagePath != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: isDark ? 0.15 : 0.2,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Placeholder in case image is not found
                          return Container(
                            color: Colors.transparent,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Use min size
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Smaller font size
                        ),
                        maxLines: 1, // Limit lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Smaller font size
                        height: 1.3,
                      ),
                      maxLines: 2, // Limit to 2 lines
                      overflow: TextOverflow.ellipsis,
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

  // Add new method to build the marketplace section
  Widget _buildMarketplaceSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '우리 동네 중고거래',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/marketplace'),
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _marketplaceItems.length,
            itemBuilder: (context, index) {
              final item = _marketplaceItems[index];
              return _buildMarketplaceItemCard(item, context);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMarketplaceItemCard(MarketItem item, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Create formatter with null safety
    String formatPrice(double price) {
      try {
        final formatter = NumberFormat('#,###', 'ko_KR');
        return '${formatter.format(price)}원';
      } catch (e) {
        return '${price.toStringAsFixed(0)}원';
      }
    }
    
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToItemDetail(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    item.images.first,
                    fit: BoxFit.cover,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Item details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(item.price),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.location ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.likes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.chats}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
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
  
  void _navigateToItemDetail(MarketItem item) {
    // Navigate to marketplace screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketScreen(),
      ),
    ).then((_) {
      setState(() {
        // Refresh state when returning from marketplace
      });
    });
  }

  // Add new method for recent community activity section 
  Widget _buildRecentActivitySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '실시간 동네소식',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/neighborhood'),
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _recentActivities.length,
          itemBuilder: (context, index) {
            final activity = _recentActivities[index];
            return _buildActivityItem(context, activity);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activity['category'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: activity['color'],
                ),
              ),
              const Spacer(),
              Text(
                activity['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['userName'],
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Activity-specific indicator
              if (activity['type'] == 'post')
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity['replyCount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              else if (activity['type'] == 'event')
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity['participantCount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              else if (activity['type'] == 'review')
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity['likeCount']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Add today's deals section builder
  Widget _buildTodaysDealsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 특가',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/marketplace'),
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _todaysDeals.length,
            itemBuilder: (context, index) {
              final deal = _todaysDeals[index];
              return _buildDealCard(deal, context);
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildDealCard(Map<String, dynamic> deal, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, '/marketplace'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deal banner
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: deal['color'],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${deal['discountPercent']}% 할인',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      deal['expiryTime'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        deal['imageUrl'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.surfaceVariant,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Deal info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal['shop'],
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deal['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${formatPrice(deal['originalPrice'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${formatPrice(deal['discountPrice'])}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: deal['color'],
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
              
              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/marketplace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deal['color'].withOpacity(0.1),
                      foregroundColor: deal['color'],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '구매하기',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Format price helper method
  String formatPrice(int price) {
    try {
      final formatter = NumberFormat('#,###', 'ko_KR');
      return '${formatter.format(price)}원';
    } catch (e) {
      return '${price.toString()}원';
    }
  }

  // Add method to build the neighborhood events section
  Widget _buildNeighborhoodEventsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '동네 이벤트',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllEvents(context),
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Date indicator
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 14, // Show next 14 days
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isToday = index == 0;
              final hasEvent = _neighborhoodEvents.any((event) => 
                event['date'].year == date.year && 
                event['date'].month == date.month && 
                event['date'].day == date.day
              );
              
              return _buildDateItem(
                context, 
                date, 
                isToday: isToday,
                hasEvent: hasEvent,
              );
            },
          ),
        ),
        
        // Upcoming events
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다가오는 이벤트',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _neighborhoodEvents.length > 3 ? 3 : _neighborhoodEvents.length,
                (index) => _buildEventItem(context, _neighborhoodEvents[index]),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateItem(
    BuildContext context, 
    DateTime date, 
    {bool isToday = false, bool hasEvent = false}
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Day of week in Korean
    final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayOfWeek = weekdays[date.weekday - 1];
    
    return GestureDetector(
      onTap: () => _showEventsForDate(context, date),
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isToday 
              ? theme.colorScheme.primary
              : (hasEvent 
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : isDark ? Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isToday || hasEvent)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.2),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday 
                    ? Colors.white
                    : (hasEvent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isToday 
                    ? Colors.white
                    : (hasEvent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
              ),
            ),
            if (hasEvent)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday 
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Format date
    final eventDate = event['date'] as DateTime;
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    
    String dateText;
    if (eventDate.year == today.year && 
        eventDate.month == today.month && 
        eventDate.day == today.day) {
      dateText = '오늘';
    } else if (eventDate.year == tomorrow.year && 
               eventDate.month == tomorrow.month && 
               eventDate.day == tomorrow.day) {
      dateText = '내일';
    } else {
      // Format as MM/DD
      dateText = '${eventDate.month}/${eventDate.day}';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEventDetail(context, event),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Event image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: event['color'].withOpacity(0.2),
                        child: Icon(
                          Icons.event,
                          color: event['color'],
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['category'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: event['color'],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Title
                      Text(
                        event['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Event details
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$dateText ${event['startTime']}~${event['endTime']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['location'],
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Participant count
                Column(
                  children: [
                    Text(
                      '${event['participantCount']}명',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '참여',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventsForDate(BuildContext context, DateTime date) {
    // Filter events for the selected date
    final eventsOnDate = _neighborhoodEvents.where((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.year == date.year && 
             eventDate.month == date.month && 
             eventDate.day == date.day;
    }).toList();
    
    // Format the date as a string
    final formatter = DateFormat('yyyy년 MM월 dd일');
    final dateString = formatter.format(date);
    
    if (eventsOnDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$dateString에 예정된 이벤트가 없습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Show bottom sheet with events for that day
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '$dateString 이벤트',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Event list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: eventsOnDate.length,
                  itemBuilder: (context, index) {
                    return _buildEventItem(context, eventsOnDate[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllEvents(BuildContext context) {
    // Navigate to events screen
    Navigator.pushNamed(context, '/neighborhood/events');
  }

  void _showEventDetail(BuildContext context, Map<String, dynamic> event) {
    // Show bottom sheet with event details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Event image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Image.network(
                  event['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: event['color'].withOpacity(0.2),
                      child: Icon(
                        Icons.event,
                        color: event['color'],
                        size: 80,
                      ),
                    );
                  },
                ),
              ),
              
              // Event details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event['title'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event['category'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: event['color'],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Event info rows
                      _buildEventInfoRow(
                        context, 
                        Icons.calendar_today,
                        event['date'] is DateTime 
                            ? DateFormat('yyyy년 MM월 dd일').format(event['date'])
                            : '',
                      ),
                      const SizedBox(height: 12),
                      _buildEventInfoRow(
                        context, 
                        Icons.access_time,
                        '${event['startTime']} ~ ${event['endTime']}',
                      ),
                      const SizedBox(height: 12),
                      _buildEventInfoRow(
                        context, 
                        Icons.location_on_outlined,
                        event['location'],
                      ),
                      const SizedBox(height: 12),
                      _buildEventInfoRow(
                        context, 
                        Icons.person_outline,
                        event['organizer'],
                      ),
                      const SizedBox(height: 12),
                      _buildEventInfoRow(
                        context, 
                        Icons.people_outline,
                        '${event['participantCount']}명 참여',
                      ),
                      const SizedBox(height: 30),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('취소'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('이벤트에 참여했습니다'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('참여하기'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // Add story/post creation section
  Widget _buildStorySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Mock user avatars
    final List<String> userAvatars = [
      'https://randomuser.me/api/portraits/men/32.jpg',
      'https://randomuser.me/api/portraits/women/44.jpg',
      'https://randomuser.me/api/portraits/men/22.jpg',
      'https://randomuser.me/api/portraits/women/78.jpg',
      'https://randomuser.me/api/portraits/men/51.jpg',
      'https://randomuser.me/api/portraits/women/63.jpg',
    ];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post creation card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Input field
                InkWell(
                  onTap: () => _showPostCreationSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://randomuser.me/api/portraits/men/32.jpg', // Current user avatar
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 32,
                                height: 32,
                                color: theme.colorScheme.primary,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '동네에 소식을 공유해보세요',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Post type buttons
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPostTypeButton(
                        context,
                        '사진',
                        Icons.photo_library_outlined,
                        Colors.green,
                      ),
                      _buildPostTypeButton(
                        context,
                        '질문',
                        Icons.help_outline,
                        Colors.orange,
                      ),
                      _buildPostTypeButton(
                        context,
                        '모임',
                        Icons.people_outline,
                        Colors.blue,
                      ),
                      _buildPostTypeButton(
                        context,
                        '투표',
                        Icons.poll_outlined,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stories
          const SizedBox(height: 20),
          Text(
            '이웃 스토리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: userAvatars.length + 1, // +1 for "My Story"
              itemBuilder: (context, index) {
                // First item is "Add your story"
                if (index == 0) {
                  return _buildAddStoryItem(context);
                }
                
                // Other items are user stories
                final avatarUrl = userAvatars[index - 1];
                return _buildStoryItem(context, avatarUrl, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTypeButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: () => _showPostCreationSheet(context, type: label),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStoryItem(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg', // Current user avatar
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '내 스토리',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, String avatarUrl, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Random user names
    final List<String> userNames = [
      '김동네',
      '이웃사촌',
      '박이웃',
      '강아지맘',
      '동네친구',
      '꽃집아저씨',
    ];
    
    // Use modulo to get name based on index
    final name = userNames[(index - 1) % userNames.length];
    
    return InkWell(
      onTap: () => _showStory(context, name, avatarUrl),
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple,
                    Colors.orange,
                    Colors.pink,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.black : Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPostCreationSheet(BuildContext context, {String? type}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF121212) : theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type != null ? '$type 공유하기' : '새 게시물 작성',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(height: 1),
              
              // Post content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButton<String>(
                          value: type ?? '일상',
                          underline: SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.primary,
                          ),
                          dropdownColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          items: [
                            '일상',
                            '질문',
                            '모임',
                            '장터',
                            '분실물',
                            '나눔',
                            '투표',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {},
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Text field
                      TextField(
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: '내용을 입력하세요...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                      
                      // Image picker
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 32,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '사진 추가하기',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Post button
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('게시물이 등록되었습니다'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '게시하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Extra padding for keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  void _showStory(BuildContext context, String userName, String avatarUrl) {
    final theme = Theme.of(context);
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // Story content
                  Center(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1606787364078-24d006984229?w=500', // Random story image
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Progress bar at top
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.7, // Progress 70%
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // User info
                  Positioned(
                    top: 20,
                    left: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '3시간 전',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  // Story text
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 16,
                    child: Text(
                      '오늘 동네에서 만난 귀여운 고양이 ❤️',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Story reply
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white30,
                              ),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '메시지 보내기...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white30,
                            ),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

class ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Draw horizontal lines
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw vertical lines
    for (int i = 0; i < 6; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaveAnimationPainter extends CustomPainter {
  final AnimationController animationController;
  
  WaveAnimationPainter({required this.animationController}) : super(repaint: animationController);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final height = size.height;
    final width = size.width;
    
    final animationValue = animationController.value;
    
    path.moveTo(0, height * 0.7);
    
    for (int i = 0; i < width.toInt(); i++) {
      final x = i.toDouble();
      final sin = math.sin((x / width * 2 * math.pi) + (animationValue * 2 * math.pi));
      final y = sin * 10 + height * 0.7;
      path.lineTo(x, y);
    }
    
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CreditScoreRingPainter extends CustomPainter {
  final double score;
  final Color baseColor;
  final Color progressColor;
  final AnimationController animationController;
  final double strokeWidth;
  
  CreditScoreRingPainter({
    required this.score,
    required this.baseColor,
    required this.progressColor,
    required this.animationController,
    this.strokeWidth = 10,
  }) : super(repaint: animationController);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    
    // Draw base ring
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    canvas.drawCircle(center, radius, basePaint);
    
    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * score * animationController.value;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = progressColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.7
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
    
    // Add small circles on the progress line
    final endAngle = startAngle + sweepAngle;
    final dotRadius = strokeWidth / 4;
    
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final dotPosition = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    
    canvas.drawCircle(dotPosition, dotRadius, dotPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 