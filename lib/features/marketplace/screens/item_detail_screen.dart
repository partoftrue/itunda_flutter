import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/market_item.dart';
import '../models/seller.dart';
import '../models/review.dart';
import '../providers/market_provider.dart';
import '../widgets/seller_profile_card.dart';
import '../widgets/review_item.dart';
import '../utils/format_utils.dart';
import 'seller_profile_screen.dart';
import '../services/translation_service.dart';
import '../widgets/safety_tip_card.dart';
import '../../chat/chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final MarketItem item;

  const ItemDetailScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _showTranslation = false;
  String _translatedDescription = '';
  bool _isTranslating = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final marketProvider = Provider.of<MarketProvider>(context);
    final isBookmarked = marketProvider.isBookmarked(widget.item);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _currentImageIndex == 0 
            ? Brightness.light
            : (isDark ? Brightness.light : Brightness.dark),
        statusBarBrightness: _currentImageIndex == 0 
            ? Brightness.dark 
            : (isDark ? Brightness.dark : Brightness.light),
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(theme, isBookmarked, marketProvider),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSellerInfo(theme),
                  Divider(thickness: 8, color: theme.dividerColor.withOpacity(0.05)),
                  _buildItemDetails(theme),
                  _buildSafetyTips(theme),
                  Divider(thickness: 8, color: theme.dividerColor.withOpacity(0.05)),
                  _buildReviewsSection(theme),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
        bottomSheet: _buildBottomBar(theme, widget.item),
        floatingActionButton: widget.item.has3DModel ? FloatingActionButton(
          heroTag: 'arView',
          backgroundColor: theme.colorScheme.secondary,
          mini: true,
          onPressed: () => _show3DModelViewer(),
          child: Icon(Icons.view_in_ar, color: theme.colorScheme.onSecondary),
        ) : null,
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isBookmarked, MarketProvider marketProvider) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: _currentImageIndex == 0 
              ? Colors.white 
              : theme.colorScheme.onBackground,
          shadows: _currentImageIndex == 0 
              ? [Shadow(color: Colors.black38, blurRadius: 20)]
              : null,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isBookmarked 
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: _currentImageIndex == 0 
                ? Colors.white 
                : theme.colorScheme.onBackground,
            shadows: _currentImageIndex == 0 
                ? [Shadow(color: Colors.black38, blurRadius: 20)]
                : null,
          ),
          onPressed: () {
            marketProvider.toggleBookmark(widget.item);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.share_rounded,
            color: _currentImageIndex == 0 
                ? Colors.white 
                : theme.colorScheme.onBackground,
            shadows: _currentImageIndex == 0 
                ? [Shadow(color: Colors.black38, blurRadius: 20)]
                : null,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: _currentImageIndex == 0 
                ? Colors.white 
                : theme.colorScheme.onBackground,
            shadows: _currentImageIndex == 0 
                ? [Shadow(color: Colors.black38, blurRadius: 20)]
                : null,
          ),
          onPressed: () {
            _showItemOptionsBottomSheet();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CarouselSlider(
              items: widget.item.images.map((image) {
                return Container(
                  width: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _currentImageIndex,
                  count: widget.item.images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${widget.item.images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfo(ThemeData theme) {
    // Placeholder seller data - in a real app, this would come from a service
    final seller = Seller(
      id: 'seller1',
      name: widget.item.sellerName ?? 'Unknown Seller',
      avatar: widget.item.sellerAvatar ?? 'https://randomuser.me/api/portraits/women/44.jpg',
      location: '역삼동',
      rating: 4.8,
      reviewCount: 56,
      itemCount: 24,
      transactionRate: 0.95,
      responseRate: 0.98,
      responseTime: '10분 이내',
      followerCount: 120,
      joinDate: DateTime.now().subtract(Duration(days: 365)),
    );
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: SellerProfileCard(
        seller: seller,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerProfileScreen(seller: seller),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemDetails(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.item.category,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (widget.item.isNegotiable)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '가격제안가능',
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.item.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.item.location} · ${widget.item.timeAgo}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16),
          Text(
            FormatUtils.formatPrice(widget.item.price),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(theme, Icons.visibility_rounded, '${widget.item.viewCount}명 조회'),
              SizedBox(width: 24),
              _buildStatItem(theme, Icons.favorite_rounded, '${widget.item.likesCount}명 관심'),
              SizedBox(width: 24),
              _buildStatItem(theme, Icons.chat_rounded, '${widget.item.chatCount}명 문의'),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '상품 정보',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          _buildItemDescription(theme),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            icon: Icon(
              _isDescriptionExpanded 
                  ? Icons.keyboard_arrow_up_rounded 
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
            label: Text(
              _isDescriptionExpanded ? '접기' : '더보기',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant,
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              elevation: 0,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildKeyValueRow(theme, '상품 상태', widget.item.condition),
          SizedBox(height: 12),
          _buildKeyValueRow(theme, '거래 방식', widget.item.exchangeMethod),
        ],
      ),
    );
  }

  Widget _buildItemDescription(ThemeData theme) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '상품 설명',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Translation toggle
                InkWell(
                  onTap: () async {
                    setState(() => _isTranslating = true);
                    try {
                      final translated = await TranslationService.translateFrom(
                        widget.item.description,
                        targetLanguage: TranslationService.getUserLanguage(),
                      );
                      setState(() {
                        _showTranslation = !_showTranslation;
                        _translatedDescription = translated;
                        _isTranslating = false;
                      });
                    } catch (e) {
                      setState(() => _isTranslating = false);
                    }
                  },
                  child: Row(
                    children: [
                      _isTranslating 
                          ? SizedBox(
                              height: 16, 
                              width: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : Icon(
                              _showTranslation 
                                  ? Icons.translate 
                                  : Icons.translate_outlined,
                              color: _showTranslation 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                      SizedBox(width: 4),
                      Text(
                        _showTranslation ? '원문 보기' : '번역하기',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _showTranslation 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              _showTranslation ? _translatedDescription : widget.item.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildKeyValueRow(ThemeData theme, String key, String? value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            key,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value ?? '정보 없음',
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(ThemeData theme) {
    // Sample reviews data - in a real app, this would come from a service
    final List<Review> reviews = [
      Review(
        id: '1',
        userId: 'user1',
        userName: '서민지',
        userAvatar: 'https://randomuser.me/api/portraits/women/33.jpg',
        rating: 5,
        comment: '물건 상태가 정말 좋고 거래도 친절하게 잘 해주셨어요! 다음에도 거래하고 싶어요.',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        itemId: widget.item.id,
      ),
      Review(
        id: '2',
        userId: 'user2',
        userName: '김준호',
        userAvatar: 'https://randomuser.me/api/portraits/men/45.jpg',
        rating: 4,
        comment: '좋은 상품 감사합니다. 배송이 조금 늦게 왔지만 물건은 만족스러워요.',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        itemId: widget.item.id,
      ),
    ];
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '거래 후기 (${reviews.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('모두 보기'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...reviews.map((review) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ReviewItem(review: review),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, MarketItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(Icons.chat_outlined),
                onPressed: () => _startChat(item),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _startChat(item),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(0, 56),
                ),
                child: Text('채팅하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '거래 주의사항',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SafetyTipCard(
            title: '직거래시 주의사항',
            tips: [
              '공공장소에서 거래하세요.',
              '현금 거래 시 위조지폐 여부를 확인하세요.',
              '판매자의 신원을 확인하세요.'
            ],
          ),
          SafetyTipCard(
            title: '안전 결제 이용하기',
            tips: [
              '계좌이체보다 안전결제를 이용하세요.',
              '물품을 받기 전에 송금하지 마세요.',
              '의심스러운 계좌로 송금하지 마세요.'
            ],
          ),
          SafetyTipCard(
            title: '사기 피해 신고',
            tips: [
              '의심스러운 판매자는 신고하세요.',
              '금전 요구에 응하지 마세요.',
              '개인정보 요청에 주의하세요.'
            ],
          ),
        ],
      ),
    );
  }

  void _showItemOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                _buildOptionItem(
                  theme: theme,
                  icon: Icons.flag_rounded,
                  title: '신고하기',
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog();
                  },
                ),
                _buildOptionItem(
                  theme: theme,
                  icon: Icons.block_rounded,
                  title: '판매자 차단하기',
                  onTap: () {
                    Navigator.pop(context);
                    // Block seller
                  },
                ),
                _buildOptionItem(
                  theme: theme,
                  icon: Icons.visibility_off_rounded,
                  title: '이 상품 숨기기',
                  onTap: () {
                    Navigator.pop(context);
                    // Hide item
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }

  void _showReportDialog() {
    final theme = Theme.of(context);
    final provider = Provider.of<MarketProvider>(context, listen: false);
    
    // Report reasons
    final List<String> reportReasons = [
      '허위 매물',
      '중복 게시글',
      '전문 판매업자',
      '사기 의심',
      '비매너 사용자',
      '기타',
    ];
    
    String selectedReason = reportReasons.first;
    final descriptionController = TextEditingController();
    bool isSubmitting = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('상품 신고하기'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '신고 사유',
                      style: theme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedReason,
                          isExpanded: true,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          borderRadius: BorderRadius.circular(8),
                          items: reportReasons.map((reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: Text(reason),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedReason = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '상세 설명',
                      style: theme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '신고 내용을 자세히 작성해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() {
                            isSubmitting = true;
                          });
                          
                          final success = await provider.reportItem(
                            widget.item.id,
                            selectedReason,
                            descriptionController.text,
                          );
                          
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? '신고가 접수되었습니다'
                                      : '신고 접수에 실패했습니다',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text('신고하기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _show3DModelViewer() {
    // In a real app, this would launch an AR view or 3D model viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('3D 모델 뷰어를 시작합니다'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _startChat(MarketItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: item.sellerId,
          recipientName: item.sellerName ?? '판매자',
          recipientAvatar: item.sellerAvatar ?? '',
          initialMessage: '${item.title}에 관심이 있습니다. 거래 가능할까요?',
          productInfo: {
            'id': item.id,
            'title': item.title,
            'price': item.price,
            'image': item.images.isNotEmpty ? item.images.first : null,
          },
        ),
      ),
    );
  }
} 