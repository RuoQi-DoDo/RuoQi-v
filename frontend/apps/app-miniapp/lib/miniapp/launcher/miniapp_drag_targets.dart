import 'package:flutter/material.dart';

import '../../localization.dart';
import 'miniapp_launcher_item.dart';
import 'miniapp_library_controller.dart';

/// Carries both the entry and its source list so removing a recent entry does
/// not also remove a saved mini-program.
@immutable
class MiniProgramDragData {
  const MiniProgramDragData({required this.item, required this.kind});

  final MiniProgramLauncherItem item;
  final MiniProgramListKind kind;
}

/// WeChat-style drop actions. The caller supplies the bottom safe-area padding.
class MiniProgramDragActions extends StatelessWidget {
  const MiniProgramDragActions({
    super.key,
    required this.data,
    required this.alreadyInMy,
    required this.onAddToMy,
    required this.onDelete,
  });

  final MiniProgramDragData data;
  final bool alreadyInMy;
  final ValueChanged<MiniProgramDragData> onAddToMy;
  final ValueChanged<MiniProgramDragData> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MiniProgramDropZone(
                key: const Key('mini-program-drop-add'),
                data: data,
                enabled: !alreadyInMy,
                icon: alreadyInMy ? Icons.check_rounded : Icons.apps_rounded,
                label: alreadyInMy
                    ? l10n.text('已添加到我的小程序', 'Already in My mini-programs')
                    : l10n.text(
                        '拖动到此处添加为我的小程序',
                        'Drag here to add to My mini-programs',
                      ),
                activeLabel: l10n.text('松手添加', 'Release to add'),
                color: const Color(0xFF616161),
                activeColor: const Color(0xFF454545),
                onAccept: onAddToMy,
              ),
            ),
            Expanded(
              child: _MiniProgramDropZone(
                key: const Key('mini-program-drop-delete'),
                data: data,
                enabled: true,
                icon: Icons.delete_outline_rounded,
                label: l10n.text('删除', 'Delete'),
                activeLabel: l10n.text('松手删除', 'Release to delete'),
                color: const Color(0xFFEF4141),
                activeColor: const Color(0xFFD62E2E),
                onAccept: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniProgramDropZone extends StatefulWidget {
  const _MiniProgramDropZone({
    super.key,
    required this.data,
    required this.enabled,
    required this.icon,
    required this.label,
    required this.activeLabel,
    required this.color,
    required this.activeColor,
    required this.onAccept,
  });

  final MiniProgramDragData data;
  final bool enabled;
  final IconData icon;
  final String label;
  final String activeLabel;
  final Color color;
  final Color activeColor;
  final ValueChanged<MiniProgramDragData> onAccept;

  @override
  State<_MiniProgramDropZone> createState() => _MiniProgramDropZoneState();
}

class _MiniProgramDropZoneState extends State<_MiniProgramDropZone> {
  bool _hovered = false;

  bool _canAccept(MiniProgramDragData data) =>
      widget.enabled && data.item.id == widget.data.item.id;

  void _setHovered(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  @override
  Widget build(BuildContext context) => DragTarget<MiniProgramDragData>(
    onWillAcceptWithDetails: (details) {
      final accepted = _canAccept(details.data);
      _setHovered(accepted);
      return accepted;
    },
    onMove: (details) => _setHovered(_canAccept(details.data)),
    onLeave: (_) => _setHovered(false),
    onAcceptWithDetails: (details) {
      _setHovered(false);
      widget.onAccept(details.data);
    },
    builder: (context, candidates, rejected) => Semantics(
      label: _hovered ? widget.activeLabel : widget.label,
      enabled: widget.enabled,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        color: _hovered ? widget.activeColor : widget.color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _hovered ? 1.15 : 1,
              duration: const Duration(milliseconds: 120),
              child: Icon(widget.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 7),
            SizedBox(
              // Keep the hit area stable when the shorter release label shows.
              height: MediaQuery.textScalerOf(context).scale(12) * 1.2 * 3,
              child: Center(
                child: Text(
                  _hovered ? widget.activeLabel : widget.label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
