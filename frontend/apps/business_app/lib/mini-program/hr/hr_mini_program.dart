import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hr_controller.dart';
import 'hr_repository.dart';
import 'hr_routes.dart';
import 'hr_style.dart';
import 'pages/home_pages.dart';
import 'pages/profile_pages.dart';
import 'pages/punch_pages.dart';
import 'pages/request_pages.dart';
import 'pages/service_pages.dart';
import 'pages/team_pages.dart';
import 'pages/time_pages.dart';

/// RuoQi 人事小程序。
///
/// 默认使用静态模拟数据。页面和 [HrApi] 之间的边界由 [HrRepository]
/// 隔开，传入真实 repository 即可接入 Horilla。
class HrMiniProgram extends StatefulWidget {
  const HrMiniProgram({
    super.key,
    this.onExit,
    this.repository,
    this.useMockData = HrConfig.useMockData,
  });

  final VoidCallback? onExit;
  final HrRepository? repository;
  final bool useMockData;

  static Route<void> route({VoidCallback? onExit}) {
    return MaterialPageRoute<void>(
      builder: (context) =>
          HrMiniProgram(onExit: onExit ?? () => Navigator.of(context).pop()),
    );
  }

  @override
  State<HrMiniProgram> createState() => _HrMiniProgramState();
}

class _HrMiniProgramState extends State<HrMiniProgram> {
  late final HrAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HrAppController(
      repository:
          widget.repository ??
          (widget.useMockData
              ? const HrMockRepository()
              : HrConfig.repository(mock: false)),
      useMockData: widget.useMockData,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exit() {
    final callback = widget.onExit;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _showMore() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          decoration: const BoxDecoration(
            color: HrColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HrColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    HrLogoMark(size: 46),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RuoQi 人事',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text('员工自助 · 静态数据预览', style: HrText.meta),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.replay_rounded),
                  title: const Text('重新进入小程序'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _controller.resetToHome();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('小程序信息'),
                  subtitle: Text(
                    _controller.useMockData
                        ? '当前使用模拟数据，真实 API 已保留'
                        : '当前连接 Horilla API',
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HrTheme.data(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }
              if (_controller.canGoBack) {
                _controller.back();
              } else {
                _exit();
              }
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Material(
                color: HrColors.bg,
                child: Column(
                  children: [
                    const _HrStatusBar(),
                    _HrNavigationBar(
                      title: _controller.route.title,
                      canGoBack: _controller.canGoBack,
                      onBack: _controller.back,
                      onMore: _showMore,
                      onExit: _exit,
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: HrColors.bg,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 210),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [...previousChildren, ?currentChild],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            final begin = Offset(
                              _controller.forward ? 0.07 : -0.07,
                              0,
                            );
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: begin,
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey(_controller.route),
                            child: HrPageRouter.build(
                              _controller.route,
                              _controller,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_controller.route.showsBottomNavigation)
                      _HrBottomNavigation(
                        index: _controller.tabIndex,
                        onChanged: _controller.switchTab,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HrPageRouter {
  const HrPageRouter._();

  static Widget build(HrRoute route, HrAppController controller) {
    return switch (route) {
      HrRoute.signIn => HrSignInPage(controller: controller),
      HrRoute.punch => HrPunchPage(controller: controller),
      HrRoute.faceCheck => HrFaceCheckPage(controller: controller),
      HrRoute.home => HrHomePage(controller: controller),
      HrRoute.attendance => HrAttendancePage(controller: controller),
      HrRoute.leave => HrLeavePage(controller: controller),
      HrRoute.leaveApply => HrLeaveApplyPage(controller: controller),
      HrRoute.leaveAllocation => HrLeaveAllocationPage(controller: controller),
      HrRoute.correction => HrCorrectionPage(controller: controller),
      HrRoute.requests => HrRequestsPage(controller: controller),
      HrRoute.requestCompose => HrRequestComposePage(controller: controller),
      HrRoute.requestShift => HrRequestComposePage(controller: controller),
      HrRoute.requestWorkType => HrRequestComposePage(controller: controller),
      HrRoute.requestAsset => HrRequestComposePage(controller: controller),
      HrRoute.requestReimburse => HrRequestComposePage(controller: controller),
      HrRoute.helpdesk => HrHelpdeskPage(controller: controller),
      HrRoute.payslips => HrPayslipsPage(controller: controller),
      HrRoute.payslipDetail => HrPayslipDetailPage(controller: controller),
      HrRoute.approvals => HrApprovalsPage(controller: controller),
      HrRoute.team => HrTeamPage(controller: controller),
      HrRoute.directory => HrDirectoryPage(controller: controller),
      HrRoute.announcements => HrAnnouncementsPage(controller: controller),
      HrRoute.announcementDetail => HrAnnouncementDetailPage(
        controller: controller,
      ),
      HrRoute.notifications => HrNotificationsPage(controller: controller),
      HrRoute.me => HrMePage(controller: controller),
      HrRoute.personalInfo => HrPersonalInfoPage(controller: controller),
      HrRoute.faceEnrolment => HrFaceEnrolmentPage(controller: controller),
      HrRoute.settings => HrSettingsPage(controller: controller),
    };
  }
}

class _HrStatusBar extends StatelessWidget {
  const _HrStatusBar();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      color: HrColors.surface,
      height: top > 0 ? top + 5 : 26,
      padding: EdgeInsets.only(left: 16, right: 16, top: top > 0 ? top - 1 : 5),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: HrColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_alt, color: HrColors.ink, size: 13),
          SizedBox(width: 4),
          Icon(Icons.wifi_rounded, color: HrColors.ink, size: 13),
          SizedBox(width: 4),
          Icon(Icons.battery_full_rounded, color: HrColors.ink, size: 13),
        ],
      ),
    );
  }
}

class _HrNavigationBar extends StatelessWidget {
  const _HrNavigationBar({
    required this.title,
    required this.canGoBack,
    required this.onBack,
    required this.onMore,
    required this.onExit,
  });

  final String title;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: HrColors.surface,
        border: Border(bottom: BorderSide(color: HrColors.line2)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: canGoBack
                ? IconButton(
                    tooltip: '返回',
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: HrLogoMark(size: 30),
                  ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HrText.cardTitle.copyWith(fontSize: 14),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _HrCapsule(onMore: onMore, onExit: onExit),
          ),
        ],
      ),
    );
  }
}

class _HrCapsule extends StatelessWidget {
  const _HrCapsule({required this.onMore, required this.onExit});

  final VoidCallback onMore;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 29,
      decoration: BoxDecoration(
        color: HrColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: HrColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: '小程序菜单',
              child: Semantics(
                button: true,
                label: '小程序菜单',
                child: InkWell(
                  onTap: onMore,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(99),
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: HrColors.ink,
                  ),
                ),
              ),
            ),
          ),
          Container(width: 1, height: 15, color: HrColors.line),
          Expanded(
            child: Tooltip(
              message: '退出小程序',
              child: Semantics(
                button: true,
                label: '退出小程序',
                child: InkWell(
                  onTap: onExit,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(99),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 11,
                      color: HrColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HrBottomNavigation extends StatelessWidget {
  const _HrBottomNavigation({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = <(String, IconData)>[
    ('首页', Icons.home_outlined),
    ('时间', Icons.schedule_rounded),
    ('申请', Icons.inbox_outlined),
    ('团队', Icons.groups_2_outlined),
    ('我的', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: HrColors.bg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 7, 12, math.max(8, bottom)),
        child: Container(
          height: 58,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: HrColors.ink,
            borderRadius: BorderRadius.circular(23),
            boxShadow: HrShadows.hero,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 3.0;
              const activeFlex = 1.85;
              final unit =
                  (constraints.maxWidth - gap * (_items.length - 1)) /
                  (_items.length - 1 + activeFlex);
              return Row(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      width: i == index ? unit * activeFlex : unit,
                      child: Semantics(
                        button: true,
                        selected: i == index,
                        label: _items[i].$1,
                        child: InkWell(
                          key: Key('hr-tab-${_items[i].$1}'),
                          onTap: () => onChanged(i),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            decoration: BoxDecoration(
                              color: i == index
                                  ? HrColors.brand
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _items[i].$2,
                                  size: 19,
                                  color: i == index
                                      ? HrColors.surface
                                      : HrColors.ink4,
                                ),
                                if (i == index) ...[
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      _items[i].$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: HrColors.surface,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
