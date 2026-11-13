import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'miniapp/common/miniapp_pin.dart';
import 'pages/host/business_host_page.dart';
import 'pages/im/im_chat_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final miniProgramPinController = MiniProgramPinController();
  await miniProgramPinController.initialize();
  runApp(BusinessApp(miniProgramPinController: miniProgramPinController));
}

/// Default business home; replace this builder to launch another business.
Widget buildImChatPage(
  BuildContext context,
  ScrollController scrollController,
) => ImChatPage(scrollController: scrollController);

/// App composition: shared host navigation with a replaceable business home.
class BusinessApp extends StatelessWidget {
  const BusinessApp({
    super.key,
    this.title = 'RuoQi',
    this.homeBuilder = buildImChatPage,
    this.homeLabel = 'RuoQi',
    this.homeIcon = Icons.chat_bubble_outline_rounded,
    this.homeActiveIcon = Icons.chat_bubble_rounded,
    this.loginBuilder,
    this.onLogout,
    this.miniProgramPinController,
  });

  final String title;
  final BusinessHomeBuilder homeBuilder;
  final String homeLabel;
  final IconData homeIcon;
  final IconData homeActiveIcon;
  final WidgetBuilder? loginBuilder;
  final VoidCallback? onLogout;
  final MiniProgramPinController? miniProgramPinController;

  @override
  Widget build(BuildContext context) {
    return BusinessAppFrame(
      title: title,
      home: (_) => BusinessHostPage(
        homeBuilder: homeBuilder,
        homeLabel: homeLabel,
        homeIcon: homeIcon,
        homeActiveIcon: homeActiveIcon,
        loginBuilder: loginBuilder,
        onLogout: onLogout,
      ),
      miniProgramPinController: miniProgramPinController,
    );
  }
}
