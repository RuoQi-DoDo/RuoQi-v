import 'package:flutter/material.dart';

import '../mini-program/ats/ats_mini_program.dart';
import '../mini-program/hr/hr_mini_program.dart';
import '../mini-program/merchant/home_page.dart';
import '../mini-program/partner/home_page.dart';
import '../mini-program/platform/platform_mini_program.dart';
import 'group.dart';
import 'im/im_home_page.dart';

class BusinessGroupDefinition {
  const BusinessGroupDefinition({
    required this.group,
    required this.title,
    required this.icon,
    required this.home,
    required this.hostsMiniPrograms,
  });

  final BusinessGroup group;
  final String title;
  final IconData icon;
  final WidgetBuilder home;
  final bool hostsMiniPrograms;
}

BusinessGroupDefinition definitionFor(BusinessGroup group) {
  return switch (group) {
    BusinessGroup.im => BusinessGroupDefinition(
      group: group,
      title: 'IM',
      icon: Icons.chat_bubble_outline_rounded,
      home: (_) => const ImHomePage(),
      hostsMiniPrograms: true,
    ),
    BusinessGroup.ats => BusinessGroupDefinition(
      group: group,
      title: '企业直聘',
      icon: Icons.work_outline_rounded,
      home: (_) => const AtsMiniProgram(),
      hostsMiniPrograms: false,
    ),
    BusinessGroup.hr => BusinessGroupDefinition(
      group: group,
      title: '人事',
      icon: Icons.badge_outlined,
      home: (_) => const HrMiniProgram(),
      hostsMiniPrograms: false,
    ),
    BusinessGroup.merchant => BusinessGroupDefinition(
      group: group,
      title: '商户',
      icon: Icons.fingerprint,
      home: (_) => const MerchantHomePage(),
      hostsMiniPrograms: false,
    ),
    BusinessGroup.partner => BusinessGroupDefinition(
      group: group,
      title: '伙伴',
      icon: Icons.handshake_outlined,
      home: (_) => const PartnerHomePage(),
      hostsMiniPrograms: false,
    ),
    BusinessGroup.platform => BusinessGroupDefinition(
      group: group,
      title: '平台管理',
      icon: Icons.admin_panel_settings_outlined,
      home: (_) => const _PlatformBusinessGroupHome(),
      hostsMiniPrograms: false,
    ),
  };
}

class _PlatformBusinessGroupHome extends StatelessWidget {
  const _PlatformBusinessGroupHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('平台管理')),
      body: const SafeArea(top: false, child: PlatformMiniProgram()),
    );
  }
}
