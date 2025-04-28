import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/assets/itunda_logo_generator.dart';

/// A simple command-line tool to generate Itunda logo files
/// This should be run with `flutter run -t lib/utils/logo_generator_tool.dart`
void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Itunda Logo Generator Tool');
  print('=========================');
  print('Generating logo images for app launcher icon and splash screen...');
  
  try {
    // Generate the logo images
    await ItundaLogoGenerator.generateLogoImages();
    
    print('\nLogo generation complete!');
    print('\nNext steps:');
    print('1. Copy the generated PNG files to your assets/images/ directory');
    print('2. Run the following commands:');
    print('   - flutter pub run flutter_launcher_icons');
    print('   - flutter pub run flutter_native_splash:create');
    
    // Exit the application
    exit(0);
  } catch (e) {
    print('Error generating logo images: $e');
    exit(1);
  }
} 