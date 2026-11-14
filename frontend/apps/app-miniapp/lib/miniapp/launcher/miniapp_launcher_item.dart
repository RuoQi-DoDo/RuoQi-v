import 'package:flutter/material.dart';

/// 启动器已知小程序标识。
///
/// 启动器负责展示和上报选择，公共目录负责根据标识分发路由。
abstract final class MiniProgramLauncherIds {
  static const tospino = 'tospino';
  static const ats = 'ats';
  static const merchant = 'merchant';
  static const partner = 'partner';
  static const hr = 'hr';
  static const platform = 'platform';
}

const tospinoMiniProgramIconAsset =
    'lib/miniapp/tospino/assets/tospino-app-icon.png';

/// 小程序启动器中的单个入口。
@immutable
class MiniProgramLauncherItem {
  const MiniProgramLauncherItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.assetPath,
    this.tileKey,
    this.searchTerms = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? assetPath;
  final Key? tileKey;
  final List<String> searchTerms;
}

class MiniProgramLauncherIcon extends StatelessWidget {
  const MiniProgramLauncherIcon({
    super.key,
    required this.item,
    required this.size,
  });

  final MiniProgramLauncherItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetPath;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: item.color,
        shape: assetPath == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: assetPath == null
            ? null
            : BorderRadius.circular(size * 0.24),
      ),
      child: assetPath == null
          ? Icon(item.icon, color: Colors.white, size: size * 0.53)
          : Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Icon(item.icon, color: Colors.white, size: size * 0.53),
            ),
    );
  }
}
