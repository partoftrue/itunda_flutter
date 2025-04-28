import 'package:finance_app/features/neighborhood/data/api/spring_neighborhood_api_client.dart';
import 'package:finance_app/features/neighborhood/domain/models/post.dart';
import 'package:finance_app/features/neighborhood/domain/models/comment.dart';
import 'package:finance_app/features/neighborhood/domain/models/category.dart';
import 'package:finance_app/features/neighborhood/domain/repositories/neighborhood_repository.dart';

class SpringNeighborhoodRepository implements NeighborhoodRepository {
  final SpringNeighborhoodApiClient _apiClient;

  SpringNeighborhoodRepository({required SpringNeighborhoodApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<Post>> getPosts({
    required String location,
    String category = '전체',
    int page = 0,
    int size = 10,
  }) async {
    return _apiClient.getPosts(
      location: location,
      category: category,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<Post>> getPopularPosts({required String location}) async {
    return _apiClient.getPopularPosts(location: location);
  }

  @override
  Future<Post> getPostById(String postId, String location) async {
    return _apiClient.getPostById(postId, location);
  }

  @override
  Future<Post> createPost(Post post) async {
    return _apiClient.createPost(post);
  }

  @override
  Future<Post> updatePost(String postId, Post post) async {
    return _apiClient.updatePost(postId, post);
  }

  @override
  Future<void> deletePost(String postId) async {
    return _apiClient.deletePost(postId);
  }

  @override
  Future<Post> likePost(String postId) async {
    return _apiClient.likePost(postId);
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    return _apiClient.getCommentsByPostId(postId);
  }

  @override
  Future<Comment> addComment(Comment comment) async {
    return _apiClient.createComment(comment);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    return _apiClient.deleteComment(commentId);
  }

  @override
  Future<Comment> likeComment(String commentId) async {
    return _apiClient.likeComment(commentId);
  }

  @override
  Future<List<Category>> getCategories() async {
    return _apiClient.getCategories();
  }
} 