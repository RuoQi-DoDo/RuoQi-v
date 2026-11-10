import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'appearance.dart';

/// 业务应用共享外壳，不依赖业务组注册表。
class BusinessAppFrame extends StatefulWidget {
  const BusinessAppFrame({super.key, required this.title, required this.home});

  final String title;
  final WidgetBuilder home;

  @override
  State<BusinessAppFrame> createState() => _BusinessAppFrameState();
}

class _BusinessAppFrameState extends State<BusinessAppFrame> {
  final BusinessThemeController _themeController = BusinessThemeController();

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
              title: widget.title,
              debugShowCheckedModeBanner: false,
              builder: ruoQiSelectionBuilder,
              theme: ruoQiTheme(accent: defaultAccentColor),
              darkTheme: ruoQiTheme(
                brightness: Brightness.dark,
                accent: defaultAccentColor,
              ),
              themeMode: _themeController.mode,
              home: Builder(builder: widget.home),
            ),
          );
        },
      ),
    );
  }
}

void runBusinessApp({required String title, required WidgetBuilder home}) {
  runApp(BusinessAppFrame(title: title, home: home));
}
