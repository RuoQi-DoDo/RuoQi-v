import 'package:flutter/material.dart';

/// 微信式小程序公共胶囊。
///
/// 胶囊固定在小程序导航栏右上角，所有业务小程序复用同一布局、尺寸和交互。
/// 使用半透明白色底，保证图标在图片和彩色背景上都能保持可读。
class MiniProgramCapsule extends StatelessWidget {
  const MiniProgramCapsule({
    super.key,
    required this.onMore,
    required this.onClose,
  });

  static const double width = 94;
  static const double height = 32;
  static const Color surfaceColor = Color(0x99FFFFFF);
  static const Color borderColor = Color(0x1A000000);
  static const Color foregroundColor = Color(0xFF111111);

  final VoidCallback onMore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: const BorderSide(color: borderColor, width: 0.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                child: _MiniProgramCapsuleAction(
                  tooltip: '小程序菜单',
                  onTap: onMore,
                  child: const _MiniProgramMoreIcon(color: foregroundColor),
                ),
              ),
              SizedBox(
                width: 0.6,
                height: 21,
                child: ColoredBox(color: borderColor),
              ),
              Expanded(
                child: _MiniProgramCapsuleAction(
                  tooltip: '退出小程序',
                  onTap: onClose,
                  child: Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: foregroundColor, width: 2.2),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: foregroundColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgramMoreIcon extends StatelessWidget {
  const _MiniProgramMoreIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 12,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CapsuleDot(size: 2.5, color: color),
            const SizedBox(width: 3.2),
            _CapsuleDot(size: 4.5, color: color),
            const SizedBox(width: 3.2),
            _CapsuleDot(size: 2.5, color: color),
          ],
        ),
      ),
    );
  }
}

class _CapsuleDot extends StatelessWidget {
  const _CapsuleDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MiniProgramCapsuleAction extends StatelessWidget {
  const _MiniProgramCapsuleAction({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
