import 'package:flutter/material.dart';

/// 管理类控制台右侧内容区统一使用紧凑字号。
///
/// 只覆盖内容区的 [TextTheme]，顶部导航、左侧菜单和其他控制台外壳保持原样。
class ConsoleContentTheme extends StatelessWidget {
  const ConsoleContentTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(textTheme: compactConsoleTextTheme(theme.textTheme)),
      child: child,
    );
  }
}

TextTheme compactConsoleTextTheme(TextTheme base) {
  return base.copyWith(
    headlineSmall: base.headlineSmall?.copyWith(fontSize: 17),
    titleLarge: base.titleLarge?.copyWith(fontSize: 15),
    titleMedium: base.titleMedium?.copyWith(fontSize: 14),
    titleSmall: base.titleSmall?.copyWith(fontSize: 13),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 14),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 13),
    bodySmall: base.bodySmall?.copyWith(fontSize: 11),
    labelLarge: base.labelLarge?.copyWith(fontSize: 13),
    labelMedium: base.labelMedium?.copyWith(fontSize: 11),
    labelSmall: base.labelSmall?.copyWith(fontSize: 12),
  );
}
