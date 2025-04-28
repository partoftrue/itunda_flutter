import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class PriceText extends StatelessWidget {
  final int price;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool showCurrency;
  final bool useBoldCurrency;

  const PriceText({
    super.key,
    required this.price,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.showCurrency = true,
    this.useBoldCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    final formattedPrice = EatsFormatters.formatPrice(price);
    
    if (!showCurrency) {
      return Text(
        formattedPrice,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          height: 1.2,
          letterSpacing: -0.3,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '₩',
            style: TextStyle(
              fontSize: fontSize != null ? fontSize! * 0.9 : null,
              fontWeight: useBoldCurrency ? FontWeight.w700 : FontWeight.w400,
              color: effectiveColor.withOpacity(0.8),
              height: 1.2,
            ),
          ),
          TextSpan(
            text: ' $formattedPrice',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: effectiveColor,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
} 