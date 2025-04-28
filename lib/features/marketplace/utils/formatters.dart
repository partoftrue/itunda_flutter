class Formatters {
  /// Format price with thousand separators
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  /// Format price with thousand separators for double values
  static String formatPriceDouble(double price) {
    // Convert to int if no decimal places
    if (price == price.truncate()) {
      return formatPrice(price.toInt());
    }
    
    String priceStr = price.toStringAsFixed(2);
    // Remove trailing zeros
    if (priceStr.endsWith('.00')) {
      priceStr = priceStr.substring(0, priceStr.length - 3);
      return formatPrice(int.parse(priceStr));
    }
    
    // Format the integer part
    int decimalIndex = priceStr.indexOf('.');
    String intPart = priceStr.substring(0, decimalIndex);
    String decimalPart = priceStr.substring(decimalIndex);
    
    String formattedInt = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
    
    return formattedInt + decimalPart;
  }

  /// Get a human-readable time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
} 