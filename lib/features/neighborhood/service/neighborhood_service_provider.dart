import 'package:finance_app/features/neighborhood/data/models/comment_model.dart';
import 'package:finance_app/features/neighborhood/data/models/post_model.dart';
import 'package:finance_app/features/neighborhood/data/neighborhood_repository_impl_rest.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository provider
final neighborhoodRepositoryProvider = Provider<NeighborhoodRepositoryRest>((ref) {
  final repository = NeighborhoodRepositoryRest();
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});

// Posts providers
final postsProvider = FutureProvider.family<List<PostModel>, String?>((ref, category) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return repository.getPosts(category: category);
});

final postProvider = FutureProvider.family<PostModel?, String>((ref, postId) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return repository.getPostById(postId);
});

final popularPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return repository.getPopularPosts();
});

// Comments providers
final commentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, postId) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return repository.getComments(postId);
});

// Actions providers
final createPostProvider = Provider<Future<String> Function(PostModel)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (post) => repository.createPost(post);
});

final updatePostProvider = Provider<Future<void> Function(PostModel)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (post) => repository.updatePost(post);
});

final deletePostProvider = Provider<Future<void> Function(String)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (postId) => repository.deletePost(postId);
});

final toggleLikeProvider = Provider<Future<void> Function(String, bool)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (postId, isLiked) => repository.toggleLike(postId, isLiked);
});

final addCommentProvider = Provider<Future<String> Function(CommentModel)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (comment) => repository.addComment(comment);
});

final deleteCommentProvider = Provider<Future<void> Function(String, String)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (postId, commentId) => repository.deleteComment(postId, commentId);
});

final toggleCommentLikeProvider = Provider<Future<void> Function(String, String, bool)>((ref) {
  final repository = ref.watch(neighborhoodRepositoryProvider);
  return (postId, commentId, isLiked) => repository.toggleCommentLike(postId, commentId, isLiked);
}); 