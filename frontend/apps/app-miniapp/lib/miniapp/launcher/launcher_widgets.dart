import '../common/miniapp_localizations.dart';

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../localization.dart';
import 'miniapp_drag_targets.dart';
import 'miniapp_launcher_item.dart';
import 'miniapp_library_controller.dart';

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
              Flexible(
                child: Text(
                  localizeMiniProgramLabel(context, '搜索小程序'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
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
        Expanded(
          child: Text(
            localizeMiniProgramLabel(context, title),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (trailing != null)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
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
                    Flexible(
                      child: Text(
                        localizeMiniProgramLabel(context, trailing!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 13),
                  ],
                ),
              ),
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
    this.listKind,
    this.onDragStarted,
    this.onDragEnded,
    this.onReorder,
  });

  final List<MiniProgramLauncherItem> items;
  final ValueChanged<MiniProgramLauncherItem> onOpen;
  final double mainAxisExtent;
  final MiniProgramListKind? listKind;
  final ValueChanged<MiniProgramDragData>? onDragStarted;
  final VoidCallback? onDragEnded;
  final void Function(MiniProgramDragData data, String targetId)? onReorder;

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
        final tile = MiniProgramLauncherTile(
          key: item.tileKey,
          item: item,
          onTap: () => onOpen(item),
          draggable: listKind != null && onDragStarted != null,
        );
        final kind = listKind;
        if (kind == null || onDragStarted == null) return tile;
        final payload = MiniProgramDragData(item: item, kind: kind);
        final theme = Theme.of(context);
        final draggable = LongPressDraggable<MiniProgramDragData>(
          key: Key('mini-program-drag-${kind.name}-${item.id}'),
          data: payload,
          maxSimultaneousDrags: 1,
          rootOverlay: true,
          dragAnchorStrategy: (_, _, _) => const Offset(44, 88),
          hapticFeedbackOnStart: true,
          onDragStarted: () => onDragStarted?.call(payload),
          onDragEnd: (_) => onDragEnded?.call(),
          childWhenDragging: Opacity(opacity: 0.25, child: tile),
          feedback: Theme(
            data: theme,
            child: _MiniProgramDragFeedback(item: item),
          ),
          child: tile,
        );
        if (onReorder == null) return draggable;
        return DragTarget<MiniProgramDragData>(
          onWillAcceptWithDetails: (details) =>
              details.data.kind == kind && details.data.item.id != item.id,
          onAcceptWithDetails: (details) =>
              onReorder?.call(details.data, item.id),
          builder: (context, candidates, rejected) => AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: candidates.isEmpty
                  ? Colors.transparent
                  : theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: draggable,
          ),
        );
      },
    );
  }
}

class _MiniProgramDragFeedback extends StatelessWidget {
  const _MiniProgramDragFeedback({required this.item});

  final MiniProgramLauncherItem item;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: SizedBox(
      width: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniProgramLauncherIcon(item: item, size: 56),
          const SizedBox(height: 8),
          Text(
            localizeMiniProgramLabel(context, item.label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    ),
  );
}

class MiniProgramLauncherTile extends StatelessWidget {
  const MiniProgramLauncherTile({
    super.key,
    required this.item,
    required this.onTap,
    this.draggable = false,
  });

  final MiniProgramLauncherItem item;
  final VoidCallback onTap;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      hint: draggable
          ? AppLocalizations.of(context).text(
              '长按拖动，可添加、删除或排序',
              'Long press to drag, add, delete or reorder',
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            MiniProgramLauncherIcon(item: item, size: 38),
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
