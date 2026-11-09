import 'package:flutter/material.dart';

import 'hr_routes.dart';
import 'hr_style.dart';
import 'pages/company_pages.dart';
import 'pages/home_pages.dart';
import 'pages/message_pages.dart';
import 'pages/misc_pages.dart';
import 'pages/profile_pages.dart';

class HrMiniProgram extends StatefulWidget {
  const HrMiniProgram({super.key, this.onExit});

  /// 小程序作为客户首页子视图时，由宿主切回微信式首页。
  final VoidCallback? onExit;

  @override
  State<HrMiniProgram> createState() => _HrMiniProgramState();
}

class _HrMiniProgramState extends State<HrMiniProgram> {
  late final HrAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HrAppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exit() {
    widget.onExit?.call();
  }

  void _showMore() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HrColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [HrColors.primary, Color(0xFF5BD2B3)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '企业直聘',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '招聘求职 · 微信小程序原型',
                            style: TextStyle(
                              color: HrColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _MiniCapsule(light: false),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                _MoreMenuItem(
                  icon: Icons.add_circle_outline,
                  label: '添加到我的小程序',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    hrToast(context, '已添加到我的小程序');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.replay_rounded,
                  label: '重新进入小程序',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _controller.switchTab(0);
                    hrToast(context, '已返回小程序首页');
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.info_outline_rounded,
                  label: '关于企业直聘',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _controller.open(HrRoute.aboutUs);
                  },
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
          final route = _controller.route;
          final greenNav = route.usesGreenNavigation;
          return Scaffold(
            backgroundColor: HrColors.background,
            body: Material(
              color: Colors.black,
              child: ClipRect(
                child: Column(
                  children: [
                    _MiniStatusBar(light: greenNav),
                    _MiniNavigationBar(
                      title: route.title,
                      light: greenNav,
                      canGoBack: _controller.canGoBack,
                      onBack: _controller.back,
                      onMore: _showMore,
                      onClose: _exit,
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: HrColors.background,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 230),
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
                              _controller.forward ? 0.08 : -0.08,
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
                            key: ValueKey(route),
                            child: HrPageRouter.build(route, _controller),
                          ),
                        ),
                      ),
                    ),
                    _MiniBottomChrome(
                      showTabs: route.isTabRoot,
                      index: _controller.tabIndex,
                      onChanged: _controller.switchTab,
                      onExit: _exit,
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
      HrRoute.home => HrHomePage(controller: controller),
      HrRoute.search => HrSearchPage(controller: controller),
      HrRoute.jobList => HrJobListPage(controller: controller),
      HrRoute.jobDetail => HrJobDetailPage(controller: controller),
      HrRoute.companyList => HrCompanyListPage(controller: controller),
      HrRoute.resumeList => HrResumeListPage(controller: controller),
      HrRoute.companyDetail => HrCompanyDetailPage(controller: controller),
      HrRoute.category => HrCategoryPage(controller: controller),
      HrRoute.messages => HrMessagesPage(controller: controller),
      HrRoute.privateChat => HrPrivateChatPage(controller: controller),
      HrRoute.notices => HrNoticesPage(controller: controller),
      HrRoute.noticeDetail => const HrNoticeDetailPage(),
      HrRoute.profile => HrProfilePage(controller: controller),
      HrRoute.aboutUs => HrAboutPage(controller: controller),
      HrRoute.terms => HrAboutPage(
        controller: controller,
        type: HrAboutType.terms,
      ),
      HrRoute.privacy => HrAboutPage(
        controller: controller,
        type: HrAboutType.privacy,
      ),
      HrRoute.help => HrHelpPage(controller: controller),
      HrRoute.helpDetail => const HrHelpDetailPage(),
      HrRoute.settings => HrSettingsPage(controller: controller),
      HrRoute.hideSetting => HrHideSettingPage(controller: controller),
      HrRoute.applications => HrApplicationsPage(controller: controller),
      HrRoute.connected => HrConnectedPage(controller: controller),
      HrRoute.browse => HrBrowsePage(controller: controller),
      HrRoute.robot => const HrRobotPage(),
      HrRoute.contactUs => const HrContactPage(),
      HrRoute.promoCode => HrPromoCodePage(controller: controller),
      HrRoute.userInfo => HrUserInfoPage(controller: controller),
      HrRoute.collect => HrCollectPage(controller: controller),
      HrRoute.login => HrLoginPage(controller: controller),
      HrRoute.loginIndex => HrLoginIndexPage(controller: controller),
      HrRoute.register => HrRegisterPage(controller: controller),
      HrRoute.registerSuccess => HrRegisterSuccessPage(controller: controller),
      HrRoute.bindPhone => HrBindPhonePage(controller: controller),
      HrRoute.industry => const HrIndustryPage(),
      HrRoute.post => const HrPostPage(),
      HrRoute.resume => HrResumePage(controller: controller),
      HrRoute.resumeDetail => HrResumeDetailPage(controller: controller),
      HrRoute.editEducation => const HrEditEducationPage(),
      HrRoute.editExpectation => const HrEditExpectationPage(),
      HrRoute.editProject => const HrEditProjectPage(),
      HrRoute.editProjectContent => const HrEditProjectContentPage(),
      HrRoute.editSkill => const HrEditSkillPage(),
      HrRoute.editWork => const HrEditWorkPage(),
      HrRoute.editWorkContent => const HrEditWorkContentPage(),
      HrRoute.companyEdit => HrCompanyEditPage(controller: controller),
      HrRoute.companyEnter => HrCompanyEnterPage(controller: controller),
      HrRoute.positions => HrPositionsPage(controller: controller),
      HrRoute.positionEdit => HrPositionEditPage(controller: controller),
      HrRoute.companyAuth => HrCompanyAuthPage(controller: controller),
    };
  }
}

class _MiniStatusBar extends StatelessWidget {
  const _MiniStatusBar({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final systemTop = MediaQuery.paddingOf(context).top;
    final color = light ? Colors.white : HrColors.text;
    return Container(
      color: light ? HrColors.primary : Colors.white,
      height: systemTop > 0 ? systemTop + 8 : 28,
      padding: EdgeInsets.fromLTRB(
        16,
        systemTop > 0 ? systemTop - 2 : 5,
        16,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Icon(Icons.signal_cellular_alt, color: color, size: 14),
          const SizedBox(width: 5),
          Icon(Icons.wifi, color: color, size: 14),
          const SizedBox(width: 5),
          Icon(Icons.battery_5_bar, color: color, size: 15),
        ],
      ),
    );
  }
}

class _MiniNavigationBar extends StatelessWidget {
  const _MiniNavigationBar({
    required this.title,
    required this.light,
    required this.canGoBack,
    required this.onBack,
    required this.onMore,
    required this.onClose,
  });

  final String title;
  final bool light;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : HrColors.text;
    return Container(
      height: 48,
      color: light ? HrColors.primary : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: canGoBack
                ? IconButton(
                    onPressed: onBack,
                    tooltip: '返回',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: foreground,
                      size: 20,
                    ),
                  )
                : const SizedBox(width: 40),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _MiniCapsule(light: light, onMore: onMore, onClose: onClose),
          ),
        ],
      ),
    );
  }
}

class _MiniCapsule extends StatelessWidget {
  const _MiniCapsule({required this.light, this.onMore, this.onClose});

  final bool light;
  final VoidCallback? onMore;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : HrColors.text;
    final borderColor = light
        ? Colors.white.withValues(alpha: 0.24)
        : HrColors.text.withValues(alpha: 0.12);
    return Container(
      width: onClose == null ? 42 : 84,
      height: 30,
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: '小程序菜单',
              child: InkWell(
                onTap: onMore,
                borderRadius: BorderRadius.horizontal(
                  left: const Radius.circular(99),
                  right: Radius.circular(onClose == null ? 99 : 0),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: foreground,
                  size: 19,
                ),
              ),
            ),
          ),
          if (onClose != null) ...[
            Container(width: 1, height: 15, color: borderColor),
            Expanded(
              child: Tooltip(
                message: '退出小程序',
                child: InkWell(
                  onTap: onClose,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(99),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: foreground, width: 1.7),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: foreground,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniBottomChrome extends StatelessWidget {
  const _MiniBottomChrome({
    required this.showTabs,
    required this.index,
    required this.onChanged,
    required this.onExit,
  });

  final bool showTabs;
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return _SwipeUpExitHandle(
      onExit: onExit,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: showTabs
              ? const Border(top: BorderSide(color: HrColors.divider))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTabs)
              SizedBox(
                height: 48,
                child: _MiniTabBar(index: index, onChanged: onChanged),
              ),
            SizedBox(
              height: bottomInset > 0 ? bottomInset : 12,
              child: Center(
                child: Container(
                  width: 110,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D8D8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTabBar extends StatelessWidget {
  const _MiniTabBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['首页', '分类', '消息', '我的'];
    const icons = [
      Icons.home_outlined,
      Icons.grid_view_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.person_outline_rounded,
    ];
    const selectedIcons = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.chat_bubble_rounded,
      Icons.person_rounded,
    ];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        index == i ? selectedIcons[i] : icons[i],
                        size: 21,
                        color: index == i
                            ? HrColors.primary
                            : HrColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: index == i
                              ? HrColors.primary
                              : HrColors.textMuted,
                          fontSize: 9,
                          fontWeight: index == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (i == 2)
                    Positioned(
                      top: 3,
                      right: 18,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: HrColors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SwipeUpExitHandle extends StatefulWidget {
  const _SwipeUpExitHandle({required this.onExit, required this.child});

  final VoidCallback onExit;
  final Widget child;

  @override
  State<_SwipeUpExitHandle> createState() => _SwipeUpExitHandleState();
}

class _SwipeUpExitHandleState extends State<_SwipeUpExitHandle> {
  double _upwardDistance = 0;

  void _completeExit() {
    _upwardDistance = 0;
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '底部上滑离开小程序',
      child: GestureDetector(
        key: const Key('mini-program-exit-swipe'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _upwardDistance = 0,
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            _upwardDistance -= details.delta.dy;
          }
          if (_upwardDistance >= 48) {
            _completeExit();
          }
        },
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -280) {
            _completeExit();
          }
          _upwardDistance = 0;
        },
        child: widget.child,
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: HrColors.text, size: 20),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: HrColors.text, fontSize: 13),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: HrColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
