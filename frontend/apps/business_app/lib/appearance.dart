import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// 业务端强调色选项，与 `platform_pc` 的主题页保持同一套色板。
class AccentChoice {
  const AccentChoice(this.label, this.color);

  final String label;
  final Color color;
}

/// 默认强调色：青色。
const Color defaultAccentColor = Color(0xFF0D9488);

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

/// App-wide theme selection shared by the host and pushed settings pages.
class BusinessThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDarkMode => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  void setDarkMode(bool enabled) {
    setMode(enabled ? ThemeMode.dark : ThemeMode.light);
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
