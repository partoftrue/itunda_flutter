import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:itunda/core/constants/api_constants.dart';
import 'package:itunda/features/neighborhood/domain/models/post.dart';
import 'package:itunda/features/neighborhood/domain/models/comment.dart';
import 'package:itunda/features/neighborhood/domain/models/category.dart' as neighborhood_models;
import 'package:itunda/core/network/api_exception.dart';

/// Mock API client for neighborhood requests during development
class MockNeighborhoodApiClient {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();
  
  // Sample categories
  final List<neighborhood_models.Category> _categories = [
    neighborhood_models.Category(id: '1', name: '전체', order: 0),
    neighborhood_models.Category(id: '2', name: '동네질문', icon: '🤔', order: 1),
    neighborhood_models.Category(id: '3', name: '동네소식', icon: '📢', order: 2),
    neighborhood_models.Category(id: '4', name: '동네맛집', icon: '🍽️', order: 3),
    neighborhood_models.Category(id: '5', name: '동네생활', icon: '🏠', order: 4),
    neighborhood_models.Category(id: '6', name: '취미생활', icon: '🎨', order: 5),
    neighborhood_models.Category(id: '7', name: '같이해요', icon: '👫', order: 6),
    neighborhood_models.Category(id: '8', name: '해주세요', icon: '🙏', order: 7),
  ];
  
  // Sample posts
  final List<Post> _posts = [];
  
  // Sample comments
  final Map<String, List<Comment>> _comments = {};
  
  final List<String> _userNames = [
    '당근주민', '역삼지기', '러닝맨', '동네고양이', '맛집탐험가', 
    '헬스마니아', '독서모임장', '직장인A', '대학생B', '동네엄마'
  ];

  // Network condition simulation
  final bool _simulateNetworkErrors;
  final double _errorProbability;
  final double _networkLatencyVariation;

  // Request cancellation
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  
  MockNeighborhoodApiClient({
    bool simulateNetworkErrors = true,
    double errorProbability = 0.05, // 5% chance of error
    double networkLatencyVariation = 0.5, // 50% variation in latency
  }) : 
    _simulateNetworkErrors = simulateNetworkErrors,
    _errorProbability = errorProbability,
    _networkLatencyVariation = networkLatencyVariation {
    _generateSamplePosts();
    _generateSampleComments();
  }
  
  void _generateSamplePosts() {
    final now = DateTime.now();
    
    for (int i = 0; i < 50; i++) {
      final category = _categories[_random.nextInt(_categories.length - 1) + 1]; // Skip "전체"
      final timeDifference = Duration(hours: _random.nextInt(240)); // Up to 10 days in the past
      final postDate = now.subtract(timeDifference);
      final id = _uuid.v4();
      final authorId = _uuid.v4(); // Generate a unique authorId
      
      _posts.add(
        Post(
          id: id,
          title: _generateRandomTitle(category.name),
          content: _generateRandomContent(category.name),
          authorId: authorId, // Add the authorId
          authorName: _userNames[_random.nextInt(_userNames.length)],
          authorAvatar: "https://i.pravatar.cc/150?u=${authorId}", // Add avatar URL
          location: '서울시 강남구',
          category: category.name,
          createdAt: postDate,
          updatedAt: postDate,
          likesCount: _random.nextInt(100),
          commentsCount: _random.nextInt(30),
          isLiked: _random.nextBool(),
          images: _random.nextInt(10) > 7 ? _generateRandomImages() : [],
        ),
      );
    }
    
    // Sort posts by creation date (newest first)
    _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  void _generateSampleComments() {
    for (final post in _posts) {
      final commentCount = post.commentsCount;
      final comments = <Comment>[];
      
      for (int i = 0; i < commentCount; i++) {
        final timeDifference = Duration(minutes: _random.nextInt(60 * 24 * 5)); // Up to 5 days
        final commentDate = post.createdAt.add(timeDifference);
        final authorId = _uuid.v4(); // Generate a unique authorId
        
        comments.add(
          Comment(
            id: _uuid.v4(),
            postId: post.id,
            authorId: authorId, // Add the authorId
            content: _generateRandomCommentContent(),
            authorName: _userNames[_random.nextInt(_userNames.length)],
            createdAt: commentDate,
            updatedAt: commentDate,
            likesCount: _random.nextInt(15),
            isLiked: _random.nextBool(),
          ),
        );
      }
      
      // Sort comments by creation date (oldest first)
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _comments[post.id] = comments;
    }
  }
  
  String _generateRandomTitle(String category) {
    final titles = {
      '동네질문': [
        '이 동네 OO한 곳 어디인가요?',
        '근처에 좋은 병원 추천해주세요',
        '여기 자전거 도로 언제 공사 끝나나요?',
        '아파트 관리비가 너무 올랐어요',
        '밤에 소음이 너무 심한데 어떻게 해결하면 좋을까요?'
      ],
      '동네소식': [
        '신규 상점 오픈 소식입니다',
        '다음 주 도로 공사 안내',
        '동네 축제 일정 공유합니다',
        '새로운 버스 노선이 생겼어요',
        '학교 앞 횡단보도에 신호등 설치됩니다'
      ],
      '동네맛집': [
        '여기 돈까스 맛집 추천합니다',
        '숨은 맛집을 찾았어요',
        '신규 오픈한 카페 후기',
        '가성비 좋은 점심 메뉴',
        '가족 모임하기 좋은 식당 추천'
      ],
      '동네생활': [
        '분리수거 요일 변경 안내',
        '근처 좋은 세탁소 추천해주세요',
        '이사 와서 인사드립니다',
        '단수 공지 보셨나요?',
        '동네 고양이에게 먹이를 주면 안 되는 이유'
      ],
      '취미생활': [
        '테니스 치실 분 구합니다',
        '독서모임 새 멤버 모집',
        '그림 동호회 함께해요',
        '등산 모임 일정 공유',
        '보드게임 모임 오세요'
      ],
      '같이해요': [
        '아침 러닝 메이트 구합니다',
        '함께 공부할 스터디원 모집',
        '주말 자전거 라이딩 하실 분',
        '배달비 나눠요',
        '같이 영화 보실 분 계신가요?'
      ],
      '해주세요': [
        '강아지 산책 도와주실 분',
        '짐 옮기는데 도움이 필요해요',
        '컴퓨터 고치는데 조언 부탁드립니다',
        '집 봐주실 분 구합니다',
        '과외 선생님 추천해주세요'
      ],
    };
    
    final defaultTitles = [
      '질문있습니다',
      '도움이 필요해요',
      '추천해주세요',
      '정보 공유합니다',
      '같이 하실 분 계신가요?'
    ];
    
    final categoryTitles = titles[category] ?? defaultTitles;
    return categoryTitles[_random.nextInt(categoryTitles.length)];
  }
  
  String _generateRandomContent(String category) {
    final contents = [
      '안녕하세요, 동네 주민분들. 최근에 이사왔는데 이 지역에 대해 더 알고 싶어요. 좋은 정보 부탁드립니다.',
      '오늘 동네를 돌아다니다가 발견한 정보입니다. 다른 분들께도 도움이 되길 바랍니다.',
      '질문이 있어서 글을 올립니다. 경험이 있으신 분들의 조언이 필요합니다.',
      '저는 이 문제에 대해 이렇게 생각하는데, 여러분의 의견은 어떠신가요?',
      '함께 할 수 있는 활동을 찾고 있습니다. 관심 있으신 분들은 댓글 남겨주세요.',
      '이번 주말에 시간이 되시는 분들, 같이 이 활동을 해봐요. 재미있을 것 같아요.',
      '동네에서 이런 서비스를 찾고 있는데 추천해주실 만한 곳이 있을까요?',
      '최근에 경험한 일인데, 공유하고 싶어서 글을 씁니다. 여러분의 생각도 궁금합니다.',
      '이런 상황에서 어떻게 대처하는 것이 좋을까요? 비슷한 경험이 있으신 분들의 조언을 구합니다.',
      '동네 정보를 나누고 싶어요. 제가 알게 된 정보가 다른 분들께도 유용했으면 좋겠습니다.'
    ];
    
    return contents[_random.nextInt(contents.length)];
  }
  
  String _generateRandomCommentContent() {
    final comments = [
      '정말 좋은 정보 감사합니다.',
      '저도 비슷한 경험이 있어요.',
      '한번 시도해볼게요, 감사합니다!',
      '정보 공유 감사합니다.',
      '도움이 많이 되네요.',
      '같은 생각이었어요.',
      '잘 보고 갑니다.',
      '오 정말요? 몰랐네요.',
      '좋은 의견 감사합니다.',
      '동의합니다!',
      '이야기 나눠주셔서 감사해요.',
      '저는 조금 다르게 생각했었는데, 새로운 시각을 배웠네요.',
      '한번 방문해봐야겠어요.',
      '연락드렸습니다!',
      '좋은 제안이네요.'
    ];
    
    return comments[_random.nextInt(comments.length)];
  }
  
  List<String> _generateRandomImages() {
    final imageCounts = _random.nextInt(3) + 1; // 1 to 3 images
    final result = <String>[];
    
    for (int i = 0; i < imageCounts; i++) {
      final imageNumber = _random.nextInt(10) + 1; // 1 to 10
      result.add('https://picsum.photos/id/${200 + imageNumber}/500/300');
    }
    
    return result;
  }

  /// Simulate network delay and potential errors
  Future<T> _simulateNetwork<T>({
    required String requestId,
    required Future<T> Function() responseGenerator,
    int baseDelayMs = 500,
  }) async {
    // Create a completer that can be cancelled
    final completer = Completer<T>();
    _pendingRequests[requestId] = completer;

    try {
      // Calculate a realistic network delay with jitter
      int delayVariation = (baseDelayMs * _networkLatencyVariation * _random.nextDouble()).round();
      int totalDelay = baseDelayMs + _random.nextInt(delayVariation);
      
      // Simulate network latency
      await Future.delayed(Duration(milliseconds: totalDelay));
      
      // Sometimes simulate network errors
      if (_simulateNetworkErrors && _random.nextDouble() < _errorProbability) {
        final errorTypes = ['timeout', 'connection', 'server'];
        final errorType = errorTypes[_random.nextInt(errorTypes.length)];
        
        switch (errorType) {
          case 'timeout':
            throw ApiException(
              message: '요청 시간이 초과되었습니다.',
              statusCode: 408,
            );
          case 'connection':
            throw ApiException(
              message: '네트워크 연결에 문제가 있습니다.',
              statusCode: 0,
            );
          case 'server':
            throw ApiException(
              message: '서버 오류가 발생했습니다.',
              statusCode: 500,
            );
        }
      }
      
      // Generate the actual response
      final result = await responseGenerator();
      
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      
      return result;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    } finally {
      _pendingRequests.remove(requestId);
    }
  }

  /// Get all posts with pagination
  Future<List<Post>> getPosts({
    required String location,
    String category = '전체',
    int page = 0,
    int size = 10,
  }) async {
    final requestId = 'getPosts-$location-$category-$page-$size';
    
    return _simulateNetwork<List<Post>>(
      requestId: requestId,
      baseDelayMs: 600,
      responseGenerator: () async {
        // Filter posts by category if needed
        final filteredPosts = category == '전체'
            ? _posts
            : _posts.where((post) => post.category == category).toList();
        
        // Apply pagination
        final startIndex = page * size;
        final endIndex = min(startIndex + size, filteredPosts.length);
        
        if (startIndex >= filteredPosts.length) {
          return [];
        }
        
        return filteredPosts.sublist(startIndex, endIndex);
      },
    );
  }

  /// Get popular posts
  Future<List<Post>> getPopularPosts({
    required String location,
    int page = 0,
    int size = 10,
  }) async {
    final requestId = 'getPopularPosts-$location-$page-$size';
    
    return _simulateNetwork<List<Post>>(
      requestId: requestId,
      baseDelayMs: 700,
      responseGenerator: () async {
        // Sort by popularity (likes + comments)
        final popularPosts = List<Post>.from(_posts);
        popularPosts.sort((a, b) {
          final aPopularity = a.likesCount + a.commentsCount;
          final bPopularity = b.likesCount + b.commentsCount;
          return bPopularity.compareTo(aPopularity);
        });
        
        // Apply pagination
        final startIndex = page * size;
        final endIndex = min(startIndex + size, popularPosts.length);
        
        if (startIndex >= popularPosts.length) {
          return [];
        }
        
        return popularPosts.sublist(startIndex, endIndex);
      },
    );
  }

  /// Get a post by ID
  Future<Post> getPostById(String postId) async {
    final requestId = 'getPostById-$postId';
    
    return _simulateNetwork<Post>(
      requestId: requestId,
      baseDelayMs: 300,
      responseGenerator: () async {
        final post = _posts.firstWhere(
          (post) => post.id == postId,
          orElse: () => throw ApiException(
            message: '게시물을 찾을 수 없습니다.',
            statusCode: 404,
          ),
        );
        
        // Return a copy of the post with incremented view count
        // We don't actually store the view count in our model, so we can't update it
        return post;
      },
    );
  }

  /// Create a new post
  Future<Post> createPost(Post post) async {
    final requestId = 'createPost-${DateTime.now().millisecondsSinceEpoch}';
    
    return _simulateNetwork<Post>(
      requestId: requestId,
      baseDelayMs: 800,
      responseGenerator: () async {
        final now = DateTime.now();
        final newPost = post.copyWith(
          id: _uuid.v4(),
          createdAt: now,
          updatedAt: now,
          commentsCount: 0,
          likesCount: 0,
          isLiked: false,
        );
        
        // Add to the beginning of the list
        _posts.insert(0, newPost);
        
        // Initialize empty comments list
        _comments[newPost.id] = [];
        
        return newPost;
      },
    );
  }

  /// Update an existing post
  Future<Post> updatePost(String postId, Post post) async {
    final requestId = 'updatePost-$postId';
    
    return _simulateNetwork<Post>(
      requestId: requestId,
      baseDelayMs: 600,
      responseGenerator: () async {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index == -1) {
          throw ApiException(
            message: '게시물을 찾을 수 없습니다.',
            statusCode: 404,
          );
        }
        
        final existingPost = _posts[index];
        final updatedPost = existingPost.copyWith(
          title: post.title,
          content: post.content,
          category: post.category,
          images: post.images,
          updatedAt: DateTime.now(),
        );
        
        _posts[index] = updatedPost;
        
        return updatedPost;
      },
    );
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final requestId = 'deletePost-$postId';
    
    return _simulateNetwork<void>(
      requestId: requestId,
      baseDelayMs: 500,
      responseGenerator: () async {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index == -1) {
          throw ApiException(
            message: '게시물을 찾을 수 없습니다.',
            statusCode: 404,
          );
        }
        
        _posts.removeAt(index);
        _comments.remove(postId);
      },
    );
  }

  /// Like a post
  Future<Post> likePost(String postId) async {
    final requestId = 'likePost-$postId';
    
    return _simulateNetwork<Post>(
      requestId: requestId,
      baseDelayMs: 300,
      responseGenerator: () async {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index == -1) {
          throw ApiException(
            message: '게시물을 찾을 수 없습니다.',
            statusCode: 404,
          );
        }
        
        final post = _posts[index];
        final updatedPost = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        
        _posts[index] = updatedPost;
        
        return updatedPost;
      },
    );
  }

  /// Get comments for a post
  Future<List<Comment>> getCommentsByPostId(
    String postId, {
    int page = 0,
    int size = 20,
  }) async {
    final requestId = 'getCommentsByPostId-$postId-$page-$size';
    
    return _simulateNetwork<List<Comment>>(
      requestId: requestId,
      baseDelayMs: 400,
      responseGenerator: () async {
        final comments = _comments[postId] ?? [];
        
        // Apply pagination
        final startIndex = page * size;
        final endIndex = min(startIndex + size, comments.length);
        
        if (startIndex >= comments.length) {
          return [];
        }
        
        return comments.sublist(startIndex, endIndex);
      },
    );
  }

  /// Create a new comment
  Future<Comment> createComment(Comment comment) async {
    final requestId = 'createComment-${DateTime.now().millisecondsSinceEpoch}';
    
    return _simulateNetwork<Comment>(
      requestId: requestId,
      baseDelayMs: 500,
      responseGenerator: () async {
        final now = DateTime.now();
        final newComment = comment.copyWith(
          id: _uuid.v4(),
          createdAt: now,
          updatedAt: now,
          likesCount: 0,
          isLiked: false,
        );
        
        if (!_comments.containsKey(comment.postId)) {
          _comments[comment.postId] = [];
        }
        
        _comments[comment.postId]!.add(newComment);
        
        // Update post comment count
        final postIndex = _posts.indexWhere((p) => p.id == comment.postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          _posts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }
        
        return newComment;
      },
    );
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    final requestId = 'deleteComment-$commentId';
    
    return _simulateNetwork<void>(
      requestId: requestId,
      baseDelayMs: 400,
      responseGenerator: () async {
        String? postId;
        Comment? removedComment;
        
        // Find and remove the comment
        for (final entry in _comments.entries) {
          final index = entry.value.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            postId = entry.key;
            removedComment = entry.value[index];
            entry.value.removeAt(index);
            break;
          }
        }
        
        if (postId == null || removedComment == null) {
          throw ApiException(
            message: '댓글을 찾을 수 없습니다.',
            statusCode: 404,
          );
        }
        
        // Update post comment count
        final postIndex = _posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          _posts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount - 1,
          );
        }
      },
    );
  }

  /// Like a comment
  Future<Comment> likeComment(String commentId) async {
    final requestId = 'likeComment-$commentId';
    
    return _simulateNetwork<Comment>(
      requestId: requestId,
      baseDelayMs: 300,
      responseGenerator: () async {
        // Find the comment
        for (final comments in _comments.values) {
          final index = comments.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            final comment = comments[index];
            final updatedComment = comment.copyWith(
              isLiked: !comment.isLiked,
              likesCount: comment.isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
            );
            
            comments[index] = updatedComment;
            return updatedComment;
          }
        }
        
        throw ApiException(
          message: '댓글을 찾을 수 없습니다.',
          statusCode: 404,
        );
      },
    );
  }

  /// Get all categories
  Future<List<neighborhood_models.Category>> getCategories() async {
    final requestId = 'getCategories';
    
    return _simulateNetwork<List<neighborhood_models.Category>>(
      requestId: requestId,
      baseDelayMs: 200,
      responseGenerator: () async {
        return _categories;
      },
    );
  }

  /// Cancel all pending requests, useful for cleanup or when user navigates away
  void cancelAllRequests() {
    for (final request in _pendingRequests.entries) {
      if (!request.value.isCompleted) {
        request.value.completeError(
          ApiException(
            message: '요청이 취소되었습니다.',
            statusCode: 0,
          ),
        );
      }
    }
    
    _pendingRequests.clear();
  }
  
  /// Cancel a specific request by ID
  void cancelRequest(String requestId) {
    final completer = _pendingRequests[requestId];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        ApiException(
          message: '요청이 취소되었습니다.',
          statusCode: 0,
        ),
      );
      _pendingRequests.remove(requestId);
    }
  }

  void dispose() {
    cancelAllRequests();
  }
} 