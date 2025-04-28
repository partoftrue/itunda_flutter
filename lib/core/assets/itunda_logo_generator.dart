import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../assets/images/itunda_logo.dart';

/// Utility class to generate PNG images of the Itunda logo for launcher icons and splash screens
class ItundaLogoGenerator {
  /// Generates logo PNG files in various sizes for launcher icons and splash screens
  static Future<void> generateLogoImages() async {
    // Define the different sizes needed
    final sizes = [
      {'name': 'launcher_icon', 'size': 192.0},  // Android adaptive icon foreground
      {'name': 'splash_logo', 'size': 512.0},    // Splash screen logo
      {'name': 'icon_foreground', 'size': 512.0}, // Android adaptive icon foreground
      {'name': 'icon_background', 'size': 512.0}, // Android adaptive icon background (solid color)
      {'name': 'app_icon', 'size': 1024.0},      // iOS icon
    ];
    
    // Get temporary directory to save the images
    final dir = await getTemporaryDirectory();
    final outputPath = '${dir.path}/logo_images';
    
    // Create directory if it doesn't exist
    final directory = Directory(outputPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    
    // Generate each size
    for (final sizeConfig in sizes) {
      final name = sizeConfig['name'] as String;
      final size = sizeConfig['size'] as double;
      
      // Generate the logo image
      final image = await _generateLogoImage(size, name == 'icon_background');
      
      // Save the image to file
      final filePath = '$outputPath/$name.png';
      final file = File(filePath);
      await file.writeAsBytes(image);
      
      print('Generated $name logo at $filePath');
    }
    
    print('All logo images generated at $outputPath');
  }
  
  /// Generates a single logo image of specified size
  static Future<Uint8List> _generateLogoImage(double size, bool backgroundOnly) async {
    // Create a RepaintBoundary to capture the widget as an image
    final repaintBoundary = RenderRepaintBoundary();
    
    // Create a pipeline owner
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    // Create the render tree
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: backgroundOnly 
          ? Container(
              width: size,
              height: size,
              color: const Color(0xFF4286F5),
            )
          : ItundaLogo(
              size: size,
              color: const Color(0xFF4286F5),
            ),
      ),
    ).attachToRenderTree(buildOwner);
    
    // Do a layout pass
    pipelineOwner.rootNode = repaintBoundary;
    // Layout initialization for RenderRepaintBoundary (prepareInitialFrame is not available in Flutter 3.x+)
    repaintBoundary.attach(pipelineOwner);
    repaintBoundary.layout(BoxConstraints.tightFor(width: size, height: size));
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    
    // Capture the image
    final image = await repaintBoundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
} 