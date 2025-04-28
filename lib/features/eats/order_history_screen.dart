import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'controllers/cart_controller.dart';
import 'models/menu_item.dart';
import 'models/restaurant.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const routeName = '/order-history';

  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final CartController _cartController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cartController = CartController();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    await _cartController.initialize();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 내역'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderHistoryList(),
    );
  }

  Widget _buildOrderHistoryList() {
    final orderHistory = _cartController.orderHistory;
    
    if (orderHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '주문 내역이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 주문을 해보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('음식점 찾아보기'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderHistory.length,
      itemBuilder: (context, index) {
        final order = orderHistory[index];
        final orderDate = DateTime.parse(order['date']);
        
        // Group orders by date
        final bool showDateHeader = index == 0 || 
            !_isSameDay(
              DateTime.parse(orderHistory[index - 1]['date']), 
              orderDate
            );
            
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) _buildDateHeader(order['date']),
            _buildOrderCard(order),
          ],
        );
      },
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  Widget _buildDateHeader(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    String formattedDate;
    if (_isSameDay(date, now)) {
      formattedDate = '오늘';
    } else if (_isSameDay(date, yesterday)) {
      formattedDate = '어제';
    } else {
      // Format as month/day
      formattedDate = '${date.month}월 ${date.day}일';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Text(
        formattedDate,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order) {
    // Parse date from string
    final orderDate = DateTime.parse(order['date']);
    final restaurant = order['restaurantName'];
    final items = (order['items'] as List);
    final totalPrice = order['totalPrice'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _formatTimeFromDate(orderDate),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            // List order items
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['name']} x ${item['quantity']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '₩${_formatNumber(item['price'] * item['quantity'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총액',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₩${_formatNumber(totalPrice)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Order again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reorderItems(order),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('다시 주문하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimeFromDate(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? '오후' : '오전';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$period ${hour}:$minute';
  }
  
  String _formatNumber(dynamic number) {
    if (number is int) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } else if (number is double) {
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return number.toString();
  }
  
  void _reorderItems(Map<String, dynamic> order) {
    // Get cart controller
    final cartController = Provider.of<CartController>(context, listen: false);
    
    // Clear existing cart
    cartController.clearCart();
    
    // Create temporary restaurant
    final restaurant = Restaurant(
      id: order['restaurantId'],
      name: order['restaurantName'],
      category: "한식", // Default category
      imageUrl: "https://via.placeholder.com/500x300", // Placeholder
      imageAttribution: "",
      rating: 4.5,
      reviewCount: 100,
      deliveryTime: "30-40분",
      deliveryFee: "무료 배달",
      distance: 1.2,
    );
    
    // Set restaurant
    cartController.setRestaurant(restaurant);
    
    // Add items
    for (final item in order['items']) {
      // Create menu item
      final menuItem = MenuItem(
        id: item['id'],
        name: item['name'],
        description: "",
        price: item['price'],
        quantity: item['quantity'],
      );
      
      // Add to cart
      cartController.addItems(menuItem, item['quantity']);
    }
    
    // Navigate to checkout
    Navigator.of(context).pushNamed('/checkout');
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderHistoryItem order;
  
  const _OrderDetailsSheet({required this.order});
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 HH:mm').format(order.orderDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Order items
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '주문 항목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.entries.map((entry) {
                      final itemId = entry.key;
                      final quantity = entry.value;
                      final itemData = order.menuItemData[itemId];
                      
                      if (itemData == null) {
                        return const SizedBox.shrink();
                      }
                      
                      final name = itemData['name'] ?? 'Unknown item';
                      final price = itemData['price'] ?? 0;
                      final imageUrl = itemData['imageUrl'];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.restaurant, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'ko_KR',
                                      symbol: '₩',
                                      decimalDigits: 0,
                                    ).format(price),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${quantity}개',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 결제 금액',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'ko_KR',
                              symbol: '₩',
                              decimalDigits: 0,
                            ).format(order.totalPrice),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom actions
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('닫기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          // Get cart controller
                          final cartController = Provider.of<CartController>(
                            context, 
                            listen: false
                          );
                          
                          // Clear the cart
                          cartController.clearCart();
                          
                          // Create a Restaurant object to pass to setRestaurant
                          final restaurant = Restaurant(
                            id: order.restaurantId,
                            name: order.restaurantName,
                            category: "한식", // Default category 
                            imageUrl: "https://via.placeholder.com/500x300", // Placeholder
                            imageAttribution: "",
                            rating: 4.5,
                            reviewCount: 100,
                            deliveryTime: "30-40분",
                            deliveryFee: "무료 배달",
                            distance: 1.2,
                          );
                          
                          // Set the restaurant with only one parameter
                          cartController.setRestaurant(restaurant);
                          
                          // Add all items back to the cart
                          order.items.forEach((itemId, quantity) {
                            final itemData = order.menuItemData[itemId];
                            if (itemData != null) {
                              final menuItem = MenuItem.fromJson(itemData);
                              cartController.addItems(menuItem, quantity);
                            }
                          });
                          
                          // Close sheet and show message
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('장바구니에 추가되었습니다'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('다시 주문하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 