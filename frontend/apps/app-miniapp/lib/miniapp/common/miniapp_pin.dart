import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const miniProgramPinnedIdPreferenceKey = 'ruoqi.mini_program.pinned_id';

/// Persistence boundary for the single pinned mini-program.
abstract interface class MiniProgramPinStore {
  Future<String?> readPinnedId();

  Future<void> writePinnedId(String? id);
}

class SharedPreferencesMiniProgramPinStore implements MiniProgramPinStore {
  const SharedPreferencesMiniProgramPinStore();

  @override
  Future<String?> readPinnedId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(miniProgramPinnedIdPreferenceKey);
  }

  @override
  Future<void> writePinnedId(String? id) async {
    final preferences = await SharedPreferences.getInstance();
    if (id == null) {
      await preferences.remove(miniProgramPinnedIdPreferenceKey);
      return;
    }
    await preferences.setString(miniProgramPinnedIdPreferenceKey, id);
  }
}

/// Owns the one mini-program that should be restored on the next cold start.
class MiniProgramPinController extends ChangeNotifier {
  MiniProgramPinController({MiniProgramPinStore? store})
    : _store = store ?? const SharedPreferencesMiniProgramPinStore();

  final MiniProgramPinStore _store;
  Future<void>? _initialization;
  String? _pinnedId;
  bool _initialized = false;

  String? get pinnedId => _pinnedId;

  bool get isInitialized => _initialized;

  bool isPinned(String id) => _pinnedId == id;

  Future<void> initialize() {
    return _initialization ??= _load();
  }

  Future<void> _load() async {
    try {
      _pinnedId = await _store.readPinnedId();
    } catch (_) {
      // A storage failure should not prevent the business host from starting.
      _pinnedId = null;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> togglePin(String id) {
    if (isPinned(id)) {
      return unpin();
    }
    return pin(id);
  }

  Future<void> pin(String id) async {
    if (id.isEmpty || isPinned(id)) {
      return;
    }
    _pinnedId = id;
    notifyListeners();
    await _persist(id);
  }

  Future<void> unpin() async {
    if (_pinnedId == null) {
      return;
    }
    _pinnedId = null;
    notifyListeners();
    await _persist(null);
  }

  Future<void> _persist(String? id) async {
    try {
      await _store.writePinnedId(id);
    } catch (_) {
      // Keep the in-memory pin active for this session if persistence fails.
    }
  }
}

class MiniProgramPinScope extends InheritedNotifier<MiniProgramPinController> {
  const MiniProgramPinScope({
    super.key,
    required MiniProgramPinController controller,
    required super.child,
  }) : super(notifier: controller);

  static MiniProgramPinController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MiniProgramPinScope>()
        ?.notifier;
  }
}
