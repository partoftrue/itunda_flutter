import 'package:flutter/foundation.dart';

class Seller {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewCount;
  final int itemCount;
  final DateTime joinDate;
  final String? location;
  final double? transactionRate;
  final double? responseRate;
  final String? responseTime;
  final int? followerCount;

  const Seller({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewCount, 
    required this.itemCount,
    required this.joinDate,
    this.location,
    this.transactionRate,
    this.responseRate,
    this.responseTime,
    this.followerCount,
  });

  // Factory constructor to create from JSON
  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      itemCount: json['item_count'],
      joinDate: DateTime.parse(json['join_date']),
      location: json['location'],
      transactionRate: json['transaction_rate'] != null ? (json['transaction_rate'] as num).toDouble() : null,
      responseRate: json['response_rate'] != null ? (json['response_rate'] as num).toDouble() : null,
      responseTime: json['response_time'],
      followerCount: json['follower_count'],
    );
  }

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'rating': rating,
      'review_count': reviewCount,
      'item_count': itemCount,
      'join_date': joinDate.toIso8601String(),
      'location': location,
      'transaction_rate': transactionRate,
      'response_rate': responseRate,
      'response_time': responseTime,
      'follower_count': followerCount,
    };
  }

  // Copy with method for creating a copy with modified fields
  Seller copyWith({
    String? id,
    String? name,
    String? avatar,
    double? rating,
    int? reviewCount,
    int? itemCount,
    DateTime? joinDate,
    String? location,
    double? transactionRate,
    double? responseRate,
    String? responseTime,
    int? followerCount,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      itemCount: itemCount ?? this.itemCount,
      joinDate: joinDate ?? this.joinDate,
      location: location ?? this.location,
      transactionRate: transactionRate ?? this.transactionRate,
      responseRate: responseRate ?? this.responseRate,
      responseTime: responseTime ?? this.responseTime,
      followerCount: followerCount ?? this.followerCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Seller &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 