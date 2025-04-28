import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/home/home_screen.dart';
import '../../features/neighborhood/neighborhood_screen.dart';
import '../../features/marketplace/market_screen.dart';
import '../../features/eats/eats_home_screen.dart';
import '../../features/shopping/shopping_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/all_services/all_services_screen.dart';

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
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
              ],
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: theme.scaffoldBackgroundColor,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                iconSize: 22,
                enableFeedback: true,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: theme.colorScheme.primary,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                elevation: 0,
                items: [
                  _buildNavigationItem(Icons.home_outlined, Icons.home, _titles[0]),
                  _buildNavigationItem(Icons.people_outline, Icons.people, _titles[1]),
                  _buildNavigationItem(Icons.shopping_bag_outlined, Icons.shopping_bag, _titles[2]),
                  _buildNavigationItem(Icons.chat_bubble_outline, Icons.chat_bubble, _titles[3]),
                  _buildNavigationItem(Icons.grid_view_outlined, Icons.grid_view, _titles[4]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Icon(activeIcon),
        ),
      ),
      label: label,
      tooltip: label,
    );
  }
} 