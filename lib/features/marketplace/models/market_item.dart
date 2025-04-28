import 'package:flutter/foundation.dart';
import 'seller.dart';

class MarketItem {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String category;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String condition;
  final bool isFavorite;
  final int viewCount;
  final int favoriteCount;
  final bool isSold;
  
  // Additional fields needed for compatibility
  final String? sellerName;
  final String? sellerAvatar;
  final String? location;
  final DateTime? postDate;
  bool isBookmarked;
  final int likes;
  final int chats;
  final bool isNegotiable;
  final String? exchangeMethod;
  final String? imageAttribution;
  final int chatCount;
  final int likesCount;
  final double? distanceInKm;
  final double? lat;
  final double? lng;
  final bool has3DModel;

  MarketItem({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.category,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.condition,
    this.isFavorite = false,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.isSold = false,
    // Additional parameters
    this.sellerName,
    this.sellerAvatar,
    this.location,
    this.postDate,
    this.isBookmarked = false,
    this.likes = 0,
    this.chats = 0,
    this.isNegotiable = false,
    this.exchangeMethod,
    this.imageAttribution = '',
    this.chatCount = 0,
    this.likesCount = 0,
    this.distanceInKm,
    this.lat,
    this.lng,
    this.has3DModel = false,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id'],
      sellerId: json['sellerId'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'USD',
      category: json['category'],
      images: List<String>.from(json['images']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      condition: json['condition'],
      isFavorite: json['isFavorite'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      favoriteCount: json['favoriteCount'] ?? 0,
      isSold: json['isSold'] ?? false,
      sellerName: json['sellerName'],
      sellerAvatar: json['sellerAvatar'],
      location: json['location'],
      postDate: json['postDate'] != null ? DateTime.parse(json['postDate']) : null,
      isBookmarked: json['isBookmarked'] ?? false,
      likes: json['likes'] ?? 0,
      chats: json['chats'] ?? 0,
      isNegotiable: json['isNegotiable'] ?? false,
      exchangeMethod: json['exchangeMethod'],
      imageAttribution: json['imageAttribution'] ?? '',
      chatCount: json['chatCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      distanceInKm: json['distanceInKm']?.toDouble(),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      has3DModel: json['has3DModel'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'condition': condition,
      'isFavorite': isFavorite,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'isSold': isSold,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'location': location,
      'postDate': postDate?.toIso8601String(),
      'isBookmarked': isBookmarked,
      'likes': likes,
      'chats': chats,
      'isNegotiable': isNegotiable,
      'exchangeMethod': exchangeMethod,
      'imageAttribution': imageAttribution,
      'chatCount': chatCount,
      'likesCount': likesCount,
      'distanceInKm': distanceInKm,
      'lat': lat,
      'lng': lng,
      'has3DModel': has3DModel,
    };
  }

  MarketItem copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? price,
    String? currency,
    String? category,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? condition,
    bool? isFavorite,
    int? viewCount,
    int? favoriteCount,
    bool? isSold,
    String? sellerName,
    String? sellerAvatar,
    String? location,
    DateTime? postDate,
    bool? isBookmarked,
    int? likes,
    int? chats,
    bool? isNegotiable,
    String? exchangeMethod,
    String? imageAttribution,
    int? chatCount,
    int? likesCount,
    double? distanceInKm,
    double? lat,
    double? lng,
    bool? has3DModel,
  }) {
    return MarketItem(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      condition: condition ?? this.condition,
      isFavorite: isFavorite ?? this.isFavorite,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isSold: isSold ?? this.isSold,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      location: location ?? this.location,
      postDate: postDate ?? this.postDate,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      likes: likes ?? this.likes,
      chats: chats ?? this.chats,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      exchangeMethod: exchangeMethod ?? this.exchangeMethod,
      imageAttribution: imageAttribution ?? this.imageAttribution,
      chatCount: chatCount ?? this.chatCount,
      likesCount: likesCount ?? this.likesCount,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      has3DModel: has3DModel ?? this.has3DModel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Add timeAgo getter
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postDate ?? createdAt);
    
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