import 'package:intl/intl.dart';

class FormatUtils {
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    return '₩${formatter.format(price.toInt())}';
  }
  
  static String timeAgo(DateTime dateTime) {
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