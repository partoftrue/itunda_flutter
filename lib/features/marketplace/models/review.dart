import 'package:flutter/foundation.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String itemId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.itemId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      itemId: json['itemId'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'itemId': itemId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }

  // Copy with method for creating a copy with modified fields
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? itemId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      itemId: itemId ?? this.itemId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 