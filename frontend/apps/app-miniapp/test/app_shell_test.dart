import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_theme.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_style.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_style.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_style.dart';

void main() {
  testWidgets('移动端应用字体设置且不启用全局文案选择', (tester) async {
    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.builder, isNotNull);
    expect(find.byType(SelectionArea), findsNothing);
    expect(app.theme!.textTheme.titleLarge?.fontSize, 17);
    expect(app.theme!.textTheme.bodyLarge?.fontSize, 17);
    expect(app.theme!.textTheme.bodyMedium?.fontSize, 15);
    expect(app.theme!.textTheme.bodySmall?.fontSize, 12);
  });

  testWidgets('全局暗色主题使用统一的柔和石墨灰色板', (tester) async {
    final controller = BusinessThemeController();
    addTearDown(controller.dispose);
    await controller.setMode(ThemeMode.dark);

    await tester.pumpWidget(
      BusinessApp(initiallyAuthenticated: true, themeController: controller),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final dark = app.darkTheme!;
    expect(dark.scaffoldBackgroundColor, MiniAppDarkColors.background);
    expect(dark.colorScheme.surface, MiniAppDarkColors.background);
    expect(dark.colorScheme.surfaceContainerLow, MiniAppDarkColors.surface);
    expect(
      dark.colorScheme.surfaceContainerHigh,
      MiniAppDarkColors.surfaceHigh,
    );
    expect(dark.colorScheme.onSurface, MiniAppDarkColors.text);
    expect(dark.colorScheme.onSurfaceVariant, MiniAppDarkColors.muted);
    expect(dark.cardTheme.color, MiniAppDarkColors.surface);
    expect(dark.inputDecorationTheme.fillColor, MiniAppDarkColors.surfaceMuted);
    expect(dark.dividerTheme.color, MiniAppDarkColors.border);
  });

  test('内置小程序暗色主题共享宿主的石墨灰色阶', () {
    final themes = [
      AtsTheme.data(brightness: Brightness.dark),
      HrTheme.data(brightness: Brightness.dark),
      TospinoTheme.data(brightness: Brightness.dark),
    ];
    for (final theme in themes) {
      expect(theme.scaffoldBackgroundColor, MiniAppDarkColors.background);
      expect(theme.colorScheme.surface, MiniAppDarkColors.surface);
      expect(theme.colorScheme.onSurface, MiniAppDarkColors.text);
      expect(theme.colorScheme.outlineVariant, MiniAppDarkColors.border);
    }
  });

  test('只有 Web 使用全局文案选择包装', () {
    expect(platformSelectionBuilder(isWeb: false), isNull);
    expect(platformSelectionBuilder(isWeb: true), isNotNull);
  });
}
