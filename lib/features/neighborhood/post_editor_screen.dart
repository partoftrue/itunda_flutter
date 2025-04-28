import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'domain/models/post.dart';
import 'domain/models/category.dart' as neighborhood_models;
import 'presentation/providers/neighborhood_provider.dart';

class PostEditorScreen extends StatefulWidget {
  final Post? post; // If provided, we're editing an existing post
  
  const PostEditorScreen({
    super.key,
    this.post,
  });

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _selectedCategory = '동네소식';
  File? _imageFile;
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.post != null) {
      // Editing existing post
      _contentController.text = widget.post!.content;
      _selectedCategory = widget.post!.category;
      
      // Track changes
      _contentController.addListener(_checkChanges);
    }
  }
  
  void _checkChanges() {
    if (!mounted) return;
    
    final hasContentChanges = widget.post == null || 
                             _contentController.text != widget.post!.content;
    final hasCategoryChanges = widget.post == null || 
                              _selectedCategory != widget.post!.category;
    final hasImageChanges = _imageFile != null;
    
    final newHasChanges = hasContentChanges || hasCategoryChanges || hasImageChanges;
    
    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.post != null;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          isEditing ? '게시물 수정' : '새 게시물 작성',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onBackground,
          ),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges && !_isSubmitting ? _submitPost : null,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              isEditing ? '수정' : '등록',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _hasChanges && !_isSubmitting 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onBackground.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCategorySelector(theme),
            const Divider(height: 1),
            Expanded(
              child: _buildContentSection(theme),
            ),
            if (_isSubmitting)
              LinearProgressIndicator(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector(ThemeData theme) {
    return Consumer<NeighborhoodProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories.isNotEmpty
            ? provider.categories
            : [
                neighborhood_models.Category(id: '1', name: '동네질문', order: 1),
                neighborhood_models.Category(id: '2', name: '동네소식', order: 2),
                neighborhood_models.Category(id: '3', name: '동네맛집', order: 3),
                neighborhood_models.Category(id: '4', name: '일상', order: 4),
                neighborhood_models.Category(id: '5', name: '분실/실종', order: 5),
                neighborhood_models.Category(id: '6', name: '해주세요', order: 6),
              ];
        
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: theme.scaffoldBackgroundColor,
          child: Row(
            children: [
              Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                    dropdownColor: theme.scaffoldBackgroundColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? categories.first.name;
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((neighborhood_models.Category category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildContentSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: _contentController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: '우리 동네 이야기를 공유해보세요',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.4),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력해주세요';
                }
                return null;
              },
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground,
                height: 1.5,
              ),
              onChanged: (_) => _checkChanges(),
            ),
          ),
          if (_imageFile != null) ...[
            const SizedBox(height: 16),
            _buildImagePreview(theme),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.photo_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                tooltip: '사진 추가',
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  size: 24,
                ),
                tooltip: '위치 추가',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagePreview(ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _imageFile!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imageFile = null;
                _checkChanges();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _pickImage() async {
    // In a real app, you would implement image picking functionality here
    // For now, we'll just show a dialog indicating this is a placeholder
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: const Text('실제 앱에서는 이미지 선택 기능이 구현됩니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    
    // Comment the line below if you're adding real image picking
    // and uncomment the method to implement actual image picking
    setState(() {
      _imageFile = null; // Placeholder
      _checkChanges();
    });
  }
  
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('변경사항 저장'),
        content: const Text('변경 사항을 저장하지 않고 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close editor
            },
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitPost() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    final content = _contentController.text.trim();
    final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
    
    try {
      if (widget.post == null) {
        // Create new post
        final newPost = Post(
          id: widget.post?.id ?? '',
          title: '',  // Since there's no _titleController
          content: _contentController.text,
          authorId: '사용자ID', // Would come from user profile in real app
          authorName: '사용자', // Would come from user profile in real app
          authorAvatar: 'https://example.com/avatar.jpg', // Would come from user profile
          category: _selectedCategory.isNotEmpty ? _selectedCategory : '전체',
          createdAt: widget.post?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          likesCount: widget.post?.likesCount ?? 0,
          commentsCount: widget.post?.commentsCount ?? 0,
          isLiked: widget.post?.isLiked ?? false,
          images: _imageFile != null ? ['url_to_uploaded_image'] : widget.post?.images,
        );
        
        await provider.createPost(newPost);
      } else {
        // Update existing post
        final updatedPost = widget.post!.copyWith(
          category: _selectedCategory,
          content: content,
          images: _imageFile != null ? ['url_to_uploaded_image'] : widget.post!.images,
        );
        
        await provider.updatePost(updatedPost);
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      // Error handling is done in the provider
      setState(() {
        _isSubmitting = false;
      });
    }
  }
} 