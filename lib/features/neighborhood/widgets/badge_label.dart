import 'package:flutter/material.dart';

/// A styled badge label widget for categories and tags
class BadgeLabel extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  
  const BadgeLabel({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.secondaryContainer;
    final fgColor = textColor ?? theme.colorScheme.onSecondaryContainer;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: fgColor,
          ),
        ),
      ),
    );
  }
} 