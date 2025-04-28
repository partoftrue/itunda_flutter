import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';
import 'notification_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register ThemeService
  locator.registerSingleton<ThemeService>(ThemeService());

  // Register NotificationService
  locator.registerSingleton<NotificationService>(NotificationService());
} 