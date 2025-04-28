import 'package:flutter/foundation.dart';
import 'menu_item_option.dart';

@immutable
class MenuItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final int? quantity;
  final bool isPopular;
  final String? categoryId;
  final List<MenuItemOption>? options;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.quantity,
    this.isPopular = false,
    this.categoryId,
    this.options,
  });

  String get category => categoryId ?? '기타';

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? imageUrl,
    bool? isPopular,
    int? quantity,
    String? categoryId,
    List<MenuItemOption>? options,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      options: options ?? this.options,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'quantity': quantity,
      'categoryId': categoryId,
      'options': options,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      imageUrl: json['imageUrl'] as String?,
      quantity: json['quantity'] as int?,
      isPopular: json['isPopular'] as bool? ?? false,
      categoryId: json['categoryId'] as String?,
      options: json['options'] as List<MenuItemOption>?,
    );
  }
} 