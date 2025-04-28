import 'package:flutter/material.dart';

/// A branding widget to be shown on the splash screen
class ItundaBranding extends StatelessWidget {
  final double height;
  final Color textColor;
  
  const ItundaBranding({
    super.key, 
    this.height = 24.0, 
    this.textColor = const Color(0xFF4286F5)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'POWERED BY',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: height * 0.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(width: height * 0.3),
          Text(
            'itunda',
            style: TextStyle(
              color: textColor,
              fontSize: height * 0.7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
} 