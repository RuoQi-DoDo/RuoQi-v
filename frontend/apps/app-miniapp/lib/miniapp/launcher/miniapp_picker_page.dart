import '../common/miniapp_localizations.dart';

import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'launcher_widgets.dart';
import 'miniapp_collection_page.dart';
import 'miniapp_launcher_item.dart';

/// 客户首页的小程序选择页。
class MiniProgramPickerPage extends StatefulWidget {
  const MiniProgramPickerPage({
    super.key,
    required this.onOpen,
    required this.onCloseDragStart,
    required this.onCloseDragUpdate,
    required this.onCloseDragEnd,
    required this.onCloseDragCancel,
  });

  final ValueChanged<MiniProgramLauncherItem> onOpen;
  final GestureDragStartCallback onCloseDragStart;
  final GestureDragUpdateCallback onCloseDragUpdate;
  final GestureDragEndCallback onCloseDragEnd;
  final VoidCallback onCloseDragCancel;

  @override
  State<MiniProgramPickerPage> createState() => _MiniProgramPickerPageState();
}

enum _MiniProgramCollectionView { recent, mine }

class _MiniProgramPickerPageState extends State<MiniProgramPickerPage> {
  _MiniProgramCollectionView? _collectionView;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final brightness = Theme.of(context).brightness;
    final baseTheme = ruoQiTheme(brightness: brightness, accent: accent);
    if (brightness == Brightness.light) {
      final pickerTheme = baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        colorScheme: baseTheme.colorScheme.copyWith(
          surface: const Color(0xFFF2F2F2),
          surfaceContainerLowest: const Color(0xFFF7F7F7),
          surfaceContainerLow: Colors.white,
          surfaceContainer: Colors.white,
          surfaceContainerHigh: const Color(0xFFEAEAEA),
          onSurface: const Color(0xFF111111),
          onSurfaceVariant: const Color(0xFF707070),
          outlineVariant: const Color(0xFFDEDEDE),
        ),
      );
      return Theme(data: pickerTheme, child: _buildPickerContent(context));
    }
    final pickerTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF303030),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: const Color(0xFF303030),
        surfaceContainerLowest: const Color(0xFF292929),
        surfaceContainerLow: const Color(0xFF424242),
        surfaceContainer: const Color(0xFF565656),
        surfaceContainerHigh: const Color(0xFF383838),
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xFFBDBDBD),
        outlineVariant: const Color(0xFF4A4A4A),
      ),
    );
    return Theme(data: pickerTheme, child: _buildPickerContent(context));
  }

  Widget _buildPickerContent(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final info =
            theme.extension<RuQiThemeExtension>()?.info ?? scheme.secondary;

        final recent = <MiniProgramLauncherItem>[
          MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.ats,
            label: '企业直聘',
            icon: Icons.work_outline_rounded,
            color: scheme.primary,
          ),
          const MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.hr,
            label: '人事',
            icon: Icons.badge_outlined,
            color: Color(0xFFC43D28),
          ),
          MiniProgramLauncherItem(
            id: 'file-assistant',
            label: '文件助手',
            icon: Icons.folder_outlined,
            color: info,
          ),
          const MiniProgramLauncherItem(
            id: 'enterprise-services',
            label: '企业服务',
            icon: Icons.business_center_outlined,
            color: Color(0xFFE36A2E),
          ),
          const MiniProgramLauncherItem(
            id: 'meeting',
            label: '会议',
            icon: Icons.videocam_outlined,
            color: Color(0xFF4D8DFF),
          ),
          const MiniProgramLauncherItem(
            id: 'resume-assistant',
            label: '简历助手',
            icon: Icons.description_outlined,
            color: Color(0xFF8B5CF6),
          ),
          const MiniProgramLauncherItem(
            id: 'talent-pool',
            label: '人才库',
            icon: Icons.people_outline_rounded,
            color: Color(0xFF16A34A),
          ),
          const MiniProgramLauncherItem(
            id: 'interview-calendar',
            label: '面试日历',
            icon: Icons.calendar_month_outlined,
            color: Color(0xFF0EA5E9),
          ),
        ];
        final commonItems = <MiniProgramLauncherItem>[
          MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.ats,
            label: '企业直聘',
            icon: Icons.work_outline_rounded,
            color: scheme.primary,
            tileKey: const Key('mini-program-picker-ats'),
          ),
          const MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.hr,
            label: '人事',
            icon: Icons.badge_outlined,
            color: Color(0xFFC43D28),
            tileKey: Key('mini-program-picker-hr'),
          ),
          const MiniProgramLauncherItem(
            id: 'enterprise-services',
            label: '企业服务',
            icon: Icons.business_center_outlined,
            color: Color(0xFFE36A2E),
          ),
          const MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.merchant,
            label: '商户',
            icon: Icons.fingerprint,
            color: Color(0xFF3B82F6),
            tileKey: Key('mini-program-picker-merchant'),
          ),
          const MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.partner,
            label: '伙伴',
            icon: Icons.handshake_outlined,
            color: Color(0xFF8B5CF6),
            tileKey: Key('mini-program-picker-partner'),
          ),
          const MiniProgramLauncherItem(
            id: MiniProgramLauncherIds.platform,
            label: '平台管理',
            icon: Icons.admin_panel_settings_outlined,
            color: Color(0xFF0D9488),
            tileKey: Key('mini-program-picker-platform'),
          ),
          const MiniProgramLauncherItem(
            id: 'talent-assessment',
            label: '人才测评',
            icon: Icons.psychology_outlined,
            color: Color(0xFF10B981),
          ),
          const MiniProgramLauncherItem(
            id: 'video-interview',
            label: '视频面试',
            icon: Icons.video_chat_outlined,
            color: Color(0xFFF97316),
          ),
          const MiniProgramLauncherItem(
            id: 'schedule',
            label: '日程',
            icon: Icons.event_note_outlined,
            color: Color(0xFF14B8A6),
          ),
        ];
        final allItems = <MiniProgramLauncherItem>[];
        for (final item in [...recent, ...commonItems]) {
          if (!allItems.any((existing) => existing.id == item.id)) {
            allItems.add(item);
          }
        }
        allItems.addAll(const [
          MiniProgramLauncherItem(
            id: 'mail',
            label: '邮箱',
            icon: Icons.mail_outline_rounded,
            color: Color(0xFF3B82F6),
          ),
          MiniProgramLauncherItem(
            id: 'attendance',
            label: '考勤',
            icon: Icons.fact_check_outlined,
            color: Color(0xFF14B8A6),
          ),
          MiniProgramLauncherItem(
            id: 'approval',
            label: '审批',
            icon: Icons.approval_outlined,
            color: Color(0xFFF59E0B),
          ),
        ]);

        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            bottom: false,
            child: _collectionView != null
                ? MiniProgramCollectionPage(
                    key: ValueKey(
                      'mini-program-collection-${_collectionView!.name}',
                    ),
                    title: _collectionView == _MiniProgramCollectionView.recent
                        ? '最近使用的小程序'
                        : '我的小程序',
                    items: _collectionView == _MiniProgramCollectionView.recent
                        ? allItems
                        : commonItems,
                    onBack: () => setState(() => _collectionView = null),
                    onOpen: widget.onOpen,
                    onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 58,
                        child: Center(
                          child: Text(
                            localizeMiniProgramLabel(context, '最近'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MiniProgramLauncherSearchBar(
                          onTap: () => _pickerToast(context, '搜索小程序为模拟入口'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            MiniProgramLauncherSectionHeader(
                              title: '最近使用的小程序',
                              trailing: '更多',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.recent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MiniProgramLauncherGrid(
                              items: recent,
                              onOpen: widget.onOpen,
                            ),
                            const SizedBox(height: 42),
                            MiniProgramLauncherSectionHeader(
                              title: '常用的小程序',
                              trailing: '我的小程序',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.mine,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MiniProgramLauncherGrid(
                              items: commonItems,
                              onOpen: widget.onOpen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: MiniProgramLauncherSwipeExitHandle(
              onDragStart: widget.onCloseDragStart,
              onDragUpdate: widget.onCloseDragUpdate,
              onDragEnd: widget.onCloseDragEnd,
              onDragCancel: widget.onCloseDragCancel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniProgramLauncherBottomBar(
                    onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                    onMore: () => _pickerToast(context, '更多为模拟入口'),
                  ),
                  Container(
                    height: 18,
                    color: scheme.surfaceContainer,
                    alignment: Alignment.center,
                    child: Container(
                      width: 110,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void _pickerToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      );
  }
}
