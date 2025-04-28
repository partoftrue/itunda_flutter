import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/neighborhood_post.dart';
import '../domain/neighborhood_repository_interface.dart';
import 'api/neighborhood_api_service.dart';
import 'models/post_dto.dart';
import 'models/comment_dto.dart';

/// Implementation of the NeighborhoodRepositoryInterface
class NeighborhoodRepositoryImpl implements NeighborhoodRepositoryInterface {
  final NeighborhoodApiService _apiService;
  final List<NeighborhoodPost> _localPosts = [];
  final Map<String, List<Comment>> _localComments = {};
  final Uuid _uuid = const Uuid();
  
  // For storing current user information
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  
  NeighborhoodRepositoryImpl(this._apiService);
  
  /// Get current user ID from preferences (mock for demo)
  Future<String> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString(_userIdKey);
    if (userId == null) {
      userId = _uuid.v4();
      await prefs.setString(_userIdKey, userId);
    }
    return userId;
  }
  
  /// Get current user name from preferences (mock for demo)
  Future<String> _getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString(_userNameKey);
    if (userName == null) {
      userName = '익명사용자';
      await prefs.setString(_userNameKey, userName);
    }
    return userName;
  }
  
  @override
  Future<List<NeighborhoodPost>> getAllPosts() async {
    // Try to get posts from server
    final result = await _apiService.getPosts();
    
    if (result.isSuccess && result.data != null) {
      // If successful, update local cache and return domain models
      _localPosts.clear();
      final posts = result.data!.map((dto) => dto.toDomain()).toList();
      _localPosts.addAll(posts);
      return posts;
    } else {
      // If network error, return cached data
      if (_localPosts.isEmpty) {
        // If no cached data, load mock data
        _loadSamplePosts();
      }
      return _localPosts;
    }
  }
  
  @override
  Future<List<NeighborhoodPost>> getPostsByCategory(String category) async {
    if (category == '전체') {
      return getAllPosts();
    }
    
    // Try to get posts from server
    final result = await _apiService.getPostsByCategory(category);
    
    if (result.isSuccess && result.data != null) {
      // If successful, update local cache for this category and return domain models
      final posts = result.data!.map((dto) => dto.toDomain()).toList();
      return posts;
    } else {
      // If network error, filter cached data
      if (_localPosts.isEmpty) {
        // If no cached data, load mock data
        _loadSamplePosts();
      }
      return _localPosts.where((post) => post.category == category).toList();
    }
  }
  
  @override
  Future<NeighborhoodPost?> getPostById(String id) async {
    final result = await _apiService.getPostById(id);
    
    if (result.isSuccess && result.data != null) {
      final post = result.data!.toDomain();
      // Update local cache
      final index = _localPosts.indexWhere((p) => p.title == post.title);
      if (index >= 0) {
        _localPosts[index] = post;
      } else {
        _localPosts.add(post);
      }
      return post;
    } else {
      // Try to find in local cache
      return _localPosts.firstWhere(
        (post) => post.title == id,
        orElse: () => throw Exception('Post not found'),
      );
    }
  }
  
  @override
  Future<NeighborhoodPost> createPost(NeighborhoodPost post) async {
    // Get user information
    final authorId = await _getCurrentUserId();
    final authorName = await _getCurrentUserName();
    
    // Create DTO
    final postDto = PostDTO.fromDomain(
      post,
      id: _uuid.v4(),
      authorId: authorId,
    );
    
    // Send to server
    final result = await _apiService.createPost(postDto);
    
    if (result.isSuccess && result.data != null) {
      final createdPost = result.data!.toDomain();
      // Update local cache
      _localPosts.add(createdPost);
      return createdPost;
    } else {
      // For demo/offline mode, add to local cache with generated values
      final now = DateTime.now();
      final newPost = NeighborhoodPost(
        category: post.category,
        title: post.title,
        content: post.content,
        authorName: authorName,
        location: '현위치',
        likes: 0,
        comments: 0,
        postDate: now,
        images: post.images,
      );
      
      _localPosts.add(newPost);
      return newPost;
    }
  }
  
  @override
  Future<NeighborhoodPost> updatePost(String id, NeighborhoodPost post) async {
    // Get user information
    final authorId = await _getCurrentUserId();
    
    // Create DTO
    final postDto = PostDTO.fromDomain(
      post,
      id: id,
      authorId: authorId,
    );
    
    // Send to server
    final result = await _apiService.updatePost(id, postDto);
    
    if (result.isSuccess && result.data != null) {
      final updatedPost = result.data!.toDomain();
      // Update local cache
      final index = _localPosts.indexWhere((p) => p.title == post.title);
      if (index >= 0) {
        _localPosts[index] = updatedPost;
      }
      return updatedPost;
    } else {
      // For demo/offline mode, update local cache
      final index = _localPosts.indexWhere((p) => p.title == post.title);
      if (index >= 0) {
        _localPosts[index] = post;
      }
      return post;
    }
  }
  
  @override
  Future<void> deletePost(String id) async {
    // Send to server
    final result = await _apiService.deletePost(id);
    
    // Regardless of result, remove from local cache
    _localPosts.removeWhere((post) => post.title == id);
  }
  
  @override
  Future<void> toggleLikePost(String id) async {
    // Try server operation
    final result = await _apiService.toggleLikePost(id);
    
    // If offline, update local cache
    if (result.isError) {
      final index = _localPosts.indexWhere((p) => p.title == id);
      if (index >= 0) {
        final post = _localPosts[index];
        final updatedPost = NeighborhoodPost(
          category: post.category,
          title: post.title,
          content: post.content,
          authorName: post.authorName,
          location: post.location,
          likes: post.likes + 1, // Increment like count
          comments: post.comments,
          postDate: post.postDate,
          images: post.images,
        );
        _localPosts[index] = updatedPost;
      }
    }
  }
  
  @override
  Future<List<Comment>> getCommentsForPost(NeighborhoodPost post) async {
    // Try to get comments from server
    final result = await _apiService.getComments(post.title); // Using title as ID for demo
    
    if (result.isSuccess && result.data != null) {
      final comments = result.data!.map((dto) => dto.toDomain()).toList();
      // Update local cache
      _localComments[post.title] = comments;
      return comments;
    } else {
      // Return cached comments if available
      if (_localComments.containsKey(post.title)) {
        return _localComments[post.title]!;
      }
      
      // Otherwise, return mock data
      return _loadSampleComments(post);
    }
  }
  
  @override
  Future<Comment> addComment(String postId, Comment comment) async {
    // Get user information
    final authorId = await _getCurrentUserId();
    final authorName = await _getCurrentUserName();
    
    // Create DTO
    final commentDto = CommentDTO.fromDomain(
      comment,
      id: _uuid.v4(),
      postId: postId,
      authorId: authorId,
    );
    
    // Send to server
    final result = await _apiService.addComment(postId, commentDto);
    
    if (result.isSuccess && result.data != null) {
      return result.data!.toDomain();
    } else {
      // For demo/offline mode, add to local cache
      final newComment = Comment(
        authorName: authorName,
        content: comment.content,
        postDate: DateTime.now(),
        likes: 0,
      );
      
      if (!_localComments.containsKey(postId)) {
        _localComments[postId] = [];
      }
      
      _localComments[postId]!.add(newComment);
      return newComment;
    }
  }
  
  @override
  Future<void> toggleLikeComment(String postId, String commentId) async {
    // Try server operation
    final result = await _apiService.toggleLikeComment(postId, commentId);
    
    // If offline, update local cache (simplified)
    if (result.isError && _localComments.containsKey(postId)) {
      // This is simplified; real implementation would need to identify comments by ID
      // Here we just increment likes for the first comment
      if (_localComments[postId]!.isNotEmpty) {
        final comment = _localComments[postId]!.first;
        final updatedComment = Comment(
          authorName: comment.authorName,
          content: comment.content,
          postDate: comment.postDate,
          likes: comment.likes + 1,
        );
        
        _localComments[postId]![0] = updatedComment;
      }
    }
  }
  
  // Sample data for offline/demo mode
  void _loadSamplePosts() {
    if (_localPosts.isNotEmpty) return;
    
    final now = DateTime.now();
    
    _localPosts.addAll([
      NeighborhoodPost(
        category: '동네질문',
        title: '역삼동 맛집 추천 부탁드려요',
        content: '이번 주말에 친구들과 모임이 있는데, 역삼동에 회식하기 좋은 맛집 추천해주세요! 10명 정도 수용 가능한 곳이면 좋을 것 같아요.',
        authorName: '당근주민',
        location: '역삼동',
        likes: 5,
        comments: 8,
        postDate: now.subtract(Duration(hours: 2)),
      ),
      NeighborhoodPost(
        category: '동네소식',
        title: '역삼역 2번 출구 공사 언제 끝나나요?',
        content: '출퇴근길에 항상 지나가는데 공사가 너무 오래 지속되는 것 같아요. 혹시 아시는 분 계신가요?',
        authorName: '역삼지기',
        location: '역삼동',
        likes: 21,
        comments: 13,
        postDate: now.subtract(Duration(hours: 5)),
      ),
      NeighborhoodPost(
        category: '같이해요',
        title: '주말 아침 러닝 크루 모집합니다',
        content: '매주 토요일 아침 7시에 역삼역에서 만나서 함께 달리실 분 구합니다. 페이스는 6분 ~ 7분 정도로 생각하고 있어요. 관심 있으신 분들은 댓글 남겨주세요!',
        authorName: '러닝맨',
        location: '역삼동',
        likes: 8,
        comments: 3,
        postDate: now.subtract(Duration(days: 1)),
      ),
    ]);
  }
  
  List<Comment> _loadSampleComments(NeighborhoodPost post) {
    final now = DateTime.now();
    
    final comments = [
      Comment(
        authorName: '이웃주민',
        content: '정말 좋은 정보 감사합니다!',
        postDate: now.subtract(Duration(hours: 1)),
        likes: 3,
      ),
      Comment(
        authorName: '동네친구',
        content: '저도 같은 경험이 있어요. 정말 공감됩니다.',
        postDate: now.subtract(Duration(hours: 3)),
        likes: 5,
      ),
      Comment(
        authorName: '역삼지기',
        content: '앞으로도 좋은 정보 부탁드려요~',
        postDate: now.subtract(Duration(hours: 5)),
        likes: 2,
      ),
    ];
    
    _localComments[post.title] = comments;
    return comments;
  }
} 