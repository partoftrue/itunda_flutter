import 'dart:io';

void main() {
  // Path to assets directory
  final assetsDir = 'assets/images';
  
  // Create the directory if it doesn't exist
  final directory = Directory(assetsDir);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    print('Created directory: $assetsDir');
  }
  
  // Create placeholder files
  final placeholders = [
    'app_icon.png',
    'icon_foreground.png',
    'icon_background.png',
    'splash_logo.png',
    'branding.png',
  ];
  
  for (final fileName in placeholders) {
    final file = File('$assetsDir/$fileName');
    if (!file.existsSync()) {
      // Create a simple 1x1 blue PNG 
      final bytes = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
        0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
        0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB0, 0x00, 0x00, 0x00,
        0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ];
      file.writeAsBytesSync(bytes);
      print('Created placeholder file: $assetsDir/$fileName');
    } else {
      print('File already exists: $assetsDir/$fileName');
    }
  }
  
  print('\nAll placeholder files created successfully in $assetsDir/');
  print('\nNext steps:');
  print('1. Run: flutter pub run flutter_launcher_icons');
  print('2. Run: flutter pub run flutter_native_splash:create');
} 