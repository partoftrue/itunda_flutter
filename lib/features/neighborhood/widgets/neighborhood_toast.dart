import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/neighborhood_provider.dart';

class NeighborhoodToast extends StatefulWidget {
  final Widget child;
  
  const NeighborhoodToast({
    super.key,
    required this.child,
  });

  @override
  State<NeighborhoodToast> createState() => _NeighborhoodToastState();
}

class _NeighborhoodToastState extends State<NeighborhoodToast> with SingleTickerProviderStateMixin {
  String? _message;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Listen to toast stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
      provider.toastStream.listen((message) {
        _showToast(message);
      });
    });
  }
  
  void _showToast(String message) {
    setState(() {
      _message = message;
    });
    
    _animationController.forward();
    
    // Hide toast after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_message != null)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildToastContent(context, _message!),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildToastContent(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[800] 
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? Colors.white 
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 