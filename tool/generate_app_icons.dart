import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

Future<void> main() async {
  print('Generating app icons...');
  
  // The Itunda brand blue color
  const Color brandColor = Color(0xFF4286F5);
  
  // Generate app icon in different sizes
  await generateIcon(1024, 1024, brandColor, 'app_icon.png');
  await generateIcon(512, 512, brandColor, 'icon_foreground.png');
  
  // Create plain color background for adaptive icons
  await generateBackground(1024, 1024, brandColor, 'icon_background.png');
  
  print('App icons generated successfully!');
}

Future<void> generateIcon(int width, int height, Color color, String filename) async {
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
  
  final file = File('assets/images/$filename');
  await file.writeAsBytes(buffer);
  
  print('Generated $filename');
}

Future<void> generateBackground(int width, int height, Color color, String filename) async {
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
  
  final file = File('assets/images/$filename');
  await file.writeAsBytes(buffer);
  
  print('Generated $filename');
} 