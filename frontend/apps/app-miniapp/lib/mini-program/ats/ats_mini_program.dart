import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mini_program_shell.dart';
import 'ats_routes.dart';
import 'ats_style.dart';
import 'pages/company_pages.dart';
import 'pages/home_pages.dart';
import 'pages/message_pages.dart';
import 'pages/misc_pages.dart';
import 'pages/profile_pages.dart';

class AtsMiniProgram extends StatefulWidget {
  const AtsMiniProgram({super.key, this.onExit});

  /// 小程序作为客户首页子视图时，由宿主切回微信式首页。
  final VoidCallback? onExit;

  @override
  State<AtsMiniProgram> createState() => _AtsMiniProgramState();
}

class _AtsMiniProgramState extends State<AtsMiniProgram> {
  late final AtsAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtsAppController();
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
    showMiniProgramActionsSheet(
      context,
      title: '企业直聘',
      subtitle: '招聘求职 · 微信小程序原型',
      icon: Icons.work_outline_rounded,
      onRestart: () {
        _controller.switchTab(0);
        atsToast(context, '已返回小程序首页');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AtsTheme.data(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final route = _controller.route;
          final greenNav = route.usesGreenNavigation;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: greenNav ? AtsColors.primary : Colors.white,
              statusBarIconBrightness: greenNav
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: greenNav
                  ? Brightness.dark
                  : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: AtsColors.background,
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
                          color: AtsColors.background,
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
                              child: AtsPageRouter.build(route, _controller),
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
            ),
          );
        },
      ),
    );
  }
}

class AtsPageRouter {
  const AtsPageRouter._();

  static Widget build(AtsRoute route, AtsAppController controller) {
    return switch (route) {
      AtsRoute.home => AtsHomePage(controller: controller),
      AtsRoute.search => AtsSearchPage(controller: controller),
      AtsRoute.jobList => AtsJobListPage(controller: controller),
      AtsRoute.jobDetail => AtsJobDetailPage(controller: controller),
      AtsRoute.companyList => AtsCompanyListPage(controller: controller),
      AtsRoute.resumeList => AtsResumeListPage(controller: controller),
      AtsRoute.companyDetail => AtsCompanyDetailPage(controller: controller),
      AtsRoute.category => AtsCategoryPage(controller: controller),
      AtsRoute.messages => AtsMessagesPage(controller: controller),
      AtsRoute.privateChat => AtsPrivateChatPage(controller: controller),
      AtsRoute.notices => AtsNoticesPage(controller: controller),
      AtsRoute.noticeDetail => const AtsNoticeDetailPage(),
      AtsRoute.profile => AtsProfilePage(controller: controller),
      AtsRoute.aboutUs => AtsAboutPage(controller: controller),
      AtsRoute.terms => AtsAboutPage(
        controller: controller,
        type: AtsAboutType.terms,
      ),
      AtsRoute.privacy => AtsAboutPage(
        controller: controller,
        type: AtsAboutType.privacy,
      ),
      AtsRoute.help => AtsHelpPage(controller: controller),
      AtsRoute.helpDetail => const AtsHelpDetailPage(),
      AtsRoute.settings => AtsSettingsPage(controller: controller),
      AtsRoute.hideSetting => AtsHideSettingPage(controller: controller),
      AtsRoute.applications => AtsApplicationsPage(controller: controller),
      AtsRoute.connected => AtsConnectedPage(controller: controller),
      AtsRoute.browse => AtsBrowsePage(controller: controller),
      AtsRoute.robot => const AtsRobotPage(),
      AtsRoute.contactUs => const AtsContactPage(),
      AtsRoute.promoCode => AtsPromoCodePage(controller: controller),
      AtsRoute.userInfo => AtsUserInfoPage(controller: controller),
      AtsRoute.collect => AtsCollectPage(controller: controller),
      AtsRoute.login => AtsLoginPage(controller: controller),
      AtsRoute.loginIndex => AtsLoginIndexPage(controller: controller),
      AtsRoute.register => AtsRegisterPage(controller: controller),
      AtsRoute.registerSuccess => AtsRegisterSuccessPage(
        controller: controller,
      ),
      AtsRoute.bindPhone => AtsBindPhonePage(controller: controller),
      AtsRoute.industry => const AtsIndustryPage(),
      AtsRoute.post => const AtsPostPage(),
      AtsRoute.resume => AtsResumePage(controller: controller),
      AtsRoute.resumeDetail => AtsResumeDetailPage(controller: controller),
      AtsRoute.editEducation => const AtsEditEducationPage(),
      AtsRoute.editExpectation => const AtsEditExpectationPage(),
      AtsRoute.editProject => const AtsEditProjectPage(),
      AtsRoute.editProjectContent => const AtsEditProjectContentPage(),
      AtsRoute.editSkill => const AtsEditSkillPage(),
      AtsRoute.editWork => const AtsEditWorkPage(),
      AtsRoute.editWorkContent => const AtsEditWorkContentPage(),
      AtsRoute.companyEdit => AtsCompanyEditPage(controller: controller),
      AtsRoute.companyEnter => AtsCompanyEnterPage(controller: controller),
      AtsRoute.positions => AtsPositionsPage(controller: controller),
      AtsRoute.positionEdit => AtsPositionEditPage(controller: controller),
      AtsRoute.companyAuth => AtsCompanyAuthPage(controller: controller),
    };
  }
}

class _MiniStatusBar extends StatelessWidget {
  const _MiniStatusBar({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final systemTop = MediaQuery.paddingOf(context).top;
    final color = light ? Colors.white : AtsColors.text;
    final backgroundColor = light ? AtsColors.primary : Colors.white;
    if (systemTop > 0) {
      return ColoredBox(
        color: backgroundColor,
        child: SizedBox(height: systemTop),
      );
    }
    return Container(
      color: backgroundColor,
      height: 28,
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
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
    final foreground = light ? Colors.white : AtsColors.text;
    return Container(
      height: 48,
      color: light ? AtsColors.primary : Colors.white,
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
            child: MiniProgramCapsule(onMore: onMore, onClose: onClose),
          ),
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
              ? const Border(top: BorderSide(color: AtsColors.divider))
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
                            ? AtsColors.primary
                            : AtsColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: TextStyle(
                          color: index == i
                              ? AtsColors.primary
                              : AtsColors.textMuted,
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
                          color: AtsColors.red,
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
