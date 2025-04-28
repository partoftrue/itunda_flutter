import 'dart:io';
import 'package:http/http.dart';
import '../models/post_dto.dart';
import '../models/comment_dto.dart';
import 'neighborhood_api_client.dart';

/// Result class to handle API responses or errors
class ApiResult<T> {
  final T? data;
  final String? error;

  ApiResult.success(this.data) : error = null;
  ApiResult.error(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isError => error != null;
}

/// Service layer to handle API requests and responses
class NeighborhoodApiService {
  final NeighborhoodApiClient _apiClient;

  NeighborhoodApiService(this._apiClient);

  /// Get all posts with error handling
  Future<ApiResult<List<PostDTO>>> getPosts() async {
    try {
      final posts = await _apiClient.getPosts();
      return ApiResult.success(posts);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('게시글을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Get posts by category with error handling
  Future<ApiResult<List<PostDTO>>> getPostsByCategory(String category) async {
    try {
      final posts = await _apiClient.getPostsByCategory(category);
      return ApiResult.success(posts);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('카테고리별 게시글을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Get a post by ID with error handling
  Future<ApiResult<PostDTO>> getPostById(String id) async {
    try {
      final post = await _apiClient.getPostById(id);
      return ApiResult.success(post);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('게시글을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Create a post with error handling
  Future<ApiResult<PostDTO>> createPost(PostDTO post) async {
    try {
      final createdPost = await _apiClient.createPost(post);
      return ApiResult.success(createdPost);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('게시글을 작성하는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Update a post with error handling
  Future<ApiResult<PostDTO>> updatePost(String id, PostDTO post) async {
    try {
      final updatedPost = await _apiClient.updatePost(id, post);
      return ApiResult.success(updatedPost);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('게시글을 수정하는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Delete a post with error handling
  Future<ApiResult<void>> deletePost(String id) async {
    try {
      await _apiClient.deletePost(id);
      return ApiResult.success(null);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('게시글을 삭제하는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Toggle like a post with error handling
  Future<ApiResult<void>> toggleLikePost(String id) async {
    try {
      await _apiClient.toggleLikePost(id);
      return ApiResult.success(null);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('좋아요 표시에 실패했습니다: ${e.toString()}');
    }
  }

  /// Get comments for a post with error handling
  Future<ApiResult<List<CommentDTO>>> getComments(String postId) async {
    try {
      final comments = await _apiClient.getComments(postId);
      return ApiResult.success(comments);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('댓글을 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Add a comment with error handling
  Future<ApiResult<CommentDTO>> addComment(String postId, CommentDTO comment) async {
    try {
      final createdComment = await _apiClient.addComment(postId, comment);
      return ApiResult.success(createdComment);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('댓글을 작성하는데 실패했습니다: ${e.toString()}');
    }
  }

  /// Toggle like a comment with error handling
  Future<ApiResult<void>> toggleLikeComment(String postId, String commentId) async {
    try {
      await _apiClient.toggleLikeComment(postId, commentId);
      return ApiResult.success(null);
    } on SocketException {
      return ApiResult.error('네트워크 연결 실패. 인터넷 연결을 확인해주세요.');
    } on ClientException {
      return ApiResult.error('서버 연결 실패. 다시 시도해주세요.');
    } on Exception catch (e) {
      return ApiResult.error('댓글 좋아요 표시에 실패했습니다: ${e.toString()}');
    }
  }
} 