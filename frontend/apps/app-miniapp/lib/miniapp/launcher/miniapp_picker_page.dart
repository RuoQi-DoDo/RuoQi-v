import '../common/miniapp_localizations.dart';

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../localization.dart';
import 'launcher_widgets.dart';
import 'miniapp_drag_targets.dart';
import 'miniapp_library_controller.dart';
import 'miniapp_collection_page.dart';
import 'miniapp_launcher_item.dart';

/// 客户首页的小程序选择页。
class MiniProgramPickerPage extends StatefulWidget {
  const MiniProgramPickerPage({
    super.key,
    required this.onOpen,
    required this.onCloseDragStart,
    required this.onCloseDragUpdate,
    required this.onCloseDragEnd,
    required this.onCloseDragCancel,
  });

  final ValueChanged<MiniProgramLauncherItem> onOpen;
  final GestureDragStartCallback onCloseDragStart;
  final GestureDragUpdateCallback onCloseDragUpdate;
  final GestureDragEndCallback onCloseDragEnd;
  final VoidCallback onCloseDragCancel;

  @override
  State<MiniProgramPickerPage> createState() => _MiniProgramPickerPageState();
}

enum _MiniProgramCollectionView { recent, mine }

class _MiniProgramPickerPageState extends State<MiniProgramPickerPage> {
  _MiniProgramCollectionView? _collectionView;
  MiniProgramLibraryController? _ownedLibrary;
  late MiniProgramLibraryController _library;
  MiniProgramDragData? _dragData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _library =
        MiniProgramLibraryScope.maybeOf(context) ??
        (_ownedLibrary ??= MiniProgramLibraryController());
  }

  @override
  void dispose() {
    _ownedLibrary?.dispose();
    super.dispose();
  }

  void _startDrag(MiniProgramDragData data) => setState(() => _dragData = data);

  void _endDrag() {
    if (mounted && _dragData != null) setState(() => _dragData = null);
  }

  void _addToMy(MiniProgramDragData data) {
    _endDrag();
    final added = _library.addToMy(data.item);
    final l10n = AppLocalizations.of(context);
    _pickerToast(
      context,
      added
          ? l10n.text('已添加到我的小程序', 'Added to My mini-programs')
          : l10n.text('已在我的小程序中', 'Already in My mini-programs'),
    );
  }

  void _delete(MiniProgramDragData data) {
    _endDrag();
    final l10n = AppLocalizations.of(context);
    if (data.kind == MiniProgramListKind.recent) {
      _library.removeRecent(data.item.id);
      _pickerToast(
        context,
        l10n.text('已从最近使用中移除', 'Removed from recent mini-programs'),
      );
    } else {
      _library.removeFromMy(data.item.id);
      _pickerToast(
        context,
        l10n.text('已从我的小程序中移除', 'Removed from My mini-programs'),
      );
    }
  }

  void _reorder(MiniProgramDragData data, String targetId) {
    _library.reorder(data.kind, data.item.id, targetId);
  }

  void _open(MiniProgramLauncherItem item) {
    if (_dragData != null) return;
    _library.recordOpen(item);
    widget.onOpen(item);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _library,
    builder: (context, _) => _buildWithTheme(context),
  );

  Widget _buildWithTheme(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final brightness = Theme.of(context).brightness;
    final baseTheme = ruoQiTheme(brightness: brightness, accent: accent);
    if (brightness == Brightness.light) {
      final pickerTheme = baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        colorScheme: baseTheme.colorScheme.copyWith(
          surface: const Color(0xFFF2F2F2),
          surfaceContainerLowest: const Color(0xFFF7F7F7),
          surfaceContainerLow: Colors.white,
          surfaceContainer: Colors.white,
          surfaceContainerHigh: const Color(0xFFEAEAEA),
          onSurface: const Color(0xFF111111),
          onSurfaceVariant: const Color(0xFF707070),
          outlineVariant: const Color(0xFFDEDEDE),
        ),
      );
      return Theme(data: pickerTheme, child: _buildPickerContent(context));
    }
    final pickerTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF303030),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: const Color(0xFF303030),
        surfaceContainerLowest: const Color(0xFF292929),
        surfaceContainerLow: const Color(0xFF424242),
        surfaceContainer: const Color(0xFF565656),
        surfaceContainerHigh: const Color(0xFF383838),
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xFFBDBDBD),
        outlineVariant: const Color(0xFF4A4A4A),
      ),
    );
    return Theme(data: pickerTheme, child: _buildPickerContent(context));
  }

  Widget _buildPickerContent(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final recent = _library.recentItems;
        final commonItems = _library.myItems;
        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            bottom: false,
            child: _collectionView != null
                ? MiniProgramCollectionPage(
                    key: ValueKey(
                      'mini-program-collection-${_collectionView!.name}',
                    ),
                    title: _collectionView == _MiniProgramCollectionView.recent
                        ? '最近使用的小程序'
                        : '我的小程序',
                    items: _collectionView == _MiniProgramCollectionView.recent
                        ? recent
                        : commonItems,
                    listKind:
                        _collectionView == _MiniProgramCollectionView.recent
                        ? MiniProgramListKind.recent
                        : MiniProgramListKind.mine,
                    onDragStarted: _startDrag,
                    onDragEnded: _endDrag,
                    onReorder: _reorder,
                    onBack: () {
                      if (_dragData == null) {
                        setState(() => _collectionView = null);
                      }
                    },
                    onOpen: _open,
                    onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 58,
                        child: Center(
                          child: Text(
                            localizeMiniProgramLabel(context, '最近'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MiniProgramLauncherSearchBar(
                          onTap: () => _pickerToast(context, '搜索小程序为模拟入口'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            MiniProgramLauncherSectionHeader(
                              title: '最近使用的小程序',
                              trailing: '更多',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.recent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (recent.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  AppLocalizations.of(context).text(
                                    '暂无最近使用的小程序',
                                    'No recent mini-programs',
                                  ),
                                ),
                              ),
                            MiniProgramLauncherGrid(
                              items: recent,
                              listKind: MiniProgramListKind.recent,
                              onDragStarted: _startDrag,
                              onDragEnded: _endDrag,
                              onReorder: _reorder,
                              onOpen: _open,
                            ),
                            const SizedBox(height: 42),
                            MiniProgramLauncherSectionHeader(
                              title: '常用的小程序',
                              trailing: '我的小程序',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.mine,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MiniProgramLauncherGrid(
                              items: commonItems,
                              listKind: MiniProgramListKind.mine,
                              onDragStarted: _startDrag,
                              onDragEnded: _endDrag,
                              onReorder: _reorder,
                              onOpen: _open,
                            ),
                            if (commonItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  AppLocalizations.of(context).text(
                                    '长按小程序，拖到底部添加为我的小程序',
                                    'Long-press a mini-program and drag it below to add it here.',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: _dragData != null
              ? SafeArea(
                  top: false,
                  child: MiniProgramDragActions(
                    data: _dragData!,
                    alreadyInMy: _library.containsMy(_dragData!.item.id),
                    onAddToMy: _addToMy,
                    onDelete: _delete,
                  ),
                )
              : SafeArea(
                  top: false,
                  child: MiniProgramLauncherSwipeExitHandle(
                    onDragStart: widget.onCloseDragStart,
                    onDragUpdate: widget.onCloseDragUpdate,
                    onDragEnd: widget.onCloseDragEnd,
                    onDragCancel: widget.onCloseDragCancel,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MiniProgramLauncherBottomBar(
                          onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                          onMore: () => _pickerToast(context, '更多为模拟入口'),
                        ),
                        Container(
                          height: 18,
                          color: scheme.surfaceContainer,
                          alignment: Alignment.center,
                          child: Container(
                            width: 110,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  static void _pickerToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      );
  }
}
