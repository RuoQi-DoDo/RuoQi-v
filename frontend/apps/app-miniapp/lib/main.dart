import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'miniapp/common/miniapp_pin.dart';
import 'pages/auth/phone_login_page.dart';
import 'pages/auth/phone_verification_page.dart';
import 'pages/host/business_host_page.dart';
import 'pages/im/im_chat_page.dart';
import 'pages/im/im_welcome_page.dart';

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
class BusinessApp extends StatefulWidget {
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
    this.initiallyAuthenticated = false,
  });

  final String title;
  final BusinessHomeBuilder homeBuilder;
  final String homeLabel;
  final IconData homeIcon;
  final IconData homeActiveIcon;
  final WidgetBuilder? loginBuilder;
  final VoidCallback? onLogout;
  final MiniProgramPinController? miniProgramPinController;
  final bool initiallyAuthenticated;

  @override
  State<BusinessApp> createState() => _BusinessAppState();
}

class _BusinessAppState extends State<BusinessApp> {
  late bool _authenticated;
  late bool _welcomeCompleted;
  String? _pendingPhoneNumber;

  @override
  void initState() {
    super.initState();
    _authenticated = widget.initiallyAuthenticated;
    _welcomeCompleted = widget.initiallyAuthenticated;
  }

  void _acceptWelcome() {
    setState(() => _welcomeCompleted = true);
  }

  void _completeLogin() {
    setState(() {
      _authenticated = true;
      _pendingPhoneNumber = null;
    });
  }

  void _requestPhoneVerification(String phoneNumber) {
    setState(() => _pendingPhoneNumber = phoneNumber);
  }

  void _returnToPhoneEntry() {
    setState(() => _pendingPhoneNumber = null);
  }

  Widget _buildHome(BuildContext context) {
    if (!_authenticated) {
      if (!_welcomeCompleted) {
        return ImWelcomePage(
          scrollController: null,
          onContinue: _acceptWelcome,
        );
      }
      final phoneNumber = _pendingPhoneNumber;
      if (phoneNumber == null) {
        return PhoneLoginPage(onRequestVerification: _requestPhoneVerification);
      }
      return PhoneVerificationPage(
        phoneNumber: phoneNumber,
        onVerified: _completeLogin,
        onBack: _returnToPhoneEntry,
      );
    }
    return BusinessHostPage(
      homeBuilder: widget.homeBuilder,
      homeLabel: widget.homeLabel,
      homeIcon: widget.homeIcon,
      homeActiveIcon: widget.homeActiveIcon,
      loginBuilder: widget.loginBuilder,
      onLogout: () {
        widget.onLogout?.call();
        Navigator.of(context).popUntil((route) => route.isFirst);
        setState(() {
          _authenticated = false;
          _welcomeCompleted = true;
          _pendingPhoneNumber = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BusinessAppFrame(
      title: widget.title,
      home: _buildHome,
      miniProgramPinController: widget.miniProgramPinController,
    );
  }
}
