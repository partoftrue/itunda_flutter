import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itunda/features/eats/models/restaurant.dart';

class OrderHistoryItem {
  final String restaurantId;
  final String restaurantName;
  final DateTime orderDate;
  final Map<String, int> items;
  final Map<String, dynamic> menuItemData;
  final int totalPrice;

  OrderHistoryItem({
    required this.restaurantId,
    required this.restaurantName,
    required this.orderDate,
    required this.items,
    required this.menuItemData,
    required this.totalPrice,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      orderDate: DateTime.parse(json['orderDate']),
      items: Map<String, int>.from(json['items']),
      menuItemData: json['menuItemData'],
      totalPrice: json['totalPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'orderDate': orderDate.toIso8601String(),
      'items': items,
      'menuItemData': menuItemData,
      'totalPrice': totalPrice,
    };
  }
}

class CartController extends ChangeNotifier {
  static const String _cartItemsKey = 'cart_items';
  static const String _menuItemCacheKey = 'menu_item_cache';
  static const String _orderHistoryCountKey = 'order_history_count';
  
  // Private state
  final List<MenuItem> _items = [];
  Restaurant? _restaurant;
  int _totalItemCount = 0;
  double _totalPriceValue = 0;
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = false;
  
  // Getters
  List<MenuItem> get items => List.unmodifiable(_items);
  Restaurant? get restaurant => _restaurant;
  int get totalItems => _totalItemCount;
  double get totalPrice => _totalPriceValue;
  bool get hasItems => _items.isNotEmpty;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  
  // Initialize the cart
  Future<void> initialize() async {
    await _loadCartFromStorage();
    await _loadOrderHistory();
  }
  
  // Set the restaurant for the cart
  void setRestaurant(Restaurant restaurant) {
    if (_restaurant != null && _restaurant!.id != restaurant.id && _items.isNotEmpty) {
      _items.clear();
      _totalItemCount = 0;
      _totalPriceValue = 0;
      notifyListeners();
    }
    _restaurant = restaurant;
  }
  
  // Add an item to the cart
  void addToCart(MenuItem item) {
    final index = _findItemIndex(item.id);
    
    if (index >= 0) {
      // Item exists, increase quantity
      final currentItem = _items[index];
      final updatedQuantity = (currentItem.quantity ?? 0) + 1;
      _items[index] = currentItem.copyWith(quantity: updatedQuantity);
    } else {
      // New item 
      _items.add(item.copyWith(quantity: 1));
    }
    
    _updateTotals();
    _saveCartToStorage();
  }
  
  // Add multiple items to the cart
  void addItems(MenuItem item, int quantity) {
    final index = _findItemIndex(item.id);
    
    if (index >= 0) {
      // Item exists, increase quantity
      final currentItem = _items[index];
      final updatedQuantity = (currentItem.quantity ?? 0) + quantity;
      _items[index] = currentItem.copyWith(quantity: updatedQuantity);
    } else {
      // New item
      _items.add(item.copyWith(quantity: quantity));
    }
    
    _updateTotals();
    _saveCartToStorage();
  }
  
  // Remove an item from the cart
  void removeFromCart(MenuItem item) {
    final index = _findItemIndex(item.id);
    
    if (index >= 0) {
      final currentItem = _items[index];
      final currentQuantity = currentItem.quantity ?? 0;
      
      if (currentQuantity > 1) {
        // Decrease quantity
        _items[index] = currentItem.copyWith(quantity: currentQuantity - 1);
      } else {
        // Remove item
        _items.removeAt(index);
      }
      
      _updateTotals();
      _saveCartToStorage();
    }
  }
  
  // Clear the cart
  void clearCart() {
    _items.clear();
    _totalItemCount = 0;
    _totalPriceValue = 0;
    notifyListeners();
    _saveCartToStorage();
  }
  
  // Get the quantity of an item in the cart
  int getQuantity(String itemId) {
    final index = _findItemIndex(itemId);
    return index >= 0 ? (_items[index].quantity ?? 0) : 0;
  }
  
  // Update totals
  void _updateTotals() {
    int itemCount = 0;
    double totalPrice = 0;
    
    for (final item in _items) {
      final quantity = item.quantity ?? 0;
      itemCount += quantity;
      totalPrice += item.price * quantity;
    }
    
    _totalItemCount = itemCount;
    _totalPriceValue = totalPrice;
    notifyListeners();
  }
  
  // Find the index of an item in the cart
  int _findItemIndex(String itemId) {
    return _items.indexWhere((item) => item.id == itemId);
  }
  
  // Place an order
  Future<bool> placeOrder() async {
    if (_items.isEmpty || _restaurant == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Create order record
      final order = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'restaurantId': _restaurant!.id,
        'restaurantName': _restaurant!.name,
        'items': _items.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity ?? 0,
        }).toList(),
        'totalPrice': _totalPriceValue,
        'date': DateTime.now().toIso8601String(),
        'status': 'processing',
      };
      
      // Add to order history
      _orderHistory.insert(0, order);
      await _saveOrderHistory();
      
      // Clear the cart
      clearCart();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Load cart from shared preferences
  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');
      final restaurantString = prefs.getString('restaurant');
      
      if (cartString != null && cartString.isNotEmpty) {
        final cartData = json.decode(cartString) as List;
        final itemsList = cartData.map((item) => MenuItem.fromJson(item)).toList();
        
        _items.clear();
        _items.addAll(itemsList);
      }
      
      if (restaurantString != null && restaurantString.isNotEmpty) {
        _restaurant = Restaurant.fromJson(json.decode(restaurantString));
      }
      
      _updateTotals();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
  
  // Save cart to shared preferences
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartString);
      
      if (_restaurant != null) {
        final restaurantString = json.encode(_restaurant!.toJson());
        await prefs.setString('restaurant', restaurantString);
      }
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }
  
  // Load order history from shared preferences
  Future<void> _loadOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('order_history');
      
      if (historyString != null && historyString.isNotEmpty) {
        final historyData = json.decode(historyString) as List;
        _orderHistory = List<Map<String, dynamic>>.from(historyData);
      }
    } catch (e) {
      debugPrint('Error loading order history: $e');
    }
  }
  
  // Save order history to shared preferences
  Future<void> _saveOrderHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = json.encode(_orderHistory);
      await prefs.setString('order_history', historyString);
    } catch (e) {
      debugPrint('Error saving order history: $e');
    }
  }
} 