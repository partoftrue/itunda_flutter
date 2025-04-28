import '../models/market_item.dart';

/// Service for managing bookmarked marketplace items
class BookmarkService {
  // In-memory storage for bookmarked item IDs
  // In a real app, this would be persisted to storage
  final Set<String> _bookmarkedIds = {};

  // Singleton pattern
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  /// Check if an item is bookmarked
  bool isBookmarked(MarketItem item) {
    return _bookmarkedIds.contains(item.id);
  }

  /// Toggle bookmark status
  void toggleBookmark(MarketItem item) {
    if (isBookmarked(item)) {
      _bookmarkedIds.remove(item.id);
    } else {
      _bookmarkedIds.add(item.id);
    }
  }

  /// Add bookmark
  void addBookmark(MarketItem item) {
    _bookmarkedIds.add(item.id);
  }

  /// Remove bookmark
  void removeBookmark(MarketItem item) {
    _bookmarkedIds.remove(item.id);
  }

  /// Get all bookmarked IDs
  Set<String> getBookmarkedIds() {
    return Set.from(_bookmarkedIds);
  }

  /// Filter bookmarked items from a list
  List<MarketItem> filterBookmarkedItems(List<MarketItem> items) {
    return items.where((item) => _bookmarkedIds.contains(item.id)).toList();
  }

  /// Clear all bookmarks
  void clearBookmarks() {
    _bookmarkedIds.clear();
  }
} 