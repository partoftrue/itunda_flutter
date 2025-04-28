class EatsFormatters {
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  static String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)}km';
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
} 