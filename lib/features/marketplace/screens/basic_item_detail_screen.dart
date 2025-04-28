import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../models/market_item.dart';
import '../providers/market_provider.dart';
import '../../chat/chat_screen.dart';

class BasicItemDetailScreen extends StatefulWidget {
  final MarketItem item;

  const BasicItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<BasicItemDetailScreen> createState() => _BasicItemDetailScreenState();
}

class _BasicItemDetailScreenState extends State<BasicItemDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  bool _isFullScreenGallery = false;
  
  void _contactSeller() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          recipientId: widget.item.sellerId,
          recipientName: widget.item.sellerName ?? 'Seller',
          recipientAvatar: widget.item.sellerAvatar ?? '',
          initialMessage: 'Hi, is ${widget.item.title} still available?',
          productInfo: {
            'id': widget.item.id,
            'title': widget.item.title,
            'price': widget.item.price,
            'image': widget.item.images.isNotEmpty ? widget.item.images[0] : '',
          },
        ),
      ),
    );
  }
  
  void _openFullScreenGallery(int initialIndex) {
    if (widget.item.images.isEmpty) return;
    
    setState(() {
      _isFullScreenGallery = true;
      _currentImageIndex = initialIndex;
    });
  }
  
  void _closeFullScreenGallery() {
    setState(() {
      _isFullScreenGallery = false;
    });
  }
  
  Widget _buildGallery() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.item.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openFullScreenGallery(index),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.05),
                child: CachedNetworkImage(
                  imageUrl: widget.item.images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              ),
            );
          },
        ),
        // Image indicators
        if (widget.item.images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.item.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(
                      _currentImageIndex == entry.key ? 1.0 : 0.4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFullScreenGallery() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.item.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              );
            },
            itemCount: widget.item.images.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
            pageController: PageController(initialPage: _currentImageIndex),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: _closeFullScreenGallery,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentImageIndex + 1} / ${widget.item.images.length}',
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItemDetails() {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with image carousel
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          floating: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.share_outlined,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () {
                // Share functionality could be added here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon'))
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: widget.item.images.isNotEmpty
                ? _buildGallery()
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        
        // Item content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price
                Text(
                  widget.item.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.item.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Seller info
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: widget.item.sellerAvatar != null && widget.item.sellerAvatar!.isNotEmpty
                          ? NetworkImage(widget.item.sellerAvatar!)
                          : null,
                      child: widget.item.sellerAvatar == null || widget.item.sellerAvatar!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.sellerName ?? 'Seller',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.location ?? 'Unknown location',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                
                // Item description
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.item.description,
                  style: theme.textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 24),
                
                // Additional item details
                Text(
                  'Posted on: ${widget.item.postDate != null ? widget.item.postDate.toString().substring(0, 10) : 'Unknown date'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${widget.item.category}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                // Add space at the bottom for fixed action buttons
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isFullScreenGallery) {
      return _buildFullScreenGallery();
    }
    
    return Scaffold(
      body: Stack(
        children: [
          _buildItemDetails(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _contactSeller,
                child: const Text('Message Seller'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 