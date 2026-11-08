import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'appearance.dart';
import 'pages/customer_home_page.dart';

void main() {
  runApp(const BusinessApp());
}

/// 业务端（App）：默认进入客户宿主首页。
///
/// 企业直聘、商户和伙伴均以小程序子页面运行。
class BusinessApp extends StatelessWidget {
  const BusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.mobile,
      child: MaterialApp(
        title: 'RuoQi 业务端 App',
        debugShowCheckedModeBanner: false,
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(accent: defaultAccentColor),
        darkTheme: ruoQiTheme(
          brightness: Brightness.dark,
          accent: defaultAccentColor,
        ),
        themeMode: ThemeMode.light,
        home: const CustomerHomePage(),
      ),
    );
  }
}
