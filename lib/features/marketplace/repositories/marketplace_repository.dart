import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/market_item.dart';
import '../models/seller.dart';
import '../models/review.dart';
import '../services/marketplace_api_client.dart';
import '../../../core/services/storage_service.dart';

class MarketplaceRepository {
  final MarketplaceApiClient _apiClient;
  final StorageService _storageService;
  
  // In-memory cache for faster access
  final Map<String, MarketItem> _itemCache = {};
  final Map<String, Seller> _sellerCache = {};
  final Map<String, List<Review>> _reviewsCache = {};
  List<MarketItem>? _allItemsCache;
  List<MarketItem>? _bookmarkedItemsCache;
  DateTime? _lastFetchTime;
  
  // Cache expiration time (10 minutes)
  final Duration _cacheExpiration = const Duration(minutes: 10);

  MarketplaceRepository({
    MarketplaceApiClient? apiClient,
    StorageService? storageService,
  }) : 
    _apiClient = apiClient ?? MarketplaceApiClient(),
    _storageService = storageService ?? StorageService();

  // Get all marketplace items with optional filtering
  Future<List<MarketItem>> getItems({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? location,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final cacheIsValid = _lastFetchTime != null && 
                         now.difference(_lastFetchTime!) < _cacheExpiration && 
                         _allItemsCache != null;
    
    // Use cache if valid and no force refresh requested
    if (cacheIsValid && !forceRefresh && category == null && minPrice == null && 
        maxPrice == null && sortBy == null && location == null) {
      return _allItemsCache!;
    }
    
    try {
      final items = await _apiClient.getItems(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
        location: location,
      );
      
      // Update cache
      if (category == null && minPrice == null && maxPrice == null && 
          sortBy == null && location == null) {
        _allItemsCache = items;
        _lastFetchTime = now;
        
        // Update item cache for individual items
        for (var item in items) {
          _itemCache[item.id] = item;
        }
      }
      
      return items;
    } catch (e) {
      // If the API call fails, try to use the cache
      if (_allItemsCache != null) {
        return _applyFilters(_allItemsCache!, 
          category: category, 
          minPrice: minPrice, 
          maxPrice: maxPrice, 
          sortBy: sortBy, 
          location: location
        );
      }
      rethrow;
    }
  }

  // Helper method to apply filters to cached items
  List<MarketItem> _applyFilters(
    List<MarketItem> items, {
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? location,
  }) {
    var filteredItems = List<MarketItem>.from(items);
    
    // Apply category filter
    if (category != null && category != '전체') {
      filteredItems = filteredItems.where((item) => item.category == category).toList();
    }
    
    // Apply price range filter
    if (minPrice != null) {
      filteredItems = filteredItems.where((item) => item.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filteredItems = filteredItems.where((item) => item.price <= maxPrice).toList();
    }
    
    // Apply location filter
    if (location != null) {
      filteredItems = filteredItems.where((item) => 
        item.location != null && item.location!.contains(location)
      ).toList();
    }
    
    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'latest':
          filteredItems.sort((a, b) => b.postDate?.compareTo(a.postDate ?? b.createdAt) ?? 
                                      b.createdAt.compareTo(a.createdAt));
          break;
        case 'price_low':
          filteredItems.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          filteredItems.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'popular':
          filteredItems.sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
          break;
      }
    }
    
    return filteredItems;
  }

  // Get a specific item by ID
  Future<MarketItem> getItemById(String itemId, {bool forceRefresh = false}) async {
    // Try to get from cache first
    if (!forceRefresh && _itemCache.containsKey(itemId)) {
      return _itemCache[itemId]!;
    }
    
    final item = await _apiClient.getItemById(itemId);
    _itemCache[itemId] = item;
    return item;
  }

  // Get bookmarked items
  Future<List<MarketItem>> getBookmarkedItems({bool forceRefresh = false}) async {
    if (!forceRefresh && _bookmarkedItemsCache != null) {
      return _bookmarkedItemsCache!;
    }
    
    final items = await _apiClient.getBookmarkedItems();
    _bookmarkedItemsCache = items;
    
    // Also update the individual item cache
    for (var item in items) {
      _itemCache[item.id] = item;
    }
    
    return items;
  }

  // Toggle bookmark status
  Future<bool> toggleBookmark(MarketItem item) async {
    final newBookmarkStatus = !item.isBookmarked;
    
    try {
      final success = await _apiClient.toggleBookmark(item.id, newBookmarkStatus);
      
      if (success) {
        // Update the cache with the new bookmark status
        final updatedItem = item.copyWith(isBookmarked: newBookmarkStatus);
        _itemCache[item.id] = updatedItem;
        
        // If we have a cached list of all items, update it
        if (_allItemsCache != null) {
          final index = _allItemsCache!.indexWhere((i) => i.id == item.id);
          if (index >= 0) {
            _allItemsCache![index] = updatedItem;
          }
        }
        
        // Update bookmarked items cache
        if (_bookmarkedItemsCache != null) {
          if (newBookmarkStatus) {
            if (!_bookmarkedItemsCache!.any((i) => i.id == item.id)) {
              _bookmarkedItemsCache!.add(updatedItem);
            }
          } else {
            _bookmarkedItemsCache!.removeWhere((i) => i.id == item.id);
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      // If there's a network error, save the change locally and try to sync later
      await _saveOfflineBookmark(item.id, newBookmarkStatus);
      
      // Optimistically update the UI
      final updatedItem = item.copyWith(isBookmarked: newBookmarkStatus);
      _itemCache[item.id] = updatedItem;
      
      if (_allItemsCache != null) {
        final index = _allItemsCache!.indexWhere((i) => i.id == item.id);
        if (index >= 0) {
          _allItemsCache![index] = updatedItem;
        }
      }
      
      if (_bookmarkedItemsCache != null) {
        if (newBookmarkStatus) {
          if (!_bookmarkedItemsCache!.any((i) => i.id == item.id)) {
            _bookmarkedItemsCache!.add(updatedItem);
          }
        } else {
          _bookmarkedItemsCache!.removeWhere((i) => i.id == item.id);
        }
      }
      
      return true;
    }
  }

  // Save bookmark changes locally when offline
  Future<void> _saveOfflineBookmark(String itemId, bool isBookmarked) async {
    try {
      // Get current offline changes
      final offlineChanges = await _storageService.getMap('offline_bookmark_changes') ?? {};
      
      // Add this change
      offlineChanges[itemId] = isBookmarked;
      
      // Save back to storage
      await _storageService.saveMap('offline_bookmark_changes', offlineChanges);
    } catch (e) {
      debugPrint('Failed to save offline bookmark: $e');
    }
  }

  // Sync offline bookmark changes when online
  Future<void> syncOfflineBookmarks() async {
    try {
      final offlineChanges = await _storageService.getMap('offline_bookmark_changes');
      if (offlineChanges == null || offlineChanges.isEmpty) return;
      
      final successfulSyncs = <String>[];
      
      for (final entry in offlineChanges.entries) {
        try {
          final success = await _apiClient.toggleBookmark(entry.key, entry.value);
          if (success) {
            successfulSyncs.add(entry.key);
          }
        } catch (e) {
          debugPrint('Failed to sync offline bookmark for ${entry.key}: $e');
        }
      }
      
      // Remove successfully synced changes
      for (final itemId in successfulSyncs) {
        offlineChanges.remove(itemId);
      }
      
      // Save remaining changes back to storage
      if (offlineChanges.isEmpty) {
        await _storageService.delete('offline_bookmark_changes');
      } else {
        await _storageService.saveMap('offline_bookmark_changes', offlineChanges);
      }
    } catch (e) {
      debugPrint('Failed to sync offline bookmarks: $e');
    }
  }

  // Get seller information
  Future<Seller> getSeller(String sellerId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _sellerCache.containsKey(sellerId)) {
      return _sellerCache[sellerId]!;
    }
    
    final seller = await _apiClient.getSeller(sellerId);
    _sellerCache[sellerId] = seller;
    return seller;
  }

  // Get reviews for a seller
  Future<List<Review>> getSellerReviews(String sellerId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _reviewsCache.containsKey(sellerId)) {
      return _reviewsCache[sellerId]!;
    }
    
    final reviews = await _apiClient.getSellerReviews(sellerId);
    _reviewsCache[sellerId] = reviews;
    return reviews;
  }

  // Search for items
  Future<List<MarketItem>> searchItems(String query) async {
    final items = await _apiClient.searchItems(query);
    
    // Update item cache for individual items
    for (var item in items) {
      _itemCache[item.id] = item;
    }
    
    return items;
  }

  // Create a new market item
  Future<MarketItem> createItem(Map<String, dynamic> itemData, List<String> imagePaths) async {
    final newItem = await _apiClient.createItem(itemData, imagePaths);
    
    // Update caches
    _itemCache[newItem.id] = newItem;
    
    if (_allItemsCache != null) {
      _allItemsCache!.insert(0, newItem); 
    }
    
    return newItem;
  }

  // Update an existing market item
  Future<MarketItem> updateItem(String itemId, Map<String, dynamic> updates, List<String>? newImagePaths) async {
    final updatedItem = await _apiClient.updateItem(itemId, updates, newImagePaths);
    
    // Update caches
    _itemCache[itemId] = updatedItem;
    
    if (_allItemsCache != null) {
      final index = _allItemsCache!.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _allItemsCache![index] = updatedItem;
      }
    }
    
    if (_bookmarkedItemsCache != null) {
      final index = _bookmarkedItemsCache!.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        _bookmarkedItemsCache![index] = updatedItem;
      }
    }
    
    return updatedItem;
  }

  // Delete a market item
  Future<bool> deleteItem(String itemId) async {
    final success = await _apiClient.deleteItem(itemId);
    
    if (success) {
      // Update caches
      _itemCache.remove(itemId);
      
      if (_allItemsCache != null) {
        _allItemsCache!.removeWhere((item) => item.id == itemId);
      }
      
      if (_bookmarkedItemsCache != null) {
        _bookmarkedItemsCache!.removeWhere((item) => item.id == itemId);
      }
    }
    
    return success;
  }

  // Report an item
  Future<bool> reportItem(String itemId, String reason, String description) async {
    return await _apiClient.reportItem(itemId, reason, description);
  }

  // Get trending items
  Future<List<MarketItem>> getTrendingItems({int limit = 10, bool forceRefresh = false}) async {
    // Don't cache trending items as they change frequently
    final items = await _apiClient.getTrendingItems(limit: limit);
    
    // Update item cache for individual items
    for (var item in items) {
      _itemCache[item.id] = item;
    }
    
    return items;
  }

  // Clear all caches
  void clearCache() {
    _itemCache.clear();
    _sellerCache.clear();
    _reviewsCache.clear();
    _allItemsCache = null;
    _bookmarkedItemsCache = null;
    _lastFetchTime = null;
  }
} 