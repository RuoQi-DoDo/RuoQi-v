import 'package:material_ui/material_ui.dart';

import '../../localization.dart';
import '../ats/ats_miniapp.dart';
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
    assetPath: tospinoMiniProgramIconAsset,
    searchTerms: ['Tospino', 'Mall', 'Shopping', '商城', '购物', '电商'],
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
    _ => null,
  };
  if (route == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .text('该小程序暂不可用', 'This mini-program is currently unavailable'),
        ),
      ),
    );
    return;
  }
  MiniProgramLibraryScope.maybeOf(context)?.recordOpen(item);
  await Navigator.of(context).push<void>(route);
}
