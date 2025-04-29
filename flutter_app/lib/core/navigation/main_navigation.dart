import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/home/home_screen.dart';
import '../../features/neighborhood/neighborhood_screen.dart';
import '../../features/marketplace/market_screen.dart';
import '../../features/eats/eats_home_screen.dart';
import '../../features/shopping/shopping_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/all_services/all_services_screen.dart';
import '../providers/location_provider.dart';
import '../widgets/location_selector.dart';
import '../../features/neighborhood/screens/location_selector_screen.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
  
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  
  // Keep screens in memory to preserve state
  final List<Widget> _screens = [
    const HomeScreen(),
    const NeighborhoodScreen(),
    const ShoppingScreen(),
    const ChatListScreen(),
    const AllServicesScreen(), // 전체 서비스
  ];

  final List<String> _titles = [
    '홈',
    '생활',
    '쇼핑',
    '톡',
    '전체', // 전체 서비스
  ];
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      IconButton(
        icon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.onBackground,
          size: 22,
        ),
        onPressed: () {},
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tooltip: '검색',
      ),
      IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: theme.colorScheme.onBackground,
          size: 22,
        ),
        onPressed: () {},
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tooltip: '알림',
      ),
      const SizedBox(width: 12),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Debug print to verify the widget is being built
    print('MainNavigation build method called');
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? theme.colorScheme.background : Colors.white,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 20,
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            title: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationSelectorScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locationProvider.currentLocationDisplay,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white70 : Colors.black87,
                        size: 22,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: _buildActions(context),
          ),
          body: PageView(
            key: const PageStorageKey<String>('main-navigation-pageview'),
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swiping between tabs
            onPageChanged: _onPageChanged,
            children: _screens.map((screen) => 
              SizedBox.expand(
                child: screen,
              )
            ).toList(),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                elevation: 0,
                items: items,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: isDark ? Colors.white : Colors.black,
                unselectedItemColor: const Color(0xFF8E8E93),
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
                showUnselectedLabels: true,
                iconSize: 24,
                selectedFontSize: 11,
                unselectedFontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> get items => [
    _buildNavigationItem(Icons.home_rounded, Icons.home_rounded, '홈'),
    _buildNavigationItem(Icons.location_city_rounded, Icons.location_city_rounded, '생활'),
    _buildNavigationItem(Icons.shopping_bag_rounded, Icons.shopping_bag_rounded, '쇼핑'),
    _buildNavigationItem(Icons.chat_rounded, Icons.chat_rounded, '채팅'),
    _buildNavigationItem(Icons.menu_rounded, Icons.menu_rounded, '전체'),
  ];

  BottomNavigationBarItem _buildNavigationItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon, size: 26),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(activeIcon, size: 26),
      ),
      label: label,
    );
  }
} 