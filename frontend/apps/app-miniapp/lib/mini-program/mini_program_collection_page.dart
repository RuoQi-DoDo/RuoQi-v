part of '../pages/im/im_home_page.dart';

class _MiniProgramCollectionPage extends StatelessWidget {
  const _MiniProgramCollectionPage({
    super.key,
    required this.title,
    required this.items,
    required this.onBack,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onOpenHr,
    required this.onOpenPlatform,
    required this.onSearch,
    required this.onOther,
  });

  final String title;
  final List<_LauncherMiniProgramData> items;
  final VoidCallback onBack;
  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onOpenHr;
  final VoidCallback onOpenPlatform;
  final VoidCallback onSearch;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('mini-program-collection-back'),
                  tooltip: '返回',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PickerSearchBar(onTap: onSearch),
        ),
        const SizedBox(height: 34),
        Expanded(
          child: ListView(
            key: const Key('mini-program-collection-list'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              _LauncherGrid(
                items: items,
                onOpenAts: onOpenAts,
                onOpenMerchant: onOpenMerchant,
                onOpenPartner: onOpenPartner,
                onOpenHr: onOpenHr,
                onOpenPlatform: onOpenPlatform,
                onOther: onOther,
                mainAxisExtent: 94,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickerSwipeUpExitHandle extends StatelessWidget {
  const _PickerSwipeUpExitHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.child,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '底部上滑返回客户首页',
      child: GestureDetector(
        key: const Key('mini-program-picker-exit-swipe'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        onVerticalDragCancel: onDragCancel,
        child: child,
      ),
    );
  }
}

class _LauncherMiniProgramData {
  const _LauncherMiniProgramData({
    required this.label,
    required this.icon,
    required this.color,
    this.opensAts = false,
    this.opensMerchant = false,
    this.opensPartner = false,
    this.opensHr = false,
    this.opensPlatform = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool opensAts;
  final bool opensMerchant;
  final bool opensPartner;
  final bool opensHr;
  final bool opensPlatform;
}

class _LauncherGrid extends StatelessWidget {
  const _LauncherGrid({
    required this.items,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onOpenHr,
    required this.onOpenPlatform,
    required this.onOther,
    this.highlightAtsForTest = false,
    this.highlightHrForTest = false,
    this.mainAxisExtent = 72,
  });

  final List<_LauncherMiniProgramData> items;
  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onOpenHr;
  final VoidCallback onOpenPlatform;
  final VoidCallback onOther;
  final bool highlightAtsForTest;
  final bool highlightHrForTest;
  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: 8,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final key = item.opensAts && highlightAtsForTest
            ? const Key('mini-program-picker-ats')
            : item.opensMerchant
            ? const Key('mini-program-picker-merchant')
            : item.opensHr && highlightHrForTest
            ? const Key('mini-program-picker-hr')
            : item.opensPartner
            ? const Key('mini-program-picker-partner')
            : item.opensPlatform
            ? const Key('mini-program-picker-platform')
            : null;
        return _LauncherMiniProgramTile(
          key: key,
          data: item,
          onTap: item.opensAts
              ? onOpenAts
              : item.opensMerchant
              ? onOpenMerchant
              : item.opensHr
              ? onOpenHr
              : item.opensPartner
              ? onOpenPartner
              : item.opensPlatform
              ? onOpenPlatform
              : onOther,
        );
      },
    );
  }
}

class _LauncherMiniProgramTile extends StatelessWidget {
  const _LauncherMiniProgramTile({
    super.key,
    required this.data,
    required this.onTap,
  });

  final _LauncherMiniProgramData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 18),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 10,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerBottomBar extends StatelessWidget {
  const _PickerBottomBar({required this.onSearch, required this.onMore});

  final VoidCallback onSearch;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    return Container(
      height: 60,
      color: scheme.surfaceContainer,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'RuoQi',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: '搜索',
            icon: Icon(Icons.search_rounded, color: muted, size: 26),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: '更多',
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String preview;
  final String time;
  final int unread;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$unread',
                              style: TextStyle(
                                color: scheme.onError,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
