import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'miniapp_launcher_defaults.dart';
import 'miniapp_launcher_item.dart';

enum MiniProgramListKind { recent, mine }

/// Session-owned launcher lists. Removing an entry changes only that list;
/// opening it again can restore it to recent without changing My mini-programs.
class MiniProgramLibraryController extends ChangeNotifier {
  MiniProgramLibraryController({
    List<MiniProgramLauncherItem>? recentItems,
    List<MiniProgramLauncherItem>? myItems,
  }) : _recentItems = _unique(
         recentItems ?? defaultRecentMiniPrograms,
       ).map(_withoutTileKey).toList(),
       _myItems = _unique(myItems ?? defaultMyMiniPrograms).map(_asMy).toList();

  final List<MiniProgramLauncherItem> _recentItems;
  final List<MiniProgramLauncherItem> _myItems;

  List<MiniProgramLauncherItem> get recentItems =>
      List.unmodifiable(_recentItems);

  List<MiniProgramLauncherItem> get myItems => List.unmodifiable(_myItems);

  bool containsMy(String id) => _myItems.any((item) => item.id == id);

  void recordOpen(MiniProgramLauncherItem item) {
    final index = _recentItems.indexWhere((entry) => entry.id == item.id);
    if (index == 0 && _sameEntry(_recentItems.first, item)) return;
    if (index != -1) _recentItems.removeAt(index);
    _recentItems.insert(0, _withoutTileKey(item));
    notifyListeners();
  }

  bool addToMy(MiniProgramLauncherItem item) {
    if (containsMy(item.id)) return false;
    _myItems.add(_asMy(item));
    notifyListeners();
    return true;
  }

  void removeRecent(String id) => _remove(_recentItems, id);

  void removeFromMy(String id) => _remove(_myItems, id);

  void _remove(List<MiniProgramLauncherItem> items, String id) {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    items.removeAt(index);
    notifyListeners();
  }

  /// Moves the dragged item to the target's original position in its own list.
  void reorder(MiniProgramListKind kind, String draggedId, String targetId) {
    if (draggedId == targetId) return;
    final items = kind == MiniProgramListKind.recent ? _recentItems : _myItems;
    final from = items.indexWhere((item) => item.id == draggedId);
    final to = items.indexWhere((item) => item.id == targetId);
    if (from == -1 || to == -1) return;
    items.insert(to, items.removeAt(from));
    notifyListeners();
  }

  static Iterable<MiniProgramLauncherItem> _unique(
    Iterable<MiniProgramLauncherItem> items,
  ) sync* {
    final ids = <String>{};
    for (final item in items) {
      if (ids.add(item.id)) yield item;
    }
  }

  static MiniProgramLauncherItem _withoutTileKey(
    MiniProgramLauncherItem item,
  ) => MiniProgramLauncherItem(
    id: item.id,
    label: item.label,
    icon: item.icon,
    color: item.color,
    assetPath: item.assetPath,
    searchTerms: List.unmodifiable(item.searchTerms),
  );

  static MiniProgramLauncherItem _asMy(MiniProgramLauncherItem item) =>
      MiniProgramLauncherItem(
        id: item.id,
        label: item.label,
        icon: item.icon,
        color: item.color,
        assetPath: item.assetPath,
        tileKey: switch (item.id) {
          MiniProgramLauncherIds.tospino ||
          MiniProgramLauncherIds.ats ||
          MiniProgramLauncherIds.hr ||
          MiniProgramLauncherIds.merchant ||
          MiniProgramLauncherIds.partner ||
          MiniProgramLauncherIds.platform => ValueKey(
            'mini-program-picker-${item.id}',
          ),
          _ => item.tileKey,
        },
        searchTerms: List.unmodifiable(item.searchTerms),
      );

  static bool _sameEntry(
    MiniProgramLauncherItem left,
    MiniProgramLauncherItem right,
  ) =>
      left.id == right.id &&
      left.label == right.label &&
      left.icon == right.icon &&
      left.color == right.color &&
      left.assetPath == right.assetPath &&
      listEquals(left.searchTerms, right.searchTerms);
}

class MiniProgramLibraryScope
    extends InheritedNotifier<MiniProgramLibraryController> {
  const MiniProgramLibraryScope({
    super.key,
    required MiniProgramLibraryController controller,
    required super.child,
  }) : super(notifier: controller);

  static MiniProgramLibraryController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MiniProgramLibraryScope>()
      ?.notifier;
}
