import 'package:flutter/material.dart';

import 'miniapp_page_header.dart';

/// Lets each mini-program keep page titles inside its own scrollable content.
///
/// The host capsule remains fixed above this canvas; the optional title/back
/// row is a non-pinned sliver so it leaves the viewport with the page.
class MiniProgramPageCanvas extends StatelessWidget {
  const MiniProgramPageCanvas({
    super.key,
    required this.child,
    this.title = '',
    this.onBack,
    this.leading,
    this.foregroundColor,
    this.showTitle = true,
    this.onScrollChanged,
  });

  final Widget child;
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Color? foregroundColor;
  final bool showTitle;
  final ValueChanged<bool>? onScrollChanged;

  @override
  Widget build(BuildContext context) {
    final shouldShowTitle = showTitle && title.isNotEmpty;
    if (!shouldShowTitle) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          onScrollChanged?.call(notification.metrics.pixels > 8);
          return false;
        },
        child: child,
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        onScrollChanged?.call(notification.metrics.pixels > 8);
        return false;
      },
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: MiniProgramPageHeader(
              title: title,
              onBack: onBack,
              leading: leading,
              foregroundColor: foregroundColor,
            ),
          ),
        ],
        body: child,
      ),
    );
  }
}
