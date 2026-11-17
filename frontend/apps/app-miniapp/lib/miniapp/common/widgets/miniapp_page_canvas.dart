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
    this.headerDecoration,
    this.extendHeaderBehindStatusBar = false,
  });

  final Widget child;
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Color? foregroundColor;
  final bool showTitle;
  final ValueChanged<bool>? onScrollChanged;
  final Decoration? headerDecoration;
  final bool extendHeaderBehindStatusBar;

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
    Widget header = MiniProgramPageHeader(
      title: title,
      onBack: onBack,
      leading: leading,
      foregroundColor: foregroundColor,
    );
    if (extendHeaderBehindStatusBar) {
      header = DecoratedBox(
        key: const Key('miniapp-extended-page-header'),
        decoration:
            headerDecoration ??
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top),
            header,
          ],
        ),
      );
    } else if (headerDecoration != null) {
      header = DecoratedBox(decoration: headerDecoration!, child: header);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        onScrollChanged?.call(notification.metrics.pixels > 8);
        return false;
      },
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: header),
        ],
        body: child,
      ),
    );
  }
}
