import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'domain/models/post.dart';
import 'domain/models/comment.dart';
import 'presentation/providers/neighborhood_provider.dart';
import 'widgets/skeleton_loading.dart';
import 'widgets/post_card.dart';
import 'widgets/badge_label.dart';
import 'widgets/comment_item.dart';
import 'widgets/error_retry_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  
  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isComposing = false;
  bool _isCommentButtonVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Get data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
      provider.fetchPostById(widget.postId);
      provider.fetchComments(widget.postId);
      _animationController.forward();
    });
    
    // Monitor text input for send button visibility
    _commentController.addListener(() {
      final text = _commentController.text.trim();
      if (text.isNotEmpty != _isCommentButtonVisible) {
        setState(() {
          _isCommentButtonVisible = text.isNotEmpty;
        });
      }
    });
    
    // Monitor focus for keyboard visibility
    _commentFocusNode.addListener(() {
      setState(() {
        _isComposing = _commentFocusNode.hasFocus;
      });
    });
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: theme.colorScheme.onBackground,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
            Provider.of<NeighborhoodProvider>(context, listen: false).clearSelectedPost();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<NeighborhoodProvider>(
        builder: (context, provider, child) {
          if (provider.status == NeighborhoodStatus.loading || provider.selectedPost == null) {
            return const PostDetailSkeleton();
          }
          
          if (provider.status == NeighborhoodStatus.error) {
            return _buildErrorMessage(context);
          }
          
          final post = provider.selectedPost!;
          
          return Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchPostById(widget.postId);
                      await provider.fetchComments(widget.postId);
                    },
                    color: theme.colorScheme.primary,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPostHeader(post, theme),
                          _buildPostContent(post, theme),
                          _buildInteractionBar(post, provider, theme),
                          Divider(height: 32, thickness: 8, color: theme.dividerColor.withOpacity(0.05)),
                          _buildCommentsSection(provider, theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildCommentInputBar(provider, post, theme, mediaQuery),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPostHeader(Post post, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'avatar-${post.id}',
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                post.authorName.substring(0, 1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'author-${post.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          post.authorName,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Hero(
                      tag: 'category-${post.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: BadgeLabel(
                          text: post.category,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      post.location,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostContent(Post post, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Hero(
            tag: 'content-${post.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (post.images != null && post.images!.isNotEmpty) ...[
          SizedBox(
            height: 240,
            child: CachedNetworkImage(
              imageUrl: post.images!.first,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
  
  Widget _buildInteractionBar(Post post, NeighborhoodProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => provider.likePost(post.id),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: post.isLiked ? Colors.red : theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '좋아요 ${post.likesCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: post.isLiked ? Colors.red.withOpacity(0.8) : theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              // Focus the comment input
              _commentFocusNode.requestFocus();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '댓글 ${post.commentsCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.bookmark_border_rounded,
              size: 20,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsSection(NeighborhoodProvider provider, ThemeData theme) {
    final comments = provider.comments;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '댓글 ${comments.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const Spacer(),
              if (comments.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('인기순'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: comments.isEmpty
                ? _buildEmptyCommentsState(theme)
                : ListView.builder(
                    key: ValueKey('comments-${comments.length}'),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            (0.5 + (index / 20)).clamp(0.0, 1.0),
                            (0.5 + ((index + 1) / 20)).clamp(0.0, 1.0),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      );
                      
                      return FadeTransition(
                        opacity: animation,
                        child: CommentItem(
                          comment: comment,
                          onReply: () {
                            // Reply to comment functionality
                            _commentFocusNode.requestFocus();
                            _commentController.text = '@${comment.authorName} ';
                            _commentController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _commentController.text.length),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyCommentsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.onBackground.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 댓글이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 댓글을 남겨보세요!',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _commentFocusNode.requestFocus(),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('댓글 작성하기'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentInputBar(NeighborhoodProvider provider, Post post, ThemeData theme, MediaQueryData mediaQuery) {
    final bottomInset = mediaQuery.viewInsets.bottom;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(16, 8, 16, _isComposing ? 8 : bottomInset > 0 ? 8 : 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Comment input field
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onBackground,
              ),
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                  fontSize: 15,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: !_isComposing ? null : IconButton(
                  icon: const Icon(Icons.insert_photo_outlined),
                  onPressed: () {
                    // Add image to comment
                  },
                  color: theme.colorScheme.primary,
                  tooltip: '이미지 첨부',
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: _isCommentButtonVisible
                ? IconButton(
                    key: const ValueKey('send-button'),
                    onPressed: () {
                      final text = _commentController.text.trim();
                      if (text.isNotEmpty) {
                        final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
                        
                        // Use the new addComment method that takes postId and content
                        provider.addComment(widget.postId, _commentController.text.trim());
                        _commentController.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : IconButton(
                    key: const ValueKey('emoji-button'),
                    onPressed: () {
                      // Open emoji picker
                    },
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Widget _buildErrorMessage(BuildContext context) {
    return ErrorRetryWidget(
      message: '게시물을 불러오는데 실패했습니다.\n${Provider.of<NeighborhoodProvider>(context).errorMessage ?? ''}',
      onRetry: () {
        Provider.of<NeighborhoodProvider>(context, listen: false).fetchPostById(widget.postId);
      },
    );
  }
}

// Add the missing PostDetailSkeleton class if it's not defined elsewhere
class PostDetailSkeleton extends StatelessWidget {
  const PostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row skeleton
          Row(
            children: [
              SkeletonLoading(
                width: 32,
                height: 32,
                borderRadius: 16,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading(
                    width: 120,
                    height: 16,
                    borderRadius: 8,
                  ),
                  SizedBox(height: 4),
                  SkeletonLoading(
                    width: 80,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Content skeleton
          SkeletonLoading(
            width: double.infinity,
            height: 16,
            borderRadius: 8,
          ),
          SizedBox(height: 8),
          SkeletonLoading(
            width: double.infinity,
            height: 16,
            borderRadius: 8,
          ),
          SizedBox(height: 8),
          SkeletonLoading(
            width: 200,
            height: 16,
            borderRadius: 8,
          ),
          SizedBox(height: 20),
          
          // Image skeleton
          SkeletonLoading(
            width: double.infinity,
            height: 200,
            borderRadius: 8,
          ),
          SizedBox(height: 20),
          
          // Actions row skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoading(
                width: 80,
                height: 24,
                borderRadius: 12,
              ),
              SkeletonLoading(
                width: 80,
                height: 24,
                borderRadius: 12,
              ),
              SkeletonLoading(
                width: 24,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Comments header skeleton
          SkeletonLoading(
            width: 120,
            height: 20,
            borderRadius: 10,
          ),
          SizedBox(height: 20),
          
          // Comments list skeletons
          SkeletonCommentItem(),
          SizedBox(height: 16),
          SkeletonCommentItem(),
          SizedBox(height: 16),
          SkeletonCommentItem(),
        ],
      ),
    );
  }
}

class SkeletonCommentItem extends StatelessWidget {
  const SkeletonCommentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoading(
          width: 32,
          height: 32,
          borderRadius: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoading(
                    width: 80,
                    height: 14,
                    borderRadius: 7,
                  ),
                  const SkeletonLoading(
                    width: 40,
                    height: 12,
                    borderRadius: 6,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const SkeletonLoading(
                width: double.infinity,
                height: 14,
                borderRadius: 7,
              ),
              const SizedBox(height: 4),
              SkeletonLoading(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                borderRadius: 7,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const SkeletonLoading(
                    width: 60,
                    height: 20,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 16),
                  const SkeletonLoading(
                    width: 60,
                    height: 20,
                    borderRadius: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 