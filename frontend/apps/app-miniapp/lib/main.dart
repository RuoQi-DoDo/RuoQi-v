import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pages/im/im_home_page.dart';

void main() {
  runApp(const BusinessApp());
}

/// 业务小程序宿主：当前唯一主业务为 IM。
class BusinessApp extends StatelessWidget {
  const BusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BusinessAppFrame(title: 'RuoQi IM', home: (_) => const ImHomePage());
  }
}
