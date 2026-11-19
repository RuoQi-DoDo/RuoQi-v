import 'package:material_ui/material_ui.dart';

import '../../localization.dart';
import 'ai_style.dart';

enum AiHistoryGroup { today, yesterday, lastSevenDays, older }

enum _HistoryAction { rename, pin, multiSelect, delete }

class AiHistoryEntry {
  const AiHistoryEntry({
    required this.id,
    required this.title,
    required this.group,
    required this.updatedAt,
    this.pinned = false,
  });

  final String id;
  final String title;
  final AiHistoryGroup group;
  final DateTime updatedAt;
  final bool pinned;

  AiHistoryEntry copyWith({
    String? title,
    AiHistoryGroup? group,
    DateTime? updatedAt,
    bool? pinned,
  }) {
    return AiHistoryEntry(
      id: id,
      title: title ?? this.title,
      group: group ?? this.group,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
    );
  }
}

class AiHistoryPanel extends StatefulWidget {
  const AiHistoryPanel({
    super.key,
    required this.entries,
    required this.onSelect,
    required this.modelName,
    required this.onOpenSettings,
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final List<AiHistoryEntry> entries;
  final ValueChanged<AiHistoryEntry> onSelect;
  final String modelName;
  final VoidCallback onOpenSettings;
  final Future<void> Function(AiHistoryEntry entry, String title) onRename;
  final Future<void> Function(AiHistoryEntry entry, bool pinned) onPin;
  final Future<void> Function(AiHistoryEntry entry) onDelete;

  @override
  State<AiHistoryPanel> createState() => _AiHistoryPanelState();
}

class _AiHistoryPanelState extends State<AiHistoryPanel> {
  final TextEditingController _search = TextEditingController();
  late List<AiHistoryEntry> _entries = List<AiHistoryEntry>.of(widget.entries);
  final Set<AiHistoryEntry> _selected = <AiHistoryEntry>{};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refreshSearch);
  }

  @override
  void didUpdateWidget(covariant AiHistoryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.entries, widget.entries)) {
      _entries = List<AiHistoryEntry>.of(widget.entries);
      _selected.clear();
    }
  }

  @override
  void dispose() {
    _search
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  void _refreshSearch() => setState(() {});

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selected.clear();
    });
  }

  void _toggleEntry(AiHistoryEntry entry) {
    setState(() {
      if (!_selected.add(entry)) {
        _selected.remove(entry);
      }
    });
  }

  void _openEntry(AiHistoryEntry entry) {
    if (_selectionMode) {
      _toggleEntry(entry);
    } else {
      widget.onSelect(entry);
    }
  }

  Future<void> _showEntryMenu(
    BuildContext rowContext,
    AiHistoryEntry entry,
  ) async {
    final box = rowContext.findRenderObject();
    final overlay = Overlay.of(rowContext).context.findRenderObject();
    if (box is! RenderBox || overlay is! RenderBox) {
      return;
    }
    final text = AppLocalizations.of(rowContext);
    final origin = box.localToGlobal(
      Offset(0, box.size.height),
      ancestor: overlay,
    );
    const menuWidth = 224.0;
    const menuLeft = 52.0;
    final position = RelativeRect.fromLTRB(
      menuLeft,
      origin.dy + 8,
      MediaQuery.sizeOf(rowContext).width - menuLeft - menuWidth,
      0,
    );
    final action = await showMenu<_HistoryAction>(
      context: rowContext,
      position: position,
      color: AiColors.surface(rowContext),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: const BoxConstraints.tightFor(width: menuWidth),
      items: [
        _historyMenuItem(
          value: _HistoryAction.rename,
          icon: Icons.edit_outlined,
          label: text.text('重命名', 'Rename'),
          context: rowContext,
        ),
        const PopupMenuDivider(height: 1, indent: 18, endIndent: 18),
        _historyMenuItem(
          value: _HistoryAction.pin,
          icon: Icons.push_pin_outlined,
          label: text.text('置顶', 'Pin'),
          context: rowContext,
        ),
        const PopupMenuDivider(height: 1, indent: 18, endIndent: 18),
        _historyMenuItem(
          value: _HistoryAction.multiSelect,
          icon: Icons.checklist_rounded,
          label: text.text('多选', 'Select'),
          context: rowContext,
        ),
        const PopupMenuDivider(height: 1, indent: 18, endIndent: 18),
        _historyMenuItem(
          value: _HistoryAction.delete,
          icon: Icons.delete_outline_rounded,
          label: text.text('删除', 'Delete'),
          context: rowContext,
          destructive: true,
        ),
      ],
    );
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case _HistoryAction.rename:
        await _renameEntry(entry);
        break;
      case _HistoryAction.pin:
        await _pinEntry(entry);
        break;
      case _HistoryAction.multiSelect:
        _beginSelection(entry);
        break;
      case _HistoryAction.delete:
        await _deleteEntry(entry);
        break;
    }
  }

  PopupMenuItem<_HistoryAction> _historyMenuItem({
    required _HistoryAction value,
    required IconData icon,
    required String label,
    required BuildContext context,
    bool destructive = false,
  }) {
    final color = destructive
        ? AiColors.danger(context)
        : AiColors.text(context);
    return PopupMenuItem<_HistoryAction>(
      value: value,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renameEntry(AiHistoryEntry entry) async {
    final text = AppLocalizations.of(context);
    var title = entry.title;
    final renamed = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(text.text('重命名对话', 'Rename chat')),
        content: TextFormField(
          key: const Key('ai-history-rename-input'),
          initialValue: entry.title,
          autofocus: true,
          maxLength: 60,
          onChanged: (value) => title = value.trim(),
          decoration: InputDecoration(
            hintText: text.text('输入新的对话名称', 'Enter a new title'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(text.text('取消', 'Cancel')),
          ),
          TextButton(
            key: const Key('ai-history-rename-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(title),
            child: Text(text.text('保存', 'Save')),
          ),
        ],
      ),
    );
    if (!mounted || renamed == null || renamed.isEmpty) {
      return;
    }
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) {
      return;
    }
    setState(() {
      _entries[index] = _entries[index].copyWith(
        title: renamed,
        updatedAt: DateTime.now(),
      );
    });
    await widget.onRename(entry, renamed);
  }

  Future<void> _pinEntry(AiHistoryEntry entry) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index < 0) {
      return;
    }
    final current = _entries[index];
    final pinned = !current.pinned;
    setState(() {
      _entries
        ..removeAt(index)
        ..insert(
          0,
          current.copyWith(
            pinned: pinned,
            group: pinned
                ? AiHistoryGroup.today
                : _groupForDate(current.updatedAt),
          ),
        );
    });
    await widget.onPin(entry, pinned);
  }

  void _beginSelection(AiHistoryEntry entry) {
    setState(() {
      _selectionMode = true;
      _selected
        ..clear()
        ..add(entry);
    });
  }

  Future<void> _deleteEntry(AiHistoryEntry entry) async {
    setState(() {
      _entries.removeWhere((item) => item.id == entry.id);
      _selected.removeWhere((item) => item.id == entry.id);
    });
    await widget.onDelete(entry);
  }

  AiHistoryGroup _groupForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final difference = today.difference(day).inDays;
    if (difference <= 0) {
      return AiHistoryGroup.today;
    }
    if (difference == 1) {
      return AiHistoryGroup.yesterday;
    }
    if (difference < 7) {
      return AiHistoryGroup.lastSevenDays;
    }
    return AiHistoryGroup.older;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    final query = _search.text.trim().toLowerCase();
    final visible = _entries
        .where((entry) => entry.title.toLowerCase().contains(query))
        .toList(growable: false);

    return ColoredBox(
      key: const Key('ai-history-drawer'),
      color: AiColors.surface(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 13, 17, 8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AiColors.searchSurface(context),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: AiColors.muted(context),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: TextField(
                      key: const Key('ai-history-search'),
                      controller: _search,
                      style: TextStyle(
                        color: AiColors.text(context),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: text.text('搜索对话内容...', 'Search chats...'),
                        hintStyle: TextStyle(
                          color: AiColors.hint(context),
                          fontSize: 18,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_search.text.isNotEmpty)
                    InkResponse(
                      onTap: _search.clear,
                      radius: 18,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 19,
                        color: AiColors.hint(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty
                          ? text.text('暂无对话记录', 'No chats yet')
                          : text.text('没有找到相关对话', 'No matching chats'),
                      style: TextStyle(
                        color: AiColors.muted(context),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      for (final group in AiHistoryGroup.values)
                        if (visible.any((entry) => entry.group == group)) ...[
                          _HistoryGroupHeader(
                            label: _groupLabel(text, group),
                            showSelectionAction: group == AiHistoryGroup.today,
                            selectionMode: _selectionMode,
                            onToggleSelection: _toggleSelectionMode,
                          ),
                          for (final entry in visible.where(
                            (entry) => entry.group == group,
                          ))
                            _HistoryRow(
                              entry: entry,
                              selectionMode: _selectionMode,
                              selected: _selected.contains(entry),
                              onTap: () => _openEntry(entry),
                              onLongPress: (rowContext) =>
                                  _showEntryMenu(rowContext, entry),
                            ),
                        ],
                    ],
                  ),
          ),
          Container(
            key: const Key('ai-history-model'),
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AiColors.border(context),
                  width: 1 / MediaQuery.devicePixelRatioOf(context),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.text('当前模型', 'Current model'),
                        style: TextStyle(
                          color: AiColors.muted(context),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.modelName.isEmpty
                            ? text.text('未选择模型', 'No model selected')
                            : widget.modelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AiColors.text(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('ai-history-settings'),
                  tooltip: text.text('设置', 'Settings'),
                  onPressed: widget.onOpenSettings,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 23,
                    color: AiColors.muted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _groupLabel(AppLocalizations text, AiHistoryGroup group) {
    return switch (group) {
      AiHistoryGroup.today => text.text('今天', 'Today'),
      AiHistoryGroup.yesterday => text.text('昨天', 'Yesterday'),
      AiHistoryGroup.lastSevenDays => text.text('7 天内', 'Previous 7 days'),
      AiHistoryGroup.older => text.text('更早', 'Earlier'),
    };
  }
}

class _HistoryGroupHeader extends StatelessWidget {
  const _HistoryGroupHeader({
    required this.label,
    required this.showSelectionAction,
    required this.selectionMode,
    required this.onToggleSelection,
  });

  final String label;
  final bool showSelectionAction;
  final bool selectionMode;
  final VoidCallback onToggleSelection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AiColors.muted(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            if (showSelectionAction)
              IconButton(
                key: const Key('ai-history-multi-select'),
                tooltip: selectionMode
                    ? AppLocalizations.of(context).text('取消多选', 'Cancel')
                    : AppLocalizations.of(context).text('多选', 'Select'),
                onPressed: onToggleSelection,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  selectionMode ? Icons.close_rounded : Icons.checklist_rounded,
                  size: 22,
                  color: AiColors.muted(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.entry,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final AiHistoryEntry entry;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<BuildContext> onLongPress;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (rowContext) => InkWell(
        onTap: onTap,
        onLongPress: () => onLongPress(rowContext),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 14),
            child: Row(
              children: [
                if (selectionMode) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AiColors.accent(context)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? AiColors.accent(context)
                            : AiColors.border(context),
                        width: 1.4,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            color: AiColors.onAccent(context),
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AiColors.text(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
