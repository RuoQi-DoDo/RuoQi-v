import 'package:common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'appearance.dart';
import 'localization.dart';
import 'pages/account/account.dart';

/// Web 打包时启用全站文案选择，移动端 App 保持原生手势行为。
TransitionBuilder? platformSelectionBuilder({bool isWeb = kIsWeb}) {
  return isWeb ? ruoQiSelectionBuilder : null;
}

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
  final AccountController _accountController = AccountController();

  @override
  void dispose() {
    _themeController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BusinessThemeScope(
      controller: _themeController,
      child: AccountScope(
        controller: _accountController,
        child: ListenableBuilder(
          listenable: _themeController,
          builder: (context, child) {
            return RuoQiPlatformScope(
              platform: RuoQiPlatform.mobile,
              child: MaterialApp(
                title: widget.title,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  final media = MediaQuery.of(context);
                  Widget content = MediaQuery(
                    data: media.copyWith(
                      textScaler: _PreferenceTextScaler(
                        media.textScaler,
                        _themeController.fontScale,
                      ),
                    ),
                    child: child!,
                  );
                  final selectionBuilder = platformSelectionBuilder();
                  if (selectionBuilder != null) {
                    content = selectionBuilder(context, content);
                  }
                  return content;
                },
                locale: _themeController.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
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
      ),
    );
  }
}

class _PreferenceTextScaler extends TextScaler {
  const _PreferenceTextScaler(this.system, this.factor);

  final TextScaler system;
  final double factor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _PreferenceTextScaler &&
      other.system == system &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);
}

void runBusinessApp({required String title, required WidgetBuilder home}) {
  runApp(BusinessAppFrame(title: title, home: home));
}
