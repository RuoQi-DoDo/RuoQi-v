import 'package:material_ui/material_ui.dart';

import 'miniapp_launcher_item.dart';

/// Initial demo entries used until the account provides its launcher library.
const defaultRecentMiniPrograms = <MiniProgramLauncherItem>[
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.tospino,
    label: 'Tospino',
    icon: Icons.storefront_rounded,
    color: Color(0xFF42B7AE),
    assetPath: tospinoMiniProgramIconAsset,
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.ats,
    label: '企业直聘',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF0D9488),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.hr,
    label: '人事',
    icon: Icons.badge_outlined,
    color: Color(0xFFC43D28),
  ),
];

const defaultMyMiniPrograms = <MiniProgramLauncherItem>[
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.tospino,
    label: 'Tospino',
    icon: Icons.storefront_rounded,
    color: Color(0xFF42B7AE),
    assetPath: tospinoMiniProgramIconAsset,
    tileKey: Key('mini-program-picker-tospino'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.ats,
    label: '企业直聘',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF0D9488),
    tileKey: Key('mini-program-picker-ats'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.hr,
    label: '人事',
    icon: Icons.badge_outlined,
    color: Color(0xFFC43D28),
    tileKey: Key('mini-program-picker-hr'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.merchant,
    label: '商户',
    icon: Icons.fingerprint,
    color: Color(0xFF3B82F6),
    tileKey: Key('mini-program-picker-merchant'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.platform,
    label: '平台管理',
    icon: Icons.admin_panel_settings_outlined,
    color: Color(0xFF0D9488),
    tileKey: Key('mini-program-picker-platform'),
  ),
];
