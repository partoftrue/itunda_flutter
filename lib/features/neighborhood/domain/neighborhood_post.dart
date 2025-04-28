class NeighborhoodPost {
  final String id;
  final String author;
  final String? authorImageUrl;
  final String location;
  final String category;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likeCount;
  final bool isLiked;
  final int commentCount;

  const NeighborhoodPost({
    required this.id,
    required this.author,
    this.authorImageUrl,
    required this.location,
    required this.category,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
  });

  NeighborhoodPost copyWith({
    String? id,
    String? author,
    String? authorImageUrl,
    String? location,
    String? category,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
  }) {
    return NeighborhoodPost(
      id: id ?? this.id,
      author: author ?? this.author,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      location: location ?? this.location,
      category: category ?? this.category,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  factory NeighborhoodPost.fromJson(Map<String, dynamic> json) {
    return NeighborhoodPost(
      id: json['id'],
      author: json['author'],
      authorImageUrl: json['authorImageUrl'],
      location: json['location'],
      category: json['category'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      likeCount: json['likeCount'],
      isLiked: json['isLiked'],
      commentCount: json['commentCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'authorImageUrl': authorImageUrl,
      'location': location,
      'category': category,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
      'commentCount': commentCount,
    };
  }
}

class Comment {
  final String authorName;
  final String content;
  final DateTime postDate;
  final int likes;
  
  Comment({
    required this.authorName,
    required this.content,
    required this.postDate,
    required this.likes,
  });
} 