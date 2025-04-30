import 'package:flutter/material.dart';
import '../models/shopping_product.dart';
import 'package:flutter/foundation.dart';

class ShoppingProvider extends ChangeNotifier {
  // Product lists
  final List<ShoppingProduct> _flashDeals = [];
  final List<ShoppingProduct> _recommendations = [];
  final List<ShoppingProduct> _products = [];
  final List<ShoppingProduct> _cartItems = [];
  final List<String> _favoriteIds = [];
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ShoppingProduct> get flashDeals => _flashDeals;
  List<ShoppingProduct> get recommendations => _recommendations;
  List<ShoppingProduct> get products => _products;
  List<ShoppingProduct> get cartItems => _cartItems;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartItemCount => _cartItems.length;
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.price);
  
  // Promotion banners
  final List<Map<String, dynamic>> _promotionBanners = [
    {
      'title': '여름 쇼핑 특가',
      'subtitle': '인기 여름 상품 최대 50% 할인',
      'color': Colors.blue,
      'iconData': Icons.wb_sunny,
    },
    {
      'title': '신규 고객 혜택',
      'subtitle': '첫 구매 시 15% 추가 할인',
      'color': Colors.green,
      'iconData': Icons.card_giftcard,
    },
    {
      'title': '무료 배송 이벤트',
      'subtitle': '5만원 이상 구매 시 무료 배송',
      'color': Colors.orange,
      'iconData': Icons.local_shipping,
    },
  ];
  
  // Categories
  final List<Map<String, dynamic>> _categories = [
    {'name': '전체', 'icon': Icons.all_inclusive},
    {'name': '전자제품', 'icon': Icons.devices},
    {'name': '패션/잡화', 'icon': Icons.checkroom},
    {'name': '뷰티', 'icon': Icons.face},
    {'name': '생활용품', 'icon': Icons.home},
    {'name': '가구/인테리어', 'icon': Icons.chair},
    {'name': '건강식품', 'icon': Icons.favorite},
    {'name': '스포츠/레저', 'icon': Icons.sports_basketball},
  ];
  
  // Getters for static data
  List<Map<String, dynamic>> get promotionBanners => _promotionBanners;
  List<Map<String, dynamic>> get categories => _categories;
  
  // Methods
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Sample data - replace with API response
      _products.clear();
      _products.addAll([
        ShoppingProduct(
          id: '1',
          name: '애플 아이폰 14 Pro',
          imageUrl: 'https://images.unsplash.com/photo-1670272502246-768d249768ca?w=800',
          price: 1500000,
          rating: 4.8,
          reviewCount: 120,
          isNew: true,
        ),
        ShoppingProduct(
          id: '2',
          name: '나이키 운동화',
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
          price: 120000,
          rating: 4.5,
          reviewCount: 85,
          isHot: true,
        ),
        ShoppingProduct(
          id: '3',
          name: '삼성 갤럭시 S23',
          imageUrl: 'https://images.unsplash.com/photo-1670272502246-768d249768ca?w=800',
          price: 1200000,
          rating: 4.7,
          reviewCount: 95,
          isNew: true,
        ),
        ShoppingProduct(
          id: '4',
          name: '애플 에어팟 프로',
          imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800',
          price: 350000,
          rating: 4.6,
          reviewCount: 75,
          isHot: true,
        ),
      ]);
      
      // Load flash deals and recommendations
      _loadFlashDeals();
      _loadRecommendations();
      
    } catch (e) {
      _error = '상품을 불러오는 중 오류가 발생했습니다: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadFlashDeals() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _flashDeals.clear();
      _flashDeals.addAll(_products.where((product) => product.isNew || product.isHot));
    } catch (e) {
      _error = '특가 상품을 불러오는 중 오류가 발생했습니다: $e';
    }
  }
  
  Future<void> _loadRecommendations() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _recommendations.clear();
      _recommendations.addAll(_products.where((product) => product.rating >= 4.5));
    } catch (e) {
      _error = '추천 상품을 불러오는 중 오류가 발생했습니다: $e';
    }
  }
  
  List<ShoppingProduct> getProductsByCategory(String category) {
    if (category == '전체') {
      return [..._flashDeals, ..._recommendations];
    }
    return [..._flashDeals, ..._recommendations]
        .where((product) => product.category == category)
        .toList();
  }
  
  ShoppingProduct? getProductById(String id) {
    try {
      return [..._flashDeals, ..._recommendations]
          .firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Cart management
  void addToCart(ShoppingProduct product) {
    if (!_cartItems.any((item) => item.id == product.id)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }
  
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
  
  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  // Favorites management
  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }
  
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }
  
  List<ShoppingProduct> getFavorites() {
    return [..._flashDeals, ..._recommendations]
        .where((product) => _favoriteIds.contains(product.id))
        .toList();
  }
} 