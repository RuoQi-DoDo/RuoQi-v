import 'package:flutter/material.dart';

/// 启动器已知小程序标识。
///
/// 启动器本身只负责展示和上报选择，具体路由由宿主根据标识决定。
abstract final class MiniProgramLauncherIds {
  static const ats = 'ats';
  static const merchant = 'merchant';
  static const partner = 'partner';
  static const hr = 'hr';
  static const platform = 'platform';
}

/// 小程序启动器中的单个入口。
@immutable
class MiniProgramLauncherItem {
  const MiniProgramLauncherItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.tileKey,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final Key? tileKey;
}
