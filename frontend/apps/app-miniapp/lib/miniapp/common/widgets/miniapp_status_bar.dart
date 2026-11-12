import 'package:flutter/material.dart';

/// 小程序统一状态栏背景。
///
/// 真机使用系统状态栏占位；无系统安全区的预览环境会渲染一条轻量模拟
/// 状态栏，便于业务小程序保持一致的顶部结构。
class MiniProgramStatusBar extends StatelessWidget {
  const MiniProgramStatusBar({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    this.fallbackHeight = 28,
    this.fontSize = 12,
    this.iconSize = 14,
    this.iconGap = 5,
    this.horizontalPadding = 16,
    this.verticalPadding = 5,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final double fallbackHeight;
  final double fontSize;
  final double iconSize;
  final double iconGap;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final systemTop = MediaQuery.paddingOf(context).top;
    if (systemTop > 0) {
      return ColoredBox(
        color: backgroundColor,
        child: SizedBox(height: systemTop),
      );
    }
    return Container(
      color: backgroundColor,
      height: fallbackHeight,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: foregroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.signal_cellular_alt,
            color: foregroundColor,
            size: iconSize,
          ),
          SizedBox(width: iconGap),
          Icon(Icons.wifi_rounded, color: foregroundColor, size: iconSize),
          SizedBox(width: iconGap),
          Icon(
            Icons.battery_full_rounded,
            color: foregroundColor,
            size: iconSize,
          ),
        ],
      ),
    );
  }
}
