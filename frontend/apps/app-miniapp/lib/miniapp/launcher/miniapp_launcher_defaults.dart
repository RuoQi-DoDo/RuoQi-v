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
];
