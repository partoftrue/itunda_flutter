import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:finance_app/core/error/failures.dart';
import 'package:finance_app/features/neighborhood/data/models/post_dto.dart';
import 'package:finance_app/features/neighborhood/data/models/comment_dto.dart';
import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_post.dart';
import 'package:finance_app/features/neighborhood/domain/entities/neighborhood_comment.dart';
import 'package:finance_app/features/neighborhood/domain/repositories/neighborhood_repository.dart';
import 'package:finance_app/core/network/api_client.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: NeighborhoodRepository)
class NeighborhoodRepositoryImpl implements NeighborhoodRepository {
  final ApiClient _apiClient;

  NeighborhoodRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<NeighborhoodPost>>> getPosts() async {
    try {
      final response = await _apiClient.get('/api/neighborhood/posts');
      final List<dynamic> postsJson = response.data as List<dynamic>;
      final posts = postsJson.map((json) => PostDTO.fromJson(json).toDomain()).toList();
      return Right(posts);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to load posts'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NeighborhoodPost>> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/api/neighborhood/posts/$postId');
      final post = PostDTO.fromJson(response.data).toDomain();
      return Right(post);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to load post'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NeighborhoodPost>> createPost(NeighborhoodPost post, String userId) async {
    try {
      final postDto = PostDTO.fromDomain(post, userId);
      final response = await _apiClient.post(
        '/api/neighborhood/posts',
        data: postDto.toJson(),
      );
      final createdPost = PostDTO.fromJson(response.data).toDomain();
      return Right(createdPost);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to create post'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) async {
    try {
      await _apiClient.delete('/api/neighborhood/posts/$postId');
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to delete post'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NeighborhoodComment>>> getComments(String postId) async {
    try {
      final response = await _apiClient.get('/api/neighborhood/posts/$postId/comments');
      final List<dynamic> commentsJson = response.data as List<dynamic>;
      final comments = commentsJson
          .map((json) => CommentDTO.fromJson(json).toDomain())
          .toList();
      return Right(comments);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to load comments'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NeighborhoodComment>> addComment(String postId, NeighborhoodComment comment, String userId) async {
    try {
      final commentDto = CommentDTO.fromDomain(comment, postId, userId);
      final response = await _apiClient.post(
        '/api/neighborhood/posts/$postId/comments',
        data: commentDto.toJson(),
      );
      final createdComment = CommentDTO.fromJson(response.data).toDomain();
      return Right(createdComment);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to add comment'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLikePost(String postId) async {
    try {
      final response = await _apiClient.post('/api/neighborhood/posts/$postId/like');
      final bool isLiked = response.data['isLiked'] as bool;
      return Right(isLiked);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to like post'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLikeComment(String commentId) async {
    try {
      final response = await _apiClient.post('/api/neighborhood/comments/$commentId/like');
      final bool isLiked = response.data['isLiked'] as bool;
      return Right(isLiked);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to like comment'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 