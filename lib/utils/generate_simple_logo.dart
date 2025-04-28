import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Simple utility to generate logo PNG files directly in the assets directory
Future<void> main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Generating simple logo files for Itunda...');
  
  try {
    // Create assets directory if it doesn't exist
    final directory = Directory('assets/images');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    
    // Generate solid color blue background for adaptive icon
    await _generateSolidColorImage(
      'assets/images/icon_background.png',
      const Color(0xFF4286F5),
      1024,
      1024,
    );
    
    // Generate app icon with bolt
    await _generateBoltIcon(
      'assets/images/app_icon.png',
      const Color(0xFF4286F5),
      1024,
      isSquare: true,
    );
    
    // Generate foreground for adaptive icon
    await _generateBoltIcon(
      'assets/images/icon_foreground.png',
      const Color(0xFF4286F5),
      1024,
      isSquare: false,
    );
    
    // Generate splash logo
    await _generateBoltIcon(
      'assets/images/splash_logo.png',
      const Color(0xFF4286F5),
      512,
      isSquare: true,
    );
    
    // Generate branding image
    await _generateBrandingImage(
      'assets/images/branding.png',
      1024,
      200,
    );
    
    print('All logo files generated successfully in assets/images/ directory');
    print('\nNext steps:');
    print('1. Run: flutter pub run flutter_launcher_icons');
    print('2. Run: flutter pub run flutter_native_splash:create');
  } catch (e) {
    print('Error generating logo files: $e');
    exit(1);
  }
}

/// Generate a solid color image
Future<void> _generateSolidColorImage(
  String outputPath,
  Color color,
  int width,
  int height,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  
  canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  final file = File(outputPath);
  await file.writeAsBytes(pngBytes!.buffer.asUint8List());
  print('Generated: $outputPath');
}

/// Generate a bolt icon
Future<void> _generateBoltIcon(
  String outputPath,
  Color color,
  int size,
  {bool isSquare = true}
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  
  final radius = size * 0.2;
  
  if (isSquare) {
    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(radius),
      ),
      paint,
    );
  }
  
  // Draw bolt icon
  final boltPath = Path();
  
  // Simple bolt shape
  final center = size / 2;
  final boltSize = isSquare ? size * 0.6 : size * 0.8;
  final offset = isSquare ? 0.0 : size * 0.1;
  
  boltPath.moveTo(center - boltSize * 0.25, center - boltSize * 0.5 + offset);
  boltPath.lineTo(center + boltSize * 0.25, center - boltSize * 0.1 + offset);
  boltPath.lineTo(center - boltSize * 0.1, center - boltSize * 0.05 + offset);
  boltPath.lineTo(center - boltSize * 0.05, center + boltSize * 0.5 + offset);
  boltPath.lineTo(center + boltSize * 0.35, center + offset);
  boltPath.lineTo(center + boltSize * 0.1, center - boltSize * 0.15 + offset);
  boltPath.lineTo(center + boltSize * 0.2, center - boltSize * 0.2 + offset);
  boltPath.close();
  
  final boltPaint = Paint()
    ..color = isSquare ? Colors.white : color
    ..style = PaintingStyle.fill;
  
  canvas.drawPath(boltPath, boltPaint);
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  final file = File(outputPath);
  await file.writeAsBytes(pngBytes!.buffer.asUint8List());
  print('Generated: $outputPath');
}

/// Generate branding image
Future<void> _generateBrandingImage(
  String outputPath,
  int width,
  int height,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final textStyle1 = TextStyle(
    color: const Color(0xFF4286F5).withOpacity(0.7),
    fontSize: height * 0.25,
    fontWeight: FontWeight.w600,
  );
  
  final textStyle2 = TextStyle(
    color: const Color(0xFF4286F5),
    fontSize: height * 0.35,
    fontWeight: FontWeight.bold,
  );
  
  final builder1 = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center, 
    fontSize: height * 0.25,
  ))
    ..pushStyle(ui.TextStyle(
      color: const Color(0xFF4286F5).withOpacity(0.7),
      fontSize: height * 0.25,
      fontWeight: ui.FontWeight.w600,
      letterSpacing: 1.5,
    ))
    ..addText('POWERED BY');
  
  final builder2 = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center, 
    fontSize: height * 0.35,
  ))
    ..pushStyle(ui.TextStyle(
      color: const Color(0xFF4286F5),
      fontSize: height * 0.35,
      fontWeight: ui.FontWeight.bold,
      letterSpacing: 0.5,
    ))
    ..addText('itunda');
  
  final paragraph1 = builder1.build()
    ..layout(ui.ParagraphConstraints(width: width * 0.5));
  
  final paragraph2 = builder2.build()
    ..layout(ui.ParagraphConstraints(width: width * 0.4));
  
  canvas.drawParagraph(paragraph1, Offset(width * 0.1, height * 0.3));
  canvas.drawParagraph(paragraph2, Offset(width * 0.55, height * 0.25));
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  final file = File(outputPath);
  await file.writeAsBytes(pngBytes!.buffer.asUint8List());
  print('Generated: $outputPath');
} 