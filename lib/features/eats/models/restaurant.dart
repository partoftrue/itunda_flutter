import 'package:flutter/foundation.dart';
import 'menu_item.dart';

@immutable
class Restaurant {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String imageAttribution;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final double distance;
  final bool isPromoted;
  final List<String> tags;
  final Map<String, List<MenuItem>> menuCategories;
  final String description;
  final String address;
  final String phone;
  final List<String> businessHours;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.imageAttribution,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.distance,
    this.isPromoted = false,
    this.tags = const [],
    this.menuCategories = const {},
    this.description = '',
    this.address = '',
    this.phone = '',
    this.businessHours = const [],
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    String? imageAttribution,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
    String? deliveryFee,
    double? distance,
    bool? isPromoted,
    List<String>? tags,
    Map<String, List<MenuItem>>? menuCategories,
    String? description,
    String? address,
    String? phone,
    List<String>? businessHours,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAttribution: imageAttribution ?? this.imageAttribution,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      distance: distance ?? this.distance,
      isPromoted: isPromoted ?? this.isPromoted,
      tags: tags ?? this.tags,
      menuCategories: menuCategories ?? this.menuCategories,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      businessHours: businessHours ?? this.businessHours,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'imageAttribution': imageAttribution,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'distance': distance,
      'isPromoted': isPromoted,
      'tags': tags,
      'menuCategories': menuCategories.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'description': description,
      'address': address,
      'phone': phone,
      'businessHours': businessHours,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      imageAttribution: json['imageAttribution'] as String,
      rating: json['rating'] as double,
      reviewCount: json['reviewCount'] as int,
      deliveryTime: json['deliveryTime'] as String,
      deliveryFee: json['deliveryFee'] as String,
      distance: json['distance'] as double,
      isPromoted: json['isPromoted'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      menuCategories: (json['menuCategories'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => MenuItem.fromJson(e)).toList(),
            ),
          ) ??
          {},
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      businessHours: List<String>.from(json['businessHours'] ?? []),
    );
  }
} 