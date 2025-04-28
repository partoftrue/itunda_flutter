class Comment {
  final String id;
  final String postId;
  final String author;
  final String? authorImageUrl;
  final String content;
  final DateTime timestamp;
  final int likeCount;
  final bool isLiked;

  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    this.authorImageUrl,
    required this.content,
    required this.timestamp,
    required this.likeCount,
    required this.isLiked,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? author,
    String? authorImageUrl,
    String? content,
    DateTime? timestamp,
    int? likeCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      author: json['author'],
      authorImageUrl: json['authorImageUrl'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likeCount: json['likeCount'],
      isLiked: json['isLiked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }
} 