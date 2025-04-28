import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? bottom;
  final Color? backgroundColor;
  final double height;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final bool showBorder;

  const IdsAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
    this.backgroundColor,
    this.height = 48,
    this.centerTitle = false,
    this.titleStyle,
    this.showBorder = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? height + 48 : height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        border: showBorder ? Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ) : null,
      ),
      child: AppBar(
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: centerTitle,
        titleSpacing: showBackButton ? 0 : 20,
        toolbarHeight: height,
        automaticallyImplyLeading: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: showBackButton 
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onBackground,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              visualDensity: VisualDensity.compact,
            )
          : leading,
        title: Text(
          title,
          style: titleStyle ?? TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions,
        bottom: bottom != null 
          ? PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: bottom!,
            )
          : null,
      ),
    );
  }
} 