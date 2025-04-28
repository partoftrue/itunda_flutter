import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_app/features/neighborhood/domain/comment.dart';
import 'package:finance_app/features/neighborhood/domain/neighborhood_post.dart';

class NeighborhoodRepository {
  final FirebaseFirestore _firestore;
  
  NeighborhoodRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _postsCollection => 
      _firestore.collection('neighborhood_posts');
  
  CollectionReference _commentsCollection(String postId) => 
      _postsCollection.doc(postId).collection('comments');

  // POSTS CRUD OPERATIONS
  
  // Get all posts
  Stream<List<NeighborhoodPost>> getPosts({String? category}) {
    var query = _postsCollection.orderBy('timestamp', descending: true);
    
    if (category != null && category != '전체') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NeighborhoodPost.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }
  
  // Get a single post by ID
  Future<NeighborhoodPost?> getPostById(String postId) async {
    final docSnapshot = await _postsCollection.doc(postId).get();
    if (!docSnapshot.exists) {
      return null;
    }
    
    final data = docSnapshot.data() as Map<String, dynamic>;
    return NeighborhoodPost.fromJson({...data, 'id': docSnapshot.id});
  }
  
  // Create a new post
  Future<String> createPost(NeighborhoodPost post) async {
    final docRef = await _postsCollection.add(post.toJson()..remove('id'));
    return docRef.id;
  }
  
  // Update an existing post
  Future<void> updatePost(NeighborhoodPost post) async {
    await _postsCollection.doc(post.id).update(post.toJson()..remove('id'));
  }
  
  // Delete a post
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }
  
  // Toggle like status for a post
  Future<void> toggleLike(String postId, bool isLiked) async {
    await _postsCollection.doc(postId).update({
      'likeCount': FieldValue.increment(isLiked ? 1 : -1),
      'isLiked': isLiked,
    });
  }
  
  // COMMENTS CRUD OPERATIONS
  
  // Get all comments for a post
  Stream<List<Comment>> getComments(String postId) {
    return _commentsCollection(postId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Comment.fromJson({...data, 'id': doc.id, 'postId': postId});
      }).toList();
    });
  }
  
  // Add a comment to a post
  Future<String> addComment(Comment comment) async {
    final postRef = _postsCollection.doc(comment.postId);
    
    // Start a transaction to update both the comment and the post's comment count
    return _firestore.runTransaction<String>((_) async {
      final commentRef = await _commentsCollection(comment.postId)
          .add(comment.toJson()..remove('id')..remove('postId'));
      
      // Update comment count on the post
      await postRef.update({'commentCount': FieldValue.increment(1)});
      
      return commentRef.id;
    });
  }
  
  // Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    final postRef = _postsCollection.doc(postId);
    
    return _firestore.runTransaction((_) async {
      await _commentsCollection(postId).doc(commentId).delete();
      await postRef.update({'commentCount': FieldValue.increment(-1)});
    });
  }
  
  // Toggle like for a comment
  Future<void> toggleCommentLike(
      String postId, String commentId, bool isLiked) async {
    await _commentsCollection(postId).doc(commentId).update({
      'likeCount': FieldValue.increment(isLiked ? 1 : -1),
      'isLiked': isLiked,
    });
  }
} 