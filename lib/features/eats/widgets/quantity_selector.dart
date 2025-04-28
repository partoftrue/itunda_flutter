import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final double? iconSize;
  final double? buttonSize;
  final Color? buttonColor;
  final Color? iconColor;
  final Color? textColor;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.iconSize = 20.0,
    this.buttonSize = 32.0,
    this.buttonColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveButtonColor = buttonColor ?? theme.colorScheme.surface;
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove_rounded,
          onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
          theme: theme,
          effectiveButtonColor: effectiveButtonColor,
          effectiveIconColor: effectiveIconColor,
        ),
        SizedBox(
          width: buttonSize! * 1.2,
          child: Center(
            child: Text(
              quantity.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add_rounded,
          onPressed: () => onQuantityChanged(quantity + 1),
          theme: theme,
          effectiveButtonColor: effectiveButtonColor,
          effectiveIconColor: effectiveIconColor,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ThemeData theme,
    required Color effectiveButtonColor,
    required Color effectiveIconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(buttonSize! / 2),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: onPressed == null 
              ? effectiveButtonColor.withOpacity(0.5)
              : effectiveButtonColor,
            borderRadius: BorderRadius.circular(buttonSize! / 2),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null 
              ? effectiveIconColor.withOpacity(0.5)
              : effectiveIconColor,
          ),
        ),
      ),
    );
  }
} 