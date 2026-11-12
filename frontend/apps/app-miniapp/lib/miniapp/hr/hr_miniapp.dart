import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/common.dart';
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
    showMiniProgramActionsSheet(
      context,
      title: 'RuoQi 人事',
      subtitle: _controller.useMockData
          ? '员工自助 · 静态数据预览'
          : '员工自助 · Horilla API',
      icon: Icons.badge_outlined,
      onRestart: _controller.resetToHome,
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
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: HrColors.surface,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Material(
                  color: HrColors.bg,
                  child: Column(
                    children: [
                      const MiniProgramStatusBar(
                        backgroundColor: HrColors.surface,
                        foregroundColor: HrColors.ink,
                        fallbackHeight: 26,
                        fontSize: 11,
                        iconSize: 13,
                        iconGap: 4,
                      ),
                      MiniProgramNavigationBar(
                        title: _controller.route.title,
                        canGoBack: _controller.canGoBack,
                        onBack: _controller.back,
                        onMore: _showMore,
                        onClose: _exit,
                        leading: _controller.canGoBack
                            ? null
                            : const Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: HrLogoMark(size: 30),
                              ),
                        backgroundColor: HrColors.surface,
                        foregroundColor: HrColors.ink,
                        borderColor: HrColors.line2,
                        backIconSize: 18,
                        titleStyle: HrText.cardTitle.copyWith(fontSize: 14),
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
