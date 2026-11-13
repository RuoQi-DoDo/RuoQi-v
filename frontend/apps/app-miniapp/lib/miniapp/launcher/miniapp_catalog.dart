import 'package:flutter/material.dart';

import '../../localization.dart';
import '../ats/ats_miniapp.dart';
import '../common/miniapp_shell.dart';
import '../hr/hr_miniapp.dart';
import '../merchant/home_page.dart';
import '../partner/home_page.dart';
import '../platform/platform_miniapp.dart';
import '../tospino/tospino_miniapp.dart';
import 'miniapp_launcher_item.dart';
import 'miniapp_library_controller.dart';

/// Implemented mini-programs that can be launched from any shared page.
const List<MiniProgramLauncherItem> availableMiniPrograms = [
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.tospino,
    label: 'Tospino',
    icon: Icons.storefront_rounded,
    color: Color(0xFF42B7AE),
    searchTerms: ['Tospino', 'Mall', 'Shopping', '商城', '购物', '电商'],
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.ats,
    label: '企业直聘',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF12AE85),
    searchTerms: ['Recruitment', 'Jobs', 'ATS', '招聘', '求职'],
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.hr,
    label: '人事',
    icon: Icons.badge_outlined,
    color: Color(0xFFC43D28),
    searchTerms: ['HR', 'attendance', '人事', '考勤', '员工'],
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.merchant,
    label: '商户',
    icon: Icons.fingerprint,
    color: Color(0xFF3B82F6),
    searchTerms: ['Merchant', '商家', '商户'],
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.partner,
    label: '伙伴',
    icon: Icons.handshake_outlined,
    color: Color(0xFF8B5CF6),
    searchTerms: ['Partner', '伙伴', '合作伙伴'],
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.platform,
    label: '平台管理',
    icon: Icons.admin_panel_settings_outlined,
    color: Color(0xFF0D9488),
    searchTerms: ['Platform', 'Admin', '平台', '账号'],
  ),
];

/// Opens one mini-program route and returns when that mini-program exits.
Future<void> openMiniProgram(
  BuildContext context,
  MiniProgramLauncherItem item,
) async {
  final route = switch (item.id) {
    MiniProgramLauncherIds.tospino => TospinoMiniProgram.route(),
    MiniProgramLauncherIds.ats => AtsMiniProgram.route(),
    MiniProgramLauncherIds.hr => HrMiniProgram.route(),
    MiniProgramLauncherIds.merchant => MiniProgramShell.route(
      title: '商户',
      miniProgramId: item.id,
      icon: Icons.fingerprint,
      child: const MerchantHomePage(embedded: true),
    ),
    MiniProgramLauncherIds.partner => MiniProgramShell.route(
      title: '伙伴',
      miniProgramId: item.id,
      icon: Icons.handshake_outlined,
      child: const PartnerHomePage(embedded: true),
    ),
    MiniProgramLauncherIds.platform => PlatformMiniProgram.route(),
    _ => null,
  };
  if (route == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          ).text('该小程序暂不可用', 'This mini-program is currently unavailable'),
        ),
      ),
    );
    return;
  }
  MiniProgramLibraryScope.maybeOf(context)?.recordOpen(item);
  await Navigator.of(context).push<void>(route);
}
