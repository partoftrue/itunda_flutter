import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itunda/features/neighborhood/data/repositories/mock_neighborhood_repository.dart';
import 'package:itunda/features/marketplace/providers/market_provider.dart';
import 'package:itunda/features/marketplace/repositories/marketplace_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'core/providers/app_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart' as app_theme;
import 'core/navigation/main_navigation.dart';
import 'core/navigation/app_router.dart';
import 'core/services/app_initialization.dart';
import 'core/services/location_service.dart';
import 'features/neighborhood/presentation/providers/neighborhood_provider.dart';
import 'features/home/home_screen.dart';
import 'features/marketplace/providers/market_provider.dart';
import 'features/marketplace/repositories/marketplace_repository.dart';
import 'features/eats/eats_home_screen.dart';
import 'features/shopping/shopping_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/jobs/jobs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/performance_service.dart';
import 'core/services/service_locator.dart';
import 'core/services/theme_service.dart';
import 'core/services/notification_service.dart';

// Global navigator key for access throughout the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Global scaffold messenger key for snackbars and other overlay widgets
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Add this function to generate app icons
Future<void> generateAppIcons() async {
  if (kDebugMode) {
    try {
      print('Generating app icons for developer testing...');
      
      // The brand color for app icon
      const Color brandColor = AppTheme.primaryColor;
      
      // Generate the main app icon (1024x1024)
      await _generateIconImage(1024, 1024, brandColor, 'app_icon.png');
      
      // Generate the foreground image for adaptive icons
      await _generateIconImage(1024, 1024, brandColor, 'icon_foreground.png');
      
      // Generate a plain background color image
      await _generateBackgroundImage(1024, 1024, brandColor, 'icon_background.png');
      
      print('App icons generated!');
    } catch (e) {
      print('Error generating app icons: $e');
    }
  }
}

Future<void> _generateIconImage(int width, int height, Color color, String filename) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw background
  final bgPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
    
  final bgRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  final bgRadius = Radius.circular(width * 0.2);
  final bgRRect = RRect.fromRectAndRadius(bgRect, bgRadius);
  
  canvas.drawRRect(bgRRect, bgPaint);
  
  // Draw the bolt icon
  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
    
  final path = Path();
  
  // Create lightning bolt shape
  path.moveTo(width * 0.5, height * 0.18);
  path.cubicTo(width * 0.47, height * 0.18, width * 0.45, height * 0.183, width * 0.425, height * 0.19);
  path.lineTo(width * 0.33, height * 0.42);
  path.lineTo(width * 0.47, height * 0.42);
  path.lineTo(width * 0.33, height * 0.82);
  path.lineTo(width * 0.67, height * 0.5);
  path.lineTo(width * 0.5, height * 0.5);
  path.lineTo(width * 0.67, height * 0.18);
  path.close();
  
  canvas.drawPath(path, paint);
  
  // End recording and save
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  final directory = Directory('assets/images');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final file = File('assets/images/$filename');
  await file.writeAsBytes(buffer);
  
  print('Generated $filename');
}

Future<void> _generateBackgroundImage(int width, int height, Color color, String filename) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw solid color background
  final bgPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
    
  final bgRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  canvas.drawRect(bgRect, bgPaint);
  
  // End recording and save
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  final directory = Directory('assets/images');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  
  final file = File('assets/images/$filename');
  await file.writeAsBytes(buffer);
  
  print('Generated $filename');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final connectivityService = ConnectivityService();
  final performanceService = PerformanceService(prefs);
  
  // Generate app icons (only in debug mode)
  if (kDebugMode) {
    // await generateAppIcons(); // Uncomment to generate icons
  }
  
  // Set preferred orientations for better performance
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for better initial appearance
  // We'll update this dynamically based on theme in the MyApp widget
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
  // Enable performance overlay in debug mode
  if (kDebugMode) {
    // Uncomment to enable performance overlay
    // debugPaintSizeEnabled = true;
    // debugPaintLayerBordersEnabled = true;
  }
  
  // Setup dependency injection
  await setupServiceLocator();
  
  // Initialize services
  
  
  
  // Create instances of core services
  final appProvider = AppProvider();
  
  // Initialize the app
  await appProvider.initialize();
  
  // Allow debugging output
  // debugPrintSynchronously = true; // Removed as it's causing errors
  
  runApp(
    MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        Provider.value(value: connectivityService),
        Provider.value(value: performanceService),
        
        // Location service (already exists)
        ChangeNotifierProvider(create: (_) => LocationService()),
        
        // Feature providers
        ChangeNotifierProvider(create: (_) => NeighborhoodProvider(
          repository: MockNeighborhoodRepository(),
        )),
        
        // New marketplace provider using the real repository
        ChangeNotifierProvider(
          create: (context) => MarketProvider(
            repository: MarketplaceRepository(),
            locationService: Provider.of<LocationService>(context, listen: false),
          ),
        ),
        
        // Payment features providers
        
        
        // API service providers
        
        
        
        // New providers
        ChangeNotifierProvider(
          create: (_) => serviceLocator<ThemeService>(),
        ),
        ChangeNotifierProvider(
          create: (_) => serviceLocator<NotificationService>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoggedIn = false;
  bool _isInitializing = true;
  final AppInitialization _appInitialization = AppInitialization();
  bool _showPerformanceOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Optimize app behavior based on lifecycle state
    if (state == AppLifecycleState.paused) {
      // App is in background - release resources
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground - reinitialize resources
      _checkConnectivity();
    }
  }
  
  void _checkConnectivity() {
    // Refresh connectivity status when app is resumed
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    connectivityService.checkConnectivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await _appInitialization.initialize();
      
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isInitializing = false;
        });
        
        // Initialize location for the marketplace after main initialization
        _initializeMarketplace();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isInitializing = false;
        });
        
        // Show error dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('앱 초기화 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }
  
  void _initializeMarketplace() {
    try {
      // Initialize the marketplace provider with location data
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      marketProvider.initLocation().then((_) {
        if (mounted) {
          marketProvider.loadItems();
        }
      }).catchError((error) {
        if (mounted) {
          print('마켓플레이스 초기화 오류: $error');
        }
      });
    } catch (e) {
      // Ignore marketplace errors - non-critical
      print('마켓플레이스 초기화 실패: $e');
    }
  }
  
  void _togglePerformanceOverlay() {
    if (kDebugMode) {
      setState(() {
        _showPerformanceOverlay = !_showPerformanceOverlay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    
    // Update system UI overlay style based on current theme
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark || 
        (themeProvider.themeMode == ThemeMode.system && 
         WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    if (_isInitializing) {
      // Show a loading screen while initializing
      return MaterialApp(
        title: 'itunda',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo could be added here
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  '앱을 초기화 중입니다...',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onBackground,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Use MainNavigation instead of directly showing HomeScreen
    return MaterialApp(
      title: 'itunda',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigation(), // Use MainNavigation to get bottom nav bar
    );
    
    // Original code - commented out for debugging
    /*
    return MaterialApp(
      title: 'itunda',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeProvider.themeMode),
      initialRoute: AppRouter.main, // Always go to main route for testing
      onGenerateRoute: AppRouter.generateRoute,
      showPerformanceOverlay: _showPerformanceOverlay,
      checkerboardRasterCacheImages: _showPerformanceOverlay,
      checkerboardOffscreenLayers: _showPerformanceOverlay,
    );
    */
  }
  
  ThemeMode _getThemeMode(app_theme.ThemeMode mode) {
    switch (mode) {
      case app_theme.ThemeMode.light:
        return ThemeMode.light;
      case app_theme.ThemeMode.dark:
        return ThemeMode.dark;
      case app_theme.ThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itunda'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return ElevatedButton(
                  onPressed: () {
                    themeService.setThemeMode(
                      themeService.themeMode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    );
                  },
                  child: Text(
                    'Toggle Theme (${themeService.themeMode.name})',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<NotificationService>(
              builder: (context, notificationService, child) {
                return ElevatedButton(
                  onPressed: () {
                    notificationService.toggleNotifications(!notificationService.isEnabled);
                  },
                  child: Text(
                    'Toggle Notifications (${notificationService.isEnabled ? 'On' : 'Off'})',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

