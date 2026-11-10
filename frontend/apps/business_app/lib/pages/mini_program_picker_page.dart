part of 'customer_home_page.dart';

class _MiniProgramPickerPage extends StatefulWidget {
  const _MiniProgramPickerPage({
    super.key,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onOpenHr,
    required this.onCloseDragStart,
    required this.onCloseDragUpdate,
    required this.onCloseDragEnd,
    required this.onCloseDragCancel,
  });

  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onOpenHr;
  final GestureDragStartCallback onCloseDragStart;
  final GestureDragUpdateCallback onCloseDragUpdate;
  final GestureDragEndCallback onCloseDragEnd;
  final VoidCallback onCloseDragCancel;

  @override
  State<_MiniProgramPickerPage> createState() => _MiniProgramPickerPageState();
}

enum _MiniProgramCollectionView { recent, mine }

class _MiniProgramPickerPageState extends State<_MiniProgramPickerPage> {
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

        final recent = <_LauncherMiniProgramData>[
          _LauncherMiniProgramData(
            label: '企业直聘',
            icon: Icons.work_outline_rounded,
            color: scheme.primary,
            opensAts: true,
          ),
          _LauncherMiniProgramData(
            label: '人事',
            icon: Icons.badge_outlined,
            color: const Color(0xFFC43D28),
            opensHr: true,
          ),
          _LauncherMiniProgramData(
            label: '文件助手',
            icon: Icons.folder_outlined,
            color: info,
          ),
          _LauncherMiniProgramData(
            label: '企业服务',
            icon: Icons.business_center_outlined,
            color: const Color(0xFFE36A2E),
          ),
          _LauncherMiniProgramData(
            label: '会议',
            icon: Icons.videocam_outlined,
            color: const Color(0xFF4D8DFF),
          ),
          _LauncherMiniProgramData(
            label: '简历助手',
            icon: Icons.description_outlined,
            color: const Color(0xFF8B5CF6),
          ),
          _LauncherMiniProgramData(
            label: '人才库',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF16A34A),
          ),
          _LauncherMiniProgramData(
            label: '面试日历',
            icon: Icons.calendar_month_outlined,
            color: const Color(0xFF0EA5E9),
          ),
        ];
        final common = <_LauncherMiniProgramData>[
          _LauncherMiniProgramData(
            label: '企业直聘',
            icon: Icons.work_outline_rounded,
            color: scheme.primary,
            opensAts: true,
          ),
          _LauncherMiniProgramData(
            label: '人事',
            icon: Icons.badge_outlined,
            color: const Color(0xFFC43D28),
            opensHr: true,
          ),
          _LauncherMiniProgramData(
            label: '企业服务',
            icon: Icons.business_center_outlined,
            color: const Color(0xFFE36A2E),
          ),
          _LauncherMiniProgramData(
            label: '商户',
            icon: Icons.fingerprint,
            color: const Color(0xFF3B82F6),
            opensMerchant: true,
          ),
          _LauncherMiniProgramData(
            label: '伙伴',
            icon: Icons.handshake_outlined,
            color: const Color(0xFF8B5CF6),
            opensPartner: true,
          ),
          _LauncherMiniProgramData(
            label: '人才测评',
            icon: Icons.psychology_outlined,
            color: const Color(0xFF10B981),
          ),
          _LauncherMiniProgramData(
            label: '视频面试',
            icon: Icons.video_chat_outlined,
            color: const Color(0xFFF97316),
          ),
          _LauncherMiniProgramData(
            label: '日程',
            icon: Icons.event_note_outlined,
            color: const Color(0xFF14B8A6),
          ),
        ];
        final allItems = <_LauncherMiniProgramData>[];
        for (final item in [...recent, ...common]) {
          if (!allItems.any((existing) => existing.label == item.label)) {
            allItems.add(item);
          }
        }
        allItems.addAll([
          const _LauncherMiniProgramData(
            label: '邮箱',
            icon: Icons.mail_outline_rounded,
            color: Color(0xFF3B82F6),
          ),
          const _LauncherMiniProgramData(
            label: '考勤',
            icon: Icons.fact_check_outlined,
            color: Color(0xFF14B8A6),
          ),
          const _LauncherMiniProgramData(
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
                ? _MiniProgramCollectionPage(
                    key: ValueKey(
                      'mini-program-collection-${_collectionView!.name}',
                    ),
                    title: _collectionView == _MiniProgramCollectionView.recent
                        ? '最近使用的小程序'
                        : '我的小程序',
                    items: _collectionView == _MiniProgramCollectionView.recent
                        ? allItems
                        : common,
                    onBack: () => setState(() => _collectionView = null),
                    onOpenAts: widget.onOpenAts,
                    onOpenMerchant: widget.onOpenMerchant,
                    onOpenPartner: widget.onOpenPartner,
                    onOpenHr: widget.onOpenHr,
                    onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                    onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 58,
                        child: Center(
                          child: Text(
                            '最近',
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
                        child: _PickerSearchBar(
                          onTap: () => _pickerToast(context, '搜索小程序为模拟入口'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          children: [
                            _PickerSectionHeader(
                              title: '最近使用的小程序',
                              trailing: '更多',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.recent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _LauncherGrid(
                              items: recent,
                              onOpenAts: widget.onOpenAts,
                              onOpenMerchant: widget.onOpenMerchant,
                              onOpenPartner: widget.onOpenPartner,
                              onOpenHr: widget.onOpenHr,
                              onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                            ),
                            const SizedBox(height: 42),
                            _PickerSectionHeader(
                              title: '常用的小程序',
                              trailing: '我的小程序',
                              onTap: () => setState(
                                () => _collectionView =
                                    _MiniProgramCollectionView.mine,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _LauncherGrid(
                              items: common,
                              onOpenAts: widget.onOpenAts,
                              onOpenMerchant: widget.onOpenMerchant,
                              onOpenPartner: widget.onOpenPartner,
                              onOpenHr: widget.onOpenHr,
                              onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                              highlightAtsForTest: true,
                              highlightHrForTest: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _PickerSwipeUpExitHandle(
              onDragStart: widget.onCloseDragStart,
              onDragUpdate: widget.onCloseDragUpdate,
              onDragEnd: widget.onCloseDragEnd,
              onDragCancel: widget.onCloseDragCancel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PickerBottomBar(
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
