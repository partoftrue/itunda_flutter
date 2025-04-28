import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';

// Models for neighborhood feature
class Category {
  final String id;
  final String name;
  final String? icon;

  Category({
    required this.id, 
    required this.name, 
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final String categoryId;
  final String? categoryName;
  final DateTime createdAt;
  final int likes;
  final int commentCount;
  final bool isLiked;
  final List<String>? imageUrls;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.categoryId,
    this.categoryName,
    required this.createdAt,
    required this.likes,
    required this.commentCount,
    required this.isLiked,
    this.imageUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      commentCount: json['commentCount'],
      isLiked: json['isLiked'] ?? false,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
    };
  }
}

class Comment {
  final String id;
  final String content;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorProfileImage;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorProfileImage,
    required this.createdAt,
    required this.likes,
    required this.isLiked,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorProfileImage: json['authorProfileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'postId': postId,
    };
  }
}

/// Service for interacting with neighborhood API endpoints
class NeighborhoodService with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<Category> _categories = [];
  List<Post> _posts = [];
  Post? _selectedPost;
  List<Comment> _comments = [];
  
  bool _isLoadingCategories = false;
  bool _isLoadingPosts = false;
  bool _isLoadingComments = false;
  bool _isLoadingMorePosts = false;
  String? _error;
  
  NeighborhoodService(this._apiClient);
  
  // Getters
  List<Category> get categories => _categories;
  List<Post> get posts => _posts;
  Post? get selectedPost => _selectedPost;
  List<Comment> get comments => _comments;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingComments => _isLoadingComments;
  bool get isLoadingMorePosts => _isLoadingMorePosts;
  String? get error => _error;
  
  /// Fetch all categories
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.get('/categories');
      final List<dynamic> data = response;
      
      _categories = data.map((item) => Category.fromJson(item)).toList();
      _isLoadingCategories = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCategories = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }
  
  /// Fetch posts with optional filters
  Future<void> fetchPosts({
    String? categoryId,
    int page = 0,
    int size = 20,
    bool popular = false,
  }) async {
    if (page == 0) {
      _isLoadingPosts = true;
      _posts = [];
    } else {
      _isLoadingMorePosts = true;
    }
    _error = null;
    notifyListeners();
    
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      
      final endpoint = popular ? '/posts/popular' : '/posts';
      final response = await _apiClient.get(endpoint, queryParams: queryParams);
      
      final List<dynamic> data = response['content'];
      final newPosts = data.map((item) => Post.fromJson(item)).toList();
      
      if (page == 0) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }
      
      _isLoadingPosts = false;
      _isLoadingMorePosts = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPosts = false;
      _isLoadingMorePosts = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }
  
  /// Fetch a single post by ID
  Future<void> fetchPost(String postId) async {
    _isLoadingPosts = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.get('/posts/$postId');
      _selectedPost = Post.fromJson(response);
      
      _isLoadingPosts = false;
      notifyListeners();
      
      // Also fetch comments for this post
      await fetchComments(postId);
    } catch (e) {
      _isLoadingPosts = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }
  
  /// Create a new post
  Future<Post?> createPost(String title, String content, String categoryId, List<String>? imageUrls) async {
    _isLoadingPosts = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'title': title,
        'content': content,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
      };
      
      final response = await _apiClient.post('/posts', body: body);
      final newPost = Post.fromJson(response);
      
      // Add to existing posts
      _posts.insert(0, newPost);
      
      _isLoadingPosts = false;
      notifyListeners();
      return newPost;
    } catch (e) {
      _isLoadingPosts = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Update an existing post
  Future<bool> updatePost(String postId, String title, String content, String categoryId, List<String>? imageUrls) async {
    _isLoadingPosts = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'title': title,
        'content': content,
        'categoryId': categoryId,
        'imageUrls': imageUrls,
      };
      
      final response = await _apiClient.put('/posts/$postId', body: body);
      final updatedPost = Post.fromJson(response);
      
      // Update in list if it exists
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      
      // Update selected post if it's the same
      if (_selectedPost?.id == postId) {
        _selectedPost = updatedPost;
      }
      
      _isLoadingPosts = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingPosts = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a post
  Future<bool> deletePost(String postId) async {
    _error = null;
    
    try {
      await _apiClient.delete('/posts/$postId');
      
      // Remove from list if it exists
      _posts.removeWhere((post) => post.id == postId);
      
      // Clear selected post if it's the same
      if (_selectedPost?.id == postId) {
        _selectedPost = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Toggle like for a post
  Future<bool> toggleLikePost(String postId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/like');
      final isLiked = response['liked'] as bool;
      
      // Update post in list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfileImage: post.authorProfileImage,
          categoryId: post.categoryId,
          categoryName: post.categoryName,
          createdAt: post.createdAt,
          likes: isLiked ? post.likes + 1 : post.likes - 1,
          commentCount: post.commentCount,
          isLiked: isLiked,
          imageUrls: post.imageUrls,
        );
      }
      
      // Update selected post if it's the same
      if (_selectedPost?.id == postId) {
        _selectedPost = Post(
          id: _selectedPost!.id,
          title: _selectedPost!.title,
          content: _selectedPost!.content,
          authorId: _selectedPost!.authorId,
          authorName: _selectedPost!.authorName,
          authorProfileImage: _selectedPost!.authorProfileImage,
          categoryId: _selectedPost!.categoryId,
          categoryName: _selectedPost!.categoryName,
          createdAt: _selectedPost!.createdAt,
          likes: isLiked ? _selectedPost!.likes + 1 : _selectedPost!.likes - 1,
          commentCount: _selectedPost!.commentCount,
          isLiked: isLiked,
          imageUrls: _selectedPost!.imageUrls,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Fetch comments for a post
  Future<void> fetchComments(String postId) async {
    _isLoadingComments = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiClient.get('/comments/post/$postId');
      final List<dynamic> data = response;
      
      _comments = data.map((item) => Comment.fromJson(item)).toList();
      
      _isLoadingComments = false;
      notifyListeners();
    } catch (e) {
      _isLoadingComments = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }
  
  /// Add a comment to a post
  Future<Comment?> addComment(String postId, String content) async {
    _isLoadingComments = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'postId': postId,
        'content': content,
      };
      
      final response = await _apiClient.post('/comments', body: body);
      final newComment = Comment.fromJson(response);
      
      // Add to existing comments
      _comments.add(newComment);
      
      // Update comment count in post
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfileImage: post.authorProfileImage,
          categoryId: post.categoryId,
          categoryName: post.categoryName,
          createdAt: post.createdAt,
          likes: post.likes,
          commentCount: post.commentCount + 1,
          isLiked: post.isLiked,
          imageUrls: post.imageUrls,
        );
      }
      
      // Update selected post if it's the same
      if (_selectedPost?.id == postId) {
        _selectedPost = Post(
          id: _selectedPost!.id,
          title: _selectedPost!.title,
          content: _selectedPost!.content,
          authorId: _selectedPost!.authorId,
          authorName: _selectedPost!.authorName,
          authorProfileImage: _selectedPost!.authorProfileImage,
          categoryId: _selectedPost!.categoryId,
          categoryName: _selectedPost!.categoryName,
          createdAt: _selectedPost!.createdAt,
          likes: _selectedPost!.likes,
          commentCount: _selectedPost!.commentCount + 1,
          isLiked: _selectedPost!.isLiked,
          imageUrls: _selectedPost!.imageUrls,
        );
      }
      
      _isLoadingComments = false;
      notifyListeners();
      return newComment;
    } catch (e) {
      _isLoadingComments = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Update a comment
  Future<bool> updateComment(String commentId, String content) async {
    _isLoadingComments = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'content': content,
      };
      
      final response = await _apiClient.put('/comments/$commentId', body: body);
      final updatedComment = Comment.fromJson(response);
      
      // Update in list if it exists
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
      
      _isLoadingComments = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingComments = false;
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a comment
  Future<bool> deleteComment(String commentId, String postId) async {
    _error = null;
    
    try {
      await _apiClient.delete('/comments/$commentId');
      
      // Remove from list if it exists
      _comments.removeWhere((comment) => comment.id == commentId);
      
      // Update comment count in post
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfileImage: post.authorProfileImage,
          categoryId: post.categoryId,
          categoryName: post.categoryName,
          createdAt: post.createdAt,
          likes: post.likes,
          commentCount: post.commentCount - 1,
          isLiked: post.isLiked,
          imageUrls: post.imageUrls,
        );
      }
      
      // Update selected post if it's the same
      if (_selectedPost?.id == postId) {
        _selectedPost = Post(
          id: _selectedPost!.id,
          title: _selectedPost!.title,
          content: _selectedPost!.content,
          authorId: _selectedPost!.authorId,
          authorName: _selectedPost!.authorName,
          authorProfileImage: _selectedPost!.authorProfileImage,
          categoryId: _selectedPost!.categoryId,
          categoryName: _selectedPost!.categoryName,
          createdAt: _selectedPost!.createdAt,
          likes: _selectedPost!.likes,
          commentCount: _selectedPost!.commentCount - 1,
          isLiked: _selectedPost!.isLiked,
          imageUrls: _selectedPost!.imageUrls,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Toggle like for a comment
  Future<bool> toggleLikeComment(String commentId) async {
    try {
      final response = await _apiClient.post('/comments/$commentId/like');
      final isLiked = response['liked'] as bool;
      
      // Update comment in list
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        final comment = _comments[index];
        _comments[index] = Comment(
          id: comment.id,
          content: comment.content,
          postId: comment.postId,
          authorId: comment.authorId,
          authorName: comment.authorName,
          authorProfileImage: comment.authorProfileImage,
          createdAt: comment.createdAt,
          likes: isLiked ? comment.likes + 1 : comment.likes - 1,
          isLiked: isLiked,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Reset state (for logout or error conditions)
  void reset() {
    _categories = [];
    _posts = [];
    _selectedPost = null;
    _comments = [];
    _error = null;
    notifyListeners();
  }
} 