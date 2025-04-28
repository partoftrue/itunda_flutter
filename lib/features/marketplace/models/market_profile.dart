class MarketProfile {
  final String id;
  final String userId;
  final String displayName;
  final String? avatar;
  final String? bio;
  final double rating;
  final int reviewCount;
  final int itemsCount;
  final int soldItemsCount;
  final DateTime joinedAt;
  final DateTime? lastActive;
  final bool isVerified;
  final Map<String, dynamic>? contactInfo;

  MarketProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatar,
    this.bio,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.itemsCount = 0,
    this.soldItemsCount = 0,
    required this.joinedAt,
    this.lastActive,
    this.isVerified = false,
    this.contactInfo,
  });

  factory MarketProfile.fromJson(Map<String, dynamic> json) {
    return MarketProfile(
      id: json['id'],
      userId: json['userId'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      bio: json['bio'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      itemsCount: json['itemsCount'] ?? 0,
      soldItemsCount: json['soldItemsCount'] ?? 0,
      joinedAt: DateTime.parse(json['joinedAt']),
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      contactInfo: json['contactInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'avatar': avatar,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'itemsCount': itemsCount,
      'soldItemsCount': soldItemsCount,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'isVerified': isVerified,
      'contactInfo': contactInfo,
    };
  }

  MarketProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatar,
    String? bio,
    double? rating,
    int? reviewCount,
    int? itemsCount,
    int? soldItemsCount,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isVerified,
    Map<String, dynamic>? contactInfo,
  }) {
    return MarketProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      itemsCount: itemsCount ?? this.itemsCount,
      soldItemsCount: soldItemsCount ?? this.soldItemsCount,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
      isVerified: isVerified ?? this.isVerified,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
} 