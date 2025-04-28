import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showShadow;
  
  const AppLogo({
    super.key, 
    this.size = 64.0, 
    this.color,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoColor = color ?? AppTheme.primaryColor;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: logoColor,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: size * 0.05,
            offset: Offset(0, size * 0.02),
          )
        ] : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: BoltPainter(color: Colors.white),
      ),
    );
  }
}

class BoltPainter extends CustomPainter {
  final Color color;
  
  BoltPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final path = Path();
    
    // Scale to fit within the container
    final width = size.width;
    final height = size.height;
    
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
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 