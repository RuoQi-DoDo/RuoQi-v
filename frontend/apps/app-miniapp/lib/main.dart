import 'package:material_ui/material_ui.dart';

import 'app_shell.dart';
import 'appearance.dart';
import 'miniapp/common/miniapp_pin.dart';
import 'pages/auth/business_session.dart';
import 'pages/host/business_host_page.dart';
import 'pages/im/im_chat_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final miniProgramPinController = MiniProgramPinController();
  await miniProgramPinController.initialize();
  final themeController = BusinessThemeController(
    themeStore: const SharedPreferencesBusinessThemeStore(),
  );
  await themeController.initialize();
  runApp(
    BusinessApp(
      miniProgramPinController: miniProgramPinController,
      themeController: themeController,
    ),
  );
}

/// Default business home; replace this builder to launch another business.
Widget buildImChatPage(
  BuildContext context,
  ScrollController scrollController,
) => ImChatPage(scrollController: scrollController);

/// App composition: shared host navigation with a replaceable business home.
class BusinessApp extends StatefulWidget {
  const BusinessApp({
    super.key,
    this.title = 'RuoQi',
    this.homeBuilder = buildImChatPage,
    this.homeLabel = '聊天',
    this.homeIcon = Icons.chat_bubble_outline_rounded,
    this.homeActiveIcon = Icons.chat_bubble_rounded,
    this.loginBuilder,
    this.onLogout,
    this.miniProgramPinController,
    this.themeController,
    this.initiallyAuthenticated = true,
    this.sessionStore,
  });

  final String title;
  final BusinessHomeBuilder homeBuilder;
  final String homeLabel;
  final IconData homeIcon;
  final IconData homeActiveIcon;
  final WidgetBuilder? loginBuilder;
  final VoidCallback? onLogout;
  final MiniProgramPinController? miniProgramPinController;
  final BusinessThemeController? themeController;
  final bool initiallyAuthenticated;
  final BusinessSessionStore? sessionStore;

  @override
  State<BusinessApp> createState() => _BusinessAppState();
}

class _BusinessAppState extends State<BusinessApp> {
  Widget _buildHome(BuildContext context) {
    return BusinessHostPage(
      homeBuilder: widget.homeBuilder,
      homeLabel: widget.homeLabel,
      homeIcon: widget.homeIcon,
      homeActiveIcon: widget.homeActiveIcon,
      loginBuilder: widget.loginBuilder,
      onLogout: widget.onLogout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BusinessAppFrame(
      title: widget.title,
      home: _buildHome,
      miniProgramPinController: widget.miniProgramPinController,
      themeController: widget.themeController,
    );
  }
}
