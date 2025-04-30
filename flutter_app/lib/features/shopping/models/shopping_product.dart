import 'package:flutter/material.dart';

class ShoppingProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isHot;
  final String? seller;
  final bool? isFreeShipping;
  final bool? isExpress;
  final String? category;
  final int quantity;

  ShoppingProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    required this.rating,
    required this.reviewCount,
    this.isNew = false,
    this.isHot = false,
    this.seller,
    this.isFreeShipping,
    this.isExpress,
    this.category,
    this.quantity = 1,
  });

  ShoppingProduct copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    double? originalPrice,
    int? discountPercentage,
    double? rating,
    int? reviewCount,
    bool? isNew,
    bool? isHot,
    String? seller,
    bool? isFreeShipping,
    bool? isExpress,
    String? category,
    int? quantity,
  }) {
    return ShoppingProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isNew: isNew ?? this.isNew,
      isHot: isHot ?? this.isHot,
      seller: seller ?? this.seller,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      isExpress: isExpress ?? this.isExpress,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }
} 