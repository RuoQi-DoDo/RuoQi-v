import '../miniapp_localizations.dart';
import '../../../pages/display/display_settings_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 微信小程序右上角三点操作面板。
///
/// 交互和分组参考微信真机：顶部为当前小程序，随后是转发联系人、
/// 两行功能入口和底部取消按钮。
const _miniProgramSheetColor = Color(0xFF1E1E1E);
const _miniProgramHeaderColor = Color(0xFF191919);
const _miniProgramTileColor = Color(0xFF292929);
const _miniProgramDividerColor = Color(0xFF2D2D2D);
const _miniProgramPrimaryText = Color(0xFFFFFFFF);
const _miniProgramSecondaryText = Color(0xFF8F8F8F);
const _miniProgramDisabledText = Color(0xFF5C5C5C);
const _miniProgramCancelText = Color(0xFF708AA6);

Future<void> showMiniProgramActionsSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  String subtitle = '微信小程序',
  VoidCallback? onRestart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    isScrollControlled: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height;
      return SizedBox(
        height: height * 0.679,
        child: _MiniProgramActionsSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          onRestart: onRestart,
        ),
      );
    },
  );
}

class _MiniProgramActionsSheet extends StatefulWidget {
  const _MiniProgramActionsSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onRestart,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRestart;

  @override
  State<_MiniProgramActionsSheet> createState() =>
      _MiniProgramActionsSheetState();
}

class _MiniProgramActionsSheetState extends State<_MiniProgramActionsSheet> {
  bool _starred = false;
  bool _favorited = false;
  bool _added = false;

  void _close() => Navigator.of(context).pop();

  void _showFeedback(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    _close();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(
      ClipboardData(text: 'https://miniapp.weixin.qq.com/${widget.title}'),
    );
    if (!mounted) {
      return;
    }
    _showFeedback(localizeMiniProgramLabel(context, '链接已复制'));
  }

  void _showSettings() {
    final navigator = Navigator.of(context);
    _close();
    navigator.push<void>(
      MaterialPageRoute<void>(builder: (_) => const DisplaySettingsPage()),
    );
  }

  void _restart() {
    _close();
    widget.onRestart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <_MiniProgramActionData>[
      _MiniProgramActionData(
        label: '转发给朋友',
        icon: Icons.turn_right_rounded,
        color: const Color(0xFF07C160),
        onTap: () =>
            _showFeedback(localizeMiniProgramLabel(context, '已打开转发面板')),
      ),
      const _MiniProgramActionData(
        label: '分享到朋友圈',
        icon: Icons.camera_alt_outlined,
        color: Color(0xFFB7B7B7),
        enabled: false,
      ),
      _MiniProgramActionData(
        label: _starred ? '取消星标' : '星标',
        icon: _starred ? Icons.star_rounded : Icons.star_border_rounded,
        color: const Color(0xFF3D9BFF),
        onTap: () => setState(() => _starred = !_starred),
      ),
      _MiniProgramActionData(
        label: _favorited ? '已收藏' : '收藏',
        icon: _favorited ? Icons.bookmark_rounded : Icons.widgets_outlined,
        color: const Color(0xFFFFB800),
        onTap: () => setState(() => _favorited = !_favorited),
      ),
      _MiniProgramActionData(
        label: _added ? '已添加' : '添加到\n我的小程序',
        icon: _added ? Icons.check_circle_rounded : Icons.apps_rounded,
        color: const Color(0xFFFFC400),
        onTap: () => setState(() => _added = !_added),
      ),
      _MiniProgramActionData(
        label: '在电脑上\n打开',
        icon: Icons.computer_outlined,
        color: _miniProgramPrimaryText,
        onTap: () =>
            _showFeedback(localizeMiniProgramLabel(context, '已打开电脑端入口')),
      ),
      _MiniProgramActionData(
        label: '浮窗',
        icon: Icons.picture_in_picture_alt_outlined,
        color: _miniProgramPrimaryText,
        onTap: () => _showFeedback(localizeMiniProgramLabel(context, '已开启浮窗')),
      ),
      _MiniProgramActionData(
        label: '设置',
        icon: Icons.settings_outlined,
        color: _miniProgramPrimaryText,
        onTap: _showSettings,
      ),
      _MiniProgramActionData(
        label: '反馈与投诉',
        icon: Icons.report_problem_outlined,
        color: _miniProgramPrimaryText,
        onTap: () =>
            _showFeedback(localizeMiniProgramLabel(context, '已打开反馈入口')),
      ),
      _MiniProgramActionData(
        label: '重新进入\n小程序',
        icon: Icons.restart_alt_rounded,
        color: _miniProgramPrimaryText,
        onTap: _restart,
      ),
      _MiniProgramActionData(
        label: '复制链接',
        icon: Icons.link_rounded,
        color: _miniProgramPrimaryText,
        onTap: _copyLink,
      ),
    ];

    return Material(
      color: _miniProgramSheetColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 75,
              child: ColoredBox(
                color: _miniProgramHeaderColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _miniProgramTileColor,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          widget.icon,
                          color: const Color(0xFF07C160),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizeMiniProgramLabel(context, widget.title),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _miniProgramPrimaryText,
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizeMiniProgramLabel(
                                context,
                                widget.subtitle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _miniProgramSecondaryText,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _miniProgramSecondaryText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                      child: Text(
                        localizeMiniProgramLabel(context, '转发给'),
                        style: TextStyle(
                          color: _miniProgramPrimaryText,
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 104,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: _shareTargets.length,
                        itemBuilder: (context, index) {
                          final target = _shareTargets[index];
                          return _MiniProgramShareTarget(
                            target: target,
                            onTap: () => _showFeedback('已选择 ${target.name}'),
                          );
                        },
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: _miniProgramDividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
                      child: _MiniProgramActionRows(
                        firstRow: actions.take(6).toList(),
                        secondRow: actions.skip(6).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: _miniProgramDividerColor,
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: _close,
                style: TextButton.styleFrom(
                  foregroundColor: _miniProgramCancelText,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  localizeMiniProgramLabel(context, '取消'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniProgramActionData {
  const _MiniProgramActionData({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
}

class _MiniProgramActionRows extends StatelessWidget {
  const _MiniProgramActionRows({
    required this.firstRow,
    required this.secondRow,
  });

  final List<_MiniProgramActionData> firstRow;
  final List<_MiniProgramActionData> secondRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MiniProgramActionRow(actions: firstRow),
        const SizedBox(height: 10),
        _MiniProgramActionRow(actions: secondRow),
      ],
    );
  }
}

class _MiniProgramActionRow extends StatelessWidget {
  const _MiniProgramActionRow({required this.actions});

  final List<_MiniProgramActionData> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 99,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _MiniProgramActionTile(action: actions[index]);
        },
      ),
    );
  }
}

class _MiniProgramActionTile extends StatelessWidget {
  const _MiniProgramActionTile({required this.action});

  final _MiniProgramActionData action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: action.enabled,
      enabled: action.enabled,
      label: localizeMiniProgramLabel(
        context,
        action.label,
      ).replaceAll('\n', ''),
      child: SizedBox(
        width: 68,
        child: InkWell(
          onTap: action.enabled ? action.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _miniProgramTileColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 27),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SizedBox(
                  width: 68,
                  child: Text(
                    localizeMiniProgramLabel(context, action.label),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.2,
                      fontSize: 11,
                      color: action.enabled
                          ? _miniProgramPrimaryText
                          : _miniProgramDisabledText,
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

class _MiniProgramShareTarget extends StatelessWidget {
  const _MiniProgramShareTarget({required this.target, required this.onTap});

  final _MiniProgramShareTargetData target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: target.colors,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(target.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: 68,
              child: Text(
                localizeMiniProgramLabel(context, target.name),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _miniProgramSecondaryText,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniProgramShareTargetData {
  const _MiniProgramShareTargetData({
    required this.name,
    required this.icon,
    required this.colors,
  });

  final String name;
  final IconData icon;
  final List<Color> colors;
}

const _shareTargets = <_MiniProgramShareTargetData>[
  _MiniProgramShareTargetData(
    name: '文件传输助手',
    icon: Icons.folder_rounded,
    colors: [Color(0xFF67C23A), Color(0xFF3AA846)],
  ),
  _MiniProgramShareTargetData(
    name: '设计群',
    icon: Icons.groups_rounded,
    colors: [Color(0xFFFF9A62), Color(0xFFE65B67)],
  ),
  _MiniProgramShareTargetData(
    name: '林知夏',
    icon: Icons.person_rounded,
    colors: [Color(0xFF68B7FF), Color(0xFF4779E8)],
  ),
  _MiniProgramShareTargetData(
    name: '运营群',
    icon: Icons.forum_rounded,
    colors: [Color(0xFF9A7BFF), Color(0xFF6B59D9)],
  ),
  _MiniProgramShareTargetData(
    name: 'Jengro Woo',
    icon: Icons.person_outline_rounded,
    colors: [Color(0xFF55D6B8), Color(0xFF2A9D8F)],
  ),
];
