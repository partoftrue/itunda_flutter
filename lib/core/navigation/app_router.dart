import 'package:flutter/material.dart';
import 'main_navigation.dart';
import '../../features/home/home_screen.dart';
import '../../features/shopping/shopping_screen.dart';
import '../../features/home/more_screen.dart';

import '../../features/neighborhood/neighborhood_screen.dart';
import '../../features/eats/eats_home_screen.dart';
import '../../features/eats/restaurant_detail_screen.dart';
import '../../features/eats/order_history_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/marketplace/market_screen.dart';
import '../../features/chat/chat_list_screen.dart';

class AppRouter {
  static const String main = '/';
  static const String home = '/home';
  static const String benefits = '/benefits';
  static const String shopping = '/shopping';
  static const String stocks = '/stocks';
  static const String more = '/more';
  static const String auth = '/auth';
  static const String neighborhood = '/neighborhood';
  static const String eats = '/eats';
  static const String restaurant = '/restaurant';
  static const String orderHistory = '/order-history';
  static const String jobs = '/jobs';
  static const String marketplace = '/marketplace';
  static const String chat = '/chat';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('Generating route for: ${settings.name}');
    
    switch (settings.name) {
      case main:
        print('Routing to MainNavigation');
        return MaterialPageRoute(builder: (context) {
          print('Building MainNavigation widget');
          return const MainNavigation();
        });
      case home:
        print('Routing to HomeScreen');
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case shopping:
        return MaterialPageRoute(builder: (_) => const ShoppingScreen());
      case more:
        return MaterialPageRoute(builder: (_) => const MoreScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => Container());
      case neighborhood:
        return MaterialPageRoute(builder: (_) => const NeighborhoodScreen());
      case eats:
        return MaterialPageRoute(builder: (_) => const EatsHomeScreen());
      case restaurant:
        final restaurantId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurantId: restaurantId ?? ''),
        );
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case jobs:
        return MaterialPageRoute(builder: (_) => const JobsScreen());
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatListScreen ());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 