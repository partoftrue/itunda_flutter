import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/market_item.dart';
import '../models/market_profile.dart';
import '../models/review.dart';
import '../models/seller.dart';
import '../repositories/marketplace_repository.dart';
import '../../../core/services/location_service.dart';
import 'dart:math';

enum MarketLoadingState { initial, loading, loaded, error }

/// Provider class for marketplace state management
class MarketProvider with ChangeNotifier {
  final MarketplaceRepository _repository;
  final LocationService? _locationService;
  
  // State variables
  MarketLoadingState _state = MarketLoadingState.initial;
  List<MarketItem> _items = [];
  List<MarketItem> _filteredItems = [];
  List<MarketItem> _bookmarkedItems = [];
  List<MarketItem> _nearbyItems = [];
  List<MarketItem> _trendingItems = [];
  String _error = '';
  String _sortOption = 'latest';
  int _selectedCategoryIndex = 0;
  bool _showAttributedOnly = false;
  RangeValues _priceRange = const RangeValues(0, 2000000);
  List<String> _recentSearches = [];
  final Set<String> _bookmarkedIds = {}; // Store IDs of bookmarked items
  String? _currentLocation;
  
  final List<String> _categories = [
    '전체',
    '디지털기기',
    '생활가전',
    '가구/인테리어',
    '생활/주방',
    '유아동',
    '의류',
    '도서/티켓/취미',
    '스포츠/레저',
    '뷰티/미용',
    '식품',
    '기타',
  ];

  // Getters
  MarketLoadingState get state => _state;
  List<MarketItem> get items => _items;
  List<MarketItem> get filteredItems => _filteredItems;
  List<MarketItem> get bookmarkedItems => _bookmarkedItems;
  List<MarketItem> get nearbyItems => _nearbyItems;
  List<MarketItem> get trendingItems => _trendingItems;
  bool get isLoading => _state == MarketLoadingState.loading;
  String get error => _error;
  String get sortOption => _sortOption;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  bool get showAttributedOnly => _showAttributedOnly;
  RangeValues get priceRange => _priceRange;
  List<String> get recentSearches => _recentSearches;
  List<String> get categories => _categories;
  String? get currentLocation => _currentLocation;

  /// Constructor
  MarketProvider({
    MarketplaceRepository? repository,
    LocationService? locationService,
  }) : 
    _repository = repository ?? MarketplaceRepository(),
    _locationService = locationService;

  /// Check if an item is bookmarked
  bool isBookmarked(MarketItem item) {
    return _bookmarkedIds.contains(item.id);
  }

  /// Load all marketplace items
  Future<void> loadItems({bool forceRefresh = false}) async {
    _state = MarketLoadingState.loading;
    _error = '';
    notifyListeners();
    
    try {
      // Try to sync offline bookmarks first
      await _repository.syncOfflineBookmarks();
      
      // Load items with current location if available
      final items = await _repository.getItems(
        location: _currentLocation,
        forceRefresh: forceRefresh,
      );
      
      _items = items;
      _applyFilters();
      _loadBookmarkedItems();
      _loadNearbyItems();
      _state = MarketLoadingState.loaded;
    } catch (e) {
      _error = 'Failed to load items: ${e.toString()}';
      _state = MarketLoadingState.error;
    }
    
    notifyListeners();
  }

  /// Apply all filters to the items
  void _applyFilters() {
    // Start with all items
    List<MarketItem> result = List.from(_items);
    
    // Apply category filter
    if (_selectedCategoryIndex > 0) {
      result = result.where((item) => 
        item.category == _categories[_selectedCategoryIndex]
      ).toList();
    }
    
    // Apply attribution filter
    if (_showAttributedOnly) {
      result = result.where((item) => 
        item.imageAttribution != null && item.imageAttribution!.isNotEmpty
      ).toList();
    }
    
    // Apply price range filter
    result = result.where((item) => 
      item.price >= _priceRange.start && 
      item.price <= _priceRange.end
    ).toList();
    
    // Apply sorting
    result = _sortItems(result, _sortOption);
    
    _filteredItems = result;
    notifyListeners();
  }

  /// Sort items based on sort option
  List<MarketItem> _sortItems(List<MarketItem> items, String sortOption) {
    final List<MarketItem> sortedItems = List<MarketItem>.from(items);
    
    switch (sortOption) {
      case 'latest':
        sortedItems.sort((a, b) => 
          (b.postDate ?? b.createdAt).compareTo(a.postDate ?? a.createdAt));
        break;
      case 'price_low':
        sortedItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sortedItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
        sortedItems.sort((a, b) => b.likes.compareTo(a.likes));
        break;
    }
    
    return sortedItems;
  }

  /// Load bookmarked items
  void _loadBookmarkedItems() {
    _bookmarkedItems = _items.where((item) => 
      isBookmarked(item)).toList();
    notifyListeners();
  }

  /// Set error message
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Set sort option
  void setSortOption(String option) {
    _sortOption = option;
    _applyFilters();
  }

  /// Set selected category index
  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    _applyFilters();
  }

  /// Toggle show attributed only
  void toggleShowAttributedOnly() {
    _showAttributedOnly = !_showAttributedOnly;
    _applyFilters();
  }

  /// Set price range
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    _applyFilters();
  }

  /// Toggle bookmark for an item
  void toggleBookmark(MarketItem item) {
    if (_bookmarkedIds.contains(item.id)) {
      _bookmarkedIds.remove(item.id);
    } else {
      _bookmarkedIds.add(item.id);
    }
    notifyListeners();
  }

  /// Search items
  Future<List<MarketItem>> searchItems(String query) async {
    if (query.isEmpty) return [];
    
    // Add to recent searches if not already present
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      notifyListeners();
    }
    
    try {
      return await _repository.searchItems(query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  /// Clear recent searches
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Remove a recent search
  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  /// Get seller profile (mock implementation)
  Future<MarketProfile> getSellerProfile(String sellerId) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    return MarketProfile(
      id: sellerId,
      userId: 'user-$sellerId',
      displayName: 'Seller Name',
      avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      bio: 'Experienced seller with great customer service',
      rating: 4.8,
      reviewCount: 42,
      itemsCount: 15,
      soldItemsCount: 10,
      joinedAt: DateTime.now().subtract(Duration(days: 365)),
      isVerified: true,
    );
  }

  /// Get reviews for an item (mock implementation)
  List<Review> getItemReviews(String itemId) {
    return [
      Review(
        id: 'rev1',
        userId: 'user1',
        userName: '구매자A',
        userAvatar: 'https://randomuser.me/api/portraits/men/2.jpg',
        itemId: itemId,
        rating: 5.0,
        comment: '상품 상태 좋고, 판매자 분도 친절해요!',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      Review(
        id: 'rev2',
        userId: 'user2',
        userName: '구매자B',
        userAvatar: 'https://randomuser.me/api/portraits/women/2.jpg',
        itemId: itemId,
        rating: 4.5,
        comment: '배송이 조금 늦었지만 품질은 좋아요.',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ];
  }

  // Initialize with the user's location
  Future<void> initLocation() async {
    if (_locationService != null) {
      final locationData = _locationService!.currentLocation;
      if (locationData != null) {
        final district = locationData.district;
        final neighborhood = locationData.neighborhood;
        
        if (district != null && neighborhood != null) {
          _currentLocation = '$district $neighborhood';
          notifyListeners();
        }
      }
    }
  }

  // Get item details
  Future<MarketItem> getItemDetails(String itemId, {bool forceRefresh = false}) async {
    try {
      final item = await _repository.getItemById(itemId, forceRefresh: forceRefresh);
      
      // Update item in our local list if it exists
      final index = _items.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
      
      return item;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get seller details
  Future<Seller> getSeller(String sellerId, {bool forceRefresh = false}) async {
    try {
      return await _repository.getSeller(sellerId, forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get seller reviews
  Future<List<Review>> getSellerReviews(String sellerId, {bool forceRefresh = false}) async {
    try {
      return await _repository.getSellerReviews(sellerId, forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Create a new market item
  Future<MarketItem> createItem(Map<String, dynamic> itemData, List<String> imagePaths) async {
    try {
      final newItem = await _repository.createItem(itemData, imagePaths);
      
      // Add to our local list
      _items.insert(0, newItem);
      notifyListeners();
      
      return newItem;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update an existing market item
  Future<MarketItem> updateItem(String itemId, Map<String, dynamic> updates, List<String>? newImagePaths) async {
    try {
      final updatedItem = await _repository.updateItem(itemId, updates, newImagePaths);
      
      // Update in our local list
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
      
      return updatedItem;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete a market item
  Future<bool> deleteItem(String itemId) async {
    try {
      final success = await _repository.deleteItem(itemId);
      
      if (success) {
        // Remove from our local list
        _items.removeWhere((item) => item.id == itemId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Set current location
  void setCurrentLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }

  // Filter items by proximity to user's location
  Future<List<MarketItem>> getNearbyItems({double maxDistanceKm = 5.0}) async {
    try {
      if (_locationService == null || _locationService!.currentLocation == null) {
        return _items; // Return all items if location service not available
      }

      final userLocation = _locationService!.currentLocation!;
      if (userLocation.latitude == null || userLocation.longitude == null) {
        return _items;
      }

      // Filter items that have location coordinates and calculate distance
      final itemsWithDistance = _items.map((item) {
        if (item.lat == null || item.lng == null) return item;
        
        // Calculate distance between user and item
        final latDiff = (item.lat! - userLocation.latitude!).abs();
        final lngDiff = (item.lng! - userLocation.longitude!).abs();
        
        // Rough conversion to kilometers (this is approximate)
        final latDistance = latDiff * 111.0; // 1 degree lat ≈ 111 km
        final lngDistance = lngDiff * 111.0 * cos(userLocation.latitude! * pi / 180.0);
        
        final distance = sqrt(latDistance * latDistance + lngDistance * lngDistance);
        
        // Return item with distance
        return item.copyWith(distanceInKm: distance);
      }).toList();
      
      // Filter by max distance
      final nearbyItems = itemsWithDistance
          .where((item) => item.distanceInKm != null && item.distanceInKm! <= maxDistanceKm)
          .toList();
          
      // Sort by distance
      nearbyItems.sort((a, b) => 
        (a.distanceInKm ?? double.infinity).compareTo(b.distanceInKm ?? double.infinity));
      
      return nearbyItems;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear filters
  void clearFilters() {
    _selectedCategoryIndex = 0;
    _priceRange = const RangeValues(0, 2000000);
    _sortOption = 'latest';
    _showAttributedOnly = false;
    notifyListeners();
  }

  // Clear all data and reload
  Future<void> refresh() async {
    _repository.clearCache();
    await loadItems(forceRefresh: true);
  }

  /// Load nearby items
  Future<void> _loadNearbyItems() async {
    _nearbyItems = await getNearbyItems(maxDistanceKm: 10.0);
    notifyListeners();
  }

  // Report an item
  Future<bool> reportItem(String itemId, String reason, String description) async {
    try {
      return await _repository.reportItem(itemId, reason, description);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Load trending items
  Future<void> loadTrendingItems() async {
    try {
      _trendingItems = await _repository.getTrendingItems(limit: 10);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update the initialize method to also load trending items
  Future<void> initialize() async {
    await loadItems();
    await loadTrendingItems();
  }

  List<String> get bookmarkedItemIds => List.unmodifiable(_bookmarkedIds);
} 