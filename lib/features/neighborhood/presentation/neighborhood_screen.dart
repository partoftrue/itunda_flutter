import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/neighborhood_post.dart';
import '../data/neighborhood_repository_impl.dart';
import '../data/api/neighborhood_api_service.dart';
import '../widgets/post_list_item.dart';
import '../widgets/category_tabs.dart';
import 'post_detail_screen.dart';

class NeighborhoodScreen extends StatefulWidget {
  const NeighborhoodScreen({Key? key}) : super(key: key);

  @override
  _NeighborhoodScreenState createState() => _NeighborhoodScreenState();
}

class _NeighborhoodScreenState extends State<NeighborhoodScreen> {
  final List<String> _categories = [
    '전체',
    '동네질문',
    '동네소식',
    '일상',
    '같이해요',
    '동네맛집',
    '취미생활',
    '분실/실종',
    '해주세요',
  ];
  
  String _selectedCategory = '전체';
  bool _isLoading = true;
  List<NeighborhoodPost> _posts = [];
  final NeighborhoodRepositoryImpl _repository = NeighborhoodRepositoryImpl(
    NeighborhoodApiService(),
  );
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }
  
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_selectedCategory == '전체') {
        _posts = await _repository.getAllPosts();
      } else {
        _posts = await _repository.getPostsByCategory(_selectedCategory);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물을 불러오는데 실패했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadPosts();
  }
  
  Future<void> _onRefresh() async {
    await _loadPosts();
  }
  
  void _navigateToPostDetail(NeighborhoodPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    ).then((_) => _loadPosts()); // Refresh after returning from detail
  }
  
  void _showCreatePostDialog() {
    // Navigate to post creation page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시물 작성 기능은 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동네생활'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('검색 기능은 준비 중입니다.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          CategoryTabs(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
          
          // Posts list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 게시물이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '첫 번째 게시물을 작성해보세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _posts.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            return InkWell(
                              onTap: () => _navigateToPostDetail(post),
                              child: PostListItem(post: post),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
        tooltip: '글쓰기',
      ),
    );
  }
} 