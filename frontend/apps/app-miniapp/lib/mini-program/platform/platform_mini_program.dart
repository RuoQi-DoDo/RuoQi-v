import 'package:flutter/material.dart';

import '../mini_program_shell.dart';
import 'pages/platform_account_home_page.dart';
import 'platform_models.dart';
import 'platform_style.dart';

/// 平台账号中心小程序。
///
/// 将原独立平台 App 中分散的个人中心、账号安全、绑定流程、
/// 第三方关联、设备与日志页面收敛为业务 App 内的独立小程序。
class PlatformMiniProgram extends StatefulWidget {
  const PlatformMiniProgram({super.key});

  static Route<void> route() {
    return MiniProgramShell.route(
      title: '平台管理',
      icon: Icons.admin_panel_settings_outlined,
      child: const PlatformMiniProgram(),
    );
  }

  @override
  State<PlatformMiniProgram> createState() => _PlatformMiniProgramState();
}

class _PlatformMiniProgramState extends State<PlatformMiniProgram> {
  late final PlatformAccountController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlatformAccountController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PlatformStyle.pageBackground(context),
      child: PlatformAccountHomePage(
        key: const Key('platform-mini-program'),
        controller: _controller,
      ),
    );
  }
}
