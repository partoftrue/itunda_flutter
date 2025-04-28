import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itunda/features/neighborhood/domain/models/post.dart';
import 'package:itunda/features/neighborhood/domain/models/comment.dart';
import 'package:itunda/features/neighborhood/domain/models/category.dart' as neighborhood_models;
import 'package:itunda/features/neighborhood/domain/repositories/neighborhood_repository.dart';
import 'package:itunda/features/neighborhood/data/repositories/mock_neighborhood_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:itunda/core/network/neighborhood_socket_service.dart';
import 'dart:convert';

enum NeighborhoodStatus {
  initial,
  loading,
  loaded,
  error,
}

enum CommentSortType {
  latest,
  oldest,
  popular,
}

class NeighborhoodProvider extends ChangeNotifier {
  NeighborhoodSocketService? _socketService;

  final NeighborhoodRepository _repository;
  
  // Data
  List<Post> _posts = [];
  List<Post> _popularPosts = [];
  Post? _selectedPost;
  List<Comment> _comments = [];
  List<neighborhood_models.Category> _categories = [];
  String _selectedCategory = '전체';
  String _currentLocation = '서울시 강남구';
  Map<String, Post> _postDetails = {};
  Map<String, List<Comment>> _commentsMap = {};
  CommentSortType _commentSortType = CommentSortType.latest;
  final StreamController<String> _toastController = StreamController<String>.broadcast();
  
  // Pagination
  int _currentPage = 0;
  bool _hasMorePosts = true;
  bool _isRefreshing = false;
  
  // State
  NeighborhoodStatus _status = NeighborhoodStatus.initial;
  String? _errorMessage;

  // Debouncing
  final Map<String, Timer> _likeDebounceTimers = {};
  final Map<String, bool> _pendingLikeOperations = {};
  
  // Add this property to track if distance filter is applied
  bool _filteredByDistance = false;
  List<Post> _filteredPosts = [];
  
  NeighborhoodProvider({
    NeighborhoodRepository? repository,
    String initialLocation = '서울시 강남구',
  }) : _repository = repository ?? MockNeighborhoodRepository(),
       _currentLocation = initialLocation {
    initSocket();
  }

  void initSocket() {
    _socketService = NeighborhoodSocketService();
    _socketService!.connect(onEvent: (event) {
      if (event['type'] == 'NEW_POST') {
        try {
          final newPost = Post.fromJson(event['payload']);
          _posts.insert(0, newPost);
          notifyListeners();
        } catch (e) {
          print('Failed to parse NEW_POST event: $e');
        }
      } else if (event['type'] == 'NEW_COMMENT') {
        try {
          // Optionally, update comments if the selected post matches
          if (_selectedPost != null && event['payload']['postId'] == _selectedPost!.id) {
            final newComment = Comment.fromJson(event['payload']);
            _comments.add(newComment);
            notifyListeners();
          }
        } catch (e) {
          print('Failed to parse NEW_COMMENT event: $e');
        }
      }
    });
  }
  
  // Getters
  NeighborhoodStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Post> get posts => _posts;
  List<Post> get popularPosts => _popularPosts;
  List<Comment> get comments => _sortComments();
  List<neighborhood_models.Category> get categories => _categories;
  Post? get selectedPost => _selectedPost;
  String get selectedCategory => _selectedCategory;
  String get currentLocation => _currentLocation;
  CommentSortType get commentSortType => _commentSortType;
  bool get hasMorePosts => _hasMorePosts;
  bool get isRefreshing => _isRefreshing;
  Stream<String> get toastStream => _toastController.stream;
  
  // Show a toast message
  void showToast(String message) {
    _toastController.add(message);
  }
  
  List<Comment> _sortComments() {
    final sortedComments = List<Comment>.from(_comments);
    
    switch (_commentSortType) {
      case CommentSortType.latest:
        sortedComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CommentSortType.oldest:
        sortedComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case CommentSortType.popular:
        sortedComments.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
    }
    
    return sortedComments;
  }
  
  void setCommentSortType(CommentSortType sortType) {
    if (_commentSortType != sortType) {
      _commentSortType = sortType;
      notifyListeners();
    }
  }
  
  // Initial data fetch
  Future<void> fetchInitialData() async {
    if (_status == NeighborhoodStatus.loading) return;
    
    _status = NeighborhoodStatus.loading;
    _currentPage = 0;
    _hasMorePosts = true;
    notifyListeners();
    
    try {
      // Get categories and posts in parallel
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getPosts(category: _selectedCategory, page: 0),
      ]);
      
      _categories = results[0] as List<neighborhood_models.Category>;
      _posts = results[1] as List<Post>;
      
      _status = NeighborhoodStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch more posts
  Future<void> fetchPosts() async {
    if (_status == NeighborhoodStatus.loading || !_hasMorePosts) return;
    
    _status = NeighborhoodStatus.loading;
    notifyListeners();
    
    try {
      final newPosts = await _repository.getPosts(
        category: _selectedCategory,
        page: _currentPage + 1,
      );
      
      if (newPosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _posts.addAll(newPosts);
        _currentPage++;
      }
      
      _status = NeighborhoodStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Refresh posts
  Future<void> refreshPosts() async {
    _isRefreshing = true;
    _currentPage = 0;
    _hasMorePosts = true;
    
    try {
      final newPosts = await _repository.getPosts(
        category: _selectedCategory,
        page: 0,
      );
      
      _posts = newPosts;
      _status = NeighborhoodStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
  
  void setSelectedCategory(String category) {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    _currentPage = 0;
    _hasMorePosts = true;
    _posts = [];
    _status = NeighborhoodStatus.loading;
    
    notifyListeners();
    
    _repository.getPosts(category: category, page: 0).then((newPosts) {
      _posts = newPosts;
      _status = NeighborhoodStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    }).catchError((e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    });
  }
  
  void setCurrentLocation(String location) {
    _currentLocation = location;
    notifyListeners();
    refreshPosts();
  }
  
  Future<Post?> getPostById(String postId) async {
    _status = NeighborhoodStatus.loading;
    notifyListeners();
    
    try {
      final post = await _repository.getPostById(postId);
      _selectedPost = post;
      _status = NeighborhoodStatus.loaded;
      notifyListeners();
      return post;
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = 'Failed to get post: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
  
  Future<Post?> getPostDetails(String postId) async {
    // Return cached post details if available
    if (_postDetails.containsKey(postId)) {
      return _postDetails[postId];
    }
    
    try {
      final post = await _repository.getPostById(postId);
      if (post != null) {
        _postDetails[postId] = post;
        
        // Update the post in the list if it exists
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = post;
        }
        
        notifyListeners();
      }
      return post;
    } catch (e) {
      // Handle error but don't update overall status
      return null;
    }
  }
  
  // Get comments for a post
  Future<List<Comment>> getComments(String postId) async {
    if (_commentsMap.containsKey(postId)) {
      return _commentsMap[postId]!;
    }
    
    try {
      final comments = await _repository.getComments(postId);
      _commentsMap[postId] = comments;
      notifyListeners();
      return comments;
    } catch (e) {
      return [];
    }
  }
  
  // Like a post with debounce and optimistic update
  Future<void> likePost(String postId) async {
    // Prevent rapid fire like/unlike
    if (_pendingLikeOperations[postId] == true) {
      return;
    }
    
    // Cancel any existing debounce timer
    _likeDebounceTimers[postId]?.cancel();
    
    // Mark this post as having a pending like operation
    _pendingLikeOperations[postId] = true;
    
    // Get current post state
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final detailsPost = _postDetails[postId];
    
    // Apply optimistic update to local state
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final updatedPost = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      _posts[postIndex] = updatedPost;
      
      // Also update in details if present
      if (detailsPost != null) {
        _postDetails[postId] = updatedPost;
      }
      
      notifyListeners();
    }
    
    // Debounce the actual API call
    _likeDebounceTimers[postId] = Timer(const Duration(milliseconds: 500), () async {
      try {
        final post = _posts.firstWhere((p) => p.id == postId);
        await _repository.toggleLike(postId, post.isLiked);
        
        // Request completed successfully, no need to revert
      } catch (e) {
        // Revert optimistic update on error
        if (postIndex != -1) {
          final post = _posts[postIndex];
          final revertedPost = post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
          );
          _posts[postIndex] = revertedPost;
          
          if (detailsPost != null) {
            _postDetails[postId] = revertedPost;
          }
          
          notifyListeners();
        }
        _toastController.add('좋아요 업데이트에 실패했습니다.');
      } finally {
        _pendingLikeOperations[postId] = false;
      }
    });
  }
  
  // Add a comment with optimistic update
  Future<bool> addComment(String postId, String content) async {
    final authorId = "current_user_id"; // In a real app, get from auth service
    final authorName = "현재 사용자"; // In a real app, get from auth service
    
    // Create an optimistic comment
    final optimisticComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
    );
    
    // Apply optimistic update to comments
    if (!_commentsMap.containsKey(postId)) {
      _commentsMap[postId] = [];
    }
    _commentsMap[postId]!.add(optimisticComment);
    
    // Update post comment count
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = post.copyWith(commentsCount: post.commentsCount + 1);
    }
    
    if (_postDetails.containsKey(postId)) {
      final post = _postDetails[postId]!;
      _postDetails[postId] = post.copyWith(commentsCount: post.commentsCount + 1);
    }
    
    notifyListeners();
    
    try {
      // Send to repository
      final commentId = await _repository.addComment(optimisticComment);
      
      // Replace optimistic comment with real one from server
      await getComments(postId);
      _toastController.add('댓글이 작성되었습니다.');
      return true;
    } catch (e) {
      // Revert optimistic updates on error
      _commentsMap[postId]!.remove(optimisticComment);
      
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(commentsCount: post.commentsCount - 1);
      }
      
      if (_postDetails.containsKey(postId)) {
        final post = _postDetails[postId]!;
        _postDetails[postId] = post.copyWith(commentsCount: post.commentsCount - 1);
      }
      
      _toastController.add('댓글 작성에 실패했습니다.');
      notifyListeners();
      return false;
    }
  }
  
  // Create a new post
  Future<String?> createPost(Post post) async {
    try {
      final postId = await _repository.createPost(post);
      
      // Add to posts with optimistic update
      final newPost = post.copyWith(
        id: postId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        commentsCount: 0,
        likesCount: 0,
      );
      
      _posts.insert(0, newPost);
      _toastController.add('게시물이 작성되었습니다.');
      notifyListeners();
      
      return postId;
    } catch (e) {
      _toastController.add('게시물 작성에 실패했습니다.');
      return null;
    }
  }
  
  // Update an existing post
  Future<void> updatePost(Post post) async {
    _status = NeighborhoodStatus.loading;
    notifyListeners();
    
    try {
      await _repository.updatePost(post);
      
      // Update in posts list
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post;
      }
      
      // Update selected post
      if (_selectedPost?.id == post.id) {
        _selectedPost = post;
      }
      
      _status = NeighborhoodStatus.loaded;
      _toastController.add('게시물이 수정되었습니다.');
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = 'Failed to update post: ${e.toString()}';
      _toastController.add('게시물 수정에 실패했습니다.');
    }
    
    notifyListeners();
  }
  
  // Delete post
  Future<bool> deletePost(String postId) async {
    // Optimistic update
    final deletedPost = _posts.firstWhere((p) => p.id == postId);
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    
    _posts.removeAt(postIndex);
    _postDetails.remove(postId);
    notifyListeners();
    
    try {
      await _repository.deletePost(postId);
      _toastController.add('게시물이 삭제되었습니다.');
      return true;
    } catch (e) {
      // Revert on error
      _posts.insert(postIndex, deletedPost);
      _postDetails[postId] = deletedPost;
      _toastController.add('게시물 삭제에 실패했습니다.');
      notifyListeners();
      return false;
    }
  }
  
  // Like a comment
  Future<void> likeComment(String commentId, String postId) async {
    // Find comment
    if (!_commentsMap.containsKey(postId)) return;
    
    final commentIndex = _commentsMap[postId]!.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;
    
    // Optimistic update
    final comment = _commentsMap[postId]![commentIndex];
    final updatedComment = comment.copyWith(
      isLiked: !comment.isLiked,
      likesCount: comment.isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
    );
    
    _commentsMap[postId]![commentIndex] = updatedComment;
    notifyListeners();
    
    try {
      await _repository.toggleCommentLike(postId, commentId, updatedComment.isLiked);
    } catch (e) {
      // Revert on error
      _commentsMap[postId]![commentIndex] = comment;
      _toastController.add('댓글 좋아요 업데이트에 실패했습니다.');
      notifyListeners();
    }
  }
  
  Future<void> fetchPopularPosts() async {
    try {
      _popularPosts = await _repository.getPopularPosts();
      notifyListeners();
    } catch (e) {
      // Don't change status for popular posts, just log error and show toast
      print('Failed to fetch popular posts: ${e.toString()}');
      _toastController.add('인기 게시물을 불러오는데 실패했습니다.');
    }
  }
  
  Future<void> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: ${e.toString()}';
      notifyListeners();
    }
  }
  
  void clearSelectedPost() {
    _selectedPost = null;
    _comments = [];
    notifyListeners();
  }
  
  void resetStatus() {
    _status = NeighborhoodStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _socketService?.disconnect();
    // Cancel all debounce timers
    for (final timer in _likeDebounceTimers.values) {
      timer.cancel();
    }
    _toastController.close();
    super.dispose();
  }
  
  // For compatibility with post_detail_screen.dart
  Future<void> fetchPostById(String postId) async {
    await getPostById(postId);
  }
  
  Future<void> fetchComments(String postId) async {
    if (_selectedPost != null && _selectedPost!.id == postId) {
      _comments = await getComments(postId);
      notifyListeners();
      return;
    }
    
    _status = NeighborhoodStatus.loading;
    notifyListeners();
    
    try {
      final post = await _repository.getPostById(postId);
      if (post != null) {
        _selectedPost = post;
        _comments = await getComments(postId);
        _status = NeighborhoodStatus.loaded;
      } else {
        _status = NeighborhoodStatus.error;
        _errorMessage = 'Post not found';
      }
    } catch (e) {
      _status = NeighborhoodStatus.error;
      _errorMessage = 'Failed to get post and comments: ${e.toString()}';
    }
    
    notifyListeners();
  }
  
  // Filter posts based on current filters
  void _filterPosts() {
    // If there are no filters applied, use all posts
    if (_selectedCategory == '전체' && !_filteredByDistance) {
      _filteredPosts = _posts;
      return;
    }
    
    // Apply category filter
    final filtered = _posts.where((post) {
      if (_selectedCategory != '전체' && post.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();
    
    _filteredPosts = filtered;
  }
  
  // Add this method to filter posts by distance
  void filterByDistance(double? distanceInKm) {
    if (distanceInKm == null) {
      // If distance is null, reset to original posts (no distance filter)
      if (_filteredByDistance) {
        _filteredByDistance = false;
        _filterPosts(); // Apply any other existing filters
        notifyListeners();
      }
      return;
    }
    
    _filteredByDistance = true;
    
    // Filter posts by distance - distance is now from location string, treat all posts as in range
    // Since Post doesn't have a distance property, all posts pass the filter for now
    final filteredPosts = _posts.where((post) {
      // Use a boolean check that will pass for all posts
      return true; // Later can be replaced with actual distance logic
    }).toList();
    
    _filteredPosts = filteredPosts;
    notifyListeners();
  }
} 