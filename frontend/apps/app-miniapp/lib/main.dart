import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'appearance.dart';
import 'pages/group.dart';
import 'pages/group_config.dart';
import 'pages/group_registry.dart';

void main() {
  runApp(const BusinessApp());
}

/// 业务端（App）：根据 Web 入口配置选择业务组的 home 作为 App 主页面。
///
/// `im` 业务组作为宿主持有小程序选择页；其他业务组也可以直接作为 home 启动。
class BusinessApp extends StatefulWidget {
  const BusinessApp({super.key, this.businessGroup});

  /// 测试或原生启动时可显式指定；为空时读取 `index.html` / dart-define 配置。
  final BusinessGroup? businessGroup;

  @override
  State<BusinessApp> createState() => _BusinessAppState();
}

class _BusinessAppState extends State<BusinessApp> {
  final BusinessThemeController _themeController = BusinessThemeController();
  late final BusinessGroupDefinition _businessGroup;

  @override
  void initState() {
    super.initState();
    _businessGroup = definitionFor(
      widget.businessGroup ?? resolveConfiguredBusinessGroup(),
    );
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BusinessThemeScope(
      controller: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, child) {
          return RuoQiPlatformScope(
            platform: RuoQiPlatform.mobile,
            child: MaterialApp(
              title: 'RuoQi ${_businessGroup.title}',
              debugShowCheckedModeBanner: false,
              builder: ruoQiSelectionBuilder,
              theme: ruoQiTheme(accent: defaultAccentColor),
              darkTheme: ruoQiTheme(
                brightness: Brightness.dark,
                accent: defaultAccentColor,
              ),
              themeMode: _themeController.mode,
              home: Builder(builder: _businessGroup.home),
            ),
          );
        },
      ),
    );
  }
}
