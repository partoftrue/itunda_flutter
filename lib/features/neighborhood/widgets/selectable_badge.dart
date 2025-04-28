import 'package:flutter/material.dart';

/// A chip-style badge label for filters and selectable tags
class SelectableBadge extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  
  const SelectableBadge({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bgColor = isSelected
        ? selectedColor ?? theme.colorScheme.primary
        : unselectedColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5);
        
    final fgColor = isSelected
        ? selectedTextColor ?? theme.colorScheme.onPrimary
        : unselectedTextColor ?? theme.colorScheme.onSurfaceVariant;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                  width: 1,
                ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: fgColor,
          ),
        ),
      ),
    );
  }
} 