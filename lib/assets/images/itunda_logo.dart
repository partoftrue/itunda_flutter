import 'package:flutter/material.dart';

class ItundaLogo extends StatelessWidget {
  final double size;
  final Color color;
  
  const ItundaLogo({
    super.key, 
    this.size = 40.0, 
    this.color = const Color(0xFF4286F5)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bolt icon
          Icon(
            Icons.bolt,
            color: Colors.white,
            size: size * 0.6,
          ),
        ],
      ),
    );
  }
} 