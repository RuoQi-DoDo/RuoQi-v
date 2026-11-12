import '../common/miniapp_localizations.dart';

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'miniapp_launcher_item.dart';

class MiniProgramLauncherSearchBar extends StatelessWidget {
  const MiniProgramLauncherSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                localizeMiniProgramLabel(context, '搜索小程序'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniProgramLauncherSectionHeader extends StatelessWidget {
  const MiniProgramLauncherSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          localizeMiniProgramLabel(context, title),
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizeMiniProgramLabel(context, trailing!),
                  style: const TextStyle(fontSize: 11),
                ),
                const Icon(Icons.chevron_right_rounded, size: 13),
              ],
            ),
          ),
      ],
    );
  }
}

class MiniProgramLauncherGrid extends StatelessWidget {
  const MiniProgramLauncherGrid({
    super.key,
    required this.items,
    required this.onOpen,
    this.mainAxisExtent = 72,
  });

  final List<MiniProgramLauncherItem> items;
  final ValueChanged<MiniProgramLauncherItem> onOpen;
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
        return MiniProgramLauncherTile(
          key: item.tileKey,
          item: item,
          onTap: () => onOpen(item),
        );
      },
    );
  }
}

class MiniProgramLauncherTile extends StatelessWidget {
  const MiniProgramLauncherTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MiniProgramLauncherItem item;
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
              color: item.color,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 18),
          Text(
            localizeMiniProgramLabel(context, item.label),
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

class MiniProgramLauncherBottomBar extends StatelessWidget {
  const MiniProgramLauncherBottomBar({
    super.key,
    required this.onSearch,
    required this.onMore,
  });

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
            tooltip: localizeMiniProgramLabel(context, '搜索'),
            icon: Icon(Icons.search_rounded, color: muted, size: 26),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: localizeMiniProgramLabel(context, '更多'),
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

class MiniProgramLauncherSwipeExitHandle extends StatelessWidget {
  const MiniProgramLauncherSwipeExitHandle({
    super.key,
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
      label: localizeMiniProgramLabel(context, '底部上滑返回客户首页'),
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
