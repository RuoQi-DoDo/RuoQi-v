import 'dart:async';

import 'package:common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppOrientation { system, portrait, landscape }

/// 业务端强调色选项，与 `platform-pc` 的主题页保持同一套色板。
class AccentChoice {
  const AccentChoice(this.label, this.color);

  final String label;
  final Color color;
}

/// 默认强调色：青色。
const Color defaultAccentColor = Color(0xFF0D9488);

/// 字体缩放范围。80% 对齐微信“标准”字号，并在其下保留一档。
const double minFontScale = 0.75;
const double maxFontScale = 1.2;
const double defaultFontScale = 0.8;

const accentChoices = <AccentChoice>[
  AccentChoice('绿色', Color(0xFF16A34A)),
  AccentChoice('青色', defaultAccentColor),
  AccentChoice('蓝色', Color(0xFF2563EB)),
  AccentChoice('靛蓝', Color(0xFF4F46E5)),
  AccentChoice('紫色', Color(0xFF9333EA)),
  AccentChoice('琥珀', Color(0xFFD97706)),
  AccentChoice('橙色', Color(0xFFEA580C)),
  AccentChoice('红色', Color(0xFFDC2626)),
  AccentChoice('玫红', ruoQiBrandColor),
];

/// 背景模式选项，与共享 `RuQiThemeModeSwitch` 一致。
class BackgroundChoice {
  const BackgroundChoice(this.label, this.icon, this.mode);

  final String label;
  final IconData icon;
  final ThemeMode mode;
}

const backgroundChoices = <BackgroundChoice>[
  BackgroundChoice('跟随系统', Icons.desktop_windows_outlined, ThemeMode.system),
  BackgroundChoice('亮色', Icons.light_mode_outlined, ThemeMode.light),
  BackgroundChoice('暗色', Icons.dark_mode_outlined, ThemeMode.dark),
];

const businessThemeModePreferenceKey = 'ruoqi.business.theme_mode';

/// Persistence boundary for the app-wide appearance mode.
abstract interface class BusinessThemeStore {
  Future<ThemeMode?> readMode();

  Future<void> writeMode(ThemeMode mode);
}

class SharedPreferencesBusinessThemeStore implements BusinessThemeStore {
  const SharedPreferencesBusinessThemeStore();

  @override
  Future<ThemeMode?> readMode() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(businessThemeModePreferenceKey);
    for (final mode in ThemeMode.values) {
      if (mode.name == value) {
        return mode;
      }
    }
    return null;
  }

  @override
  Future<void> writeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(businessThemeModePreferenceKey, mode.name);
  }
}

/// App-wide theme selection shared by the host and pushed settings pages.
class BusinessThemeController extends ChangeNotifier {
  BusinessThemeController({this.themeStore});

  final BusinessThemeStore? themeStore;
  Future<void>? _initialization;
  ThemeMode _mode = ThemeMode.light;
  Locale? _locale;
  double _fontScale = defaultFontScale;
  AppOrientation _orientation = AppOrientation.system;

  Future<void> initialize() {
    return _initialization ??= _restoreMode();
  }

  ThemeMode get mode => _mode;
  Locale? get locale => _locale;
  double get fontScale => _fontScale;
  AppOrientation get orientation => _orientation;

  Future<void> _restoreMode() async {
    final store = themeStore;
    if (store == null) {
      return;
    }
    try {
      final restored = await store.readMode();
      if (restored == null || restored == _mode) {
        return;
      }
      _mode = restored;
      notifyListeners();
    } catch (_) {
      // A storage failure should not prevent the app from starting.
    }
  }

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setFontScale(double scale) {
    final next = scale.clamp(minFontScale, maxFontScale);
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  Future<void> setOrientation(AppOrientation orientation) async {
    if (_orientation == orientation) return;
    await SystemChrome.setPreferredOrientations(switch (orientation) {
      AppOrientation.system => const <DeviceOrientation>[],
      AppOrientation.portrait => const [DeviceOrientation.portraitUp],
      AppOrientation.landscape => const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    });
    _orientation = orientation;
    notifyListeners();
  }

  bool get isDarkMode => _mode == ThemeMode.dark;

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
    final store = themeStore;
    if (store == null) {
      return;
    }
    try {
      await store.writeMode(mode);
    } catch (_) {
      // Keep the in-memory selection active if persistence fails.
    }
  }

  Future<void> setDarkMode(bool enabled) {
    return setMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}

class BusinessThemeScope extends InheritedNotifier<BusinessThemeController> {
  const BusinessThemeScope({
    super.key,
    required BusinessThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static BusinessThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BusinessThemeScope>();
    assert(scope != null, 'BusinessThemeScope is missing above this context.');
    return scope!.notifier!;
  }
}
