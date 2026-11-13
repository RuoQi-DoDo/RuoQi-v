import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/common.dart';
import '../launcher/miniapp_launcher_item.dart';
import 'ats_routes.dart';
import 'ats_style.dart';
import 'pages/company_pages.dart';
import 'pages/home_pages.dart';
import 'pages/message_pages.dart';
import 'pages/misc_pages.dart';
import 'pages/profile_pages.dart';

class AtsMiniProgram extends StatefulWidget {
  const AtsMiniProgram({super.key, this.onExit}) : _routed = false;

  const AtsMiniProgram._routed({required this.onExit}) : _routed = true;

  /// 小程序作为客户首页子视图时，由宿主切回微信式首页。
  final VoidCallback? onExit;
  final bool _routed;

  static Route<void> route() => MaterialPageRoute<void>(
    builder: (context) =>
        AtsMiniProgram._routed(onExit: () => Navigator.of(context).pop()),
  );

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
      data: AtsTheme.data(brightness: Theme.of(context).brightness),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final route = _controller.route;
          final greenNav = route.usesGreenNavigation;
          final page = AtsPageRouter.build(route, _controller);
          final content = AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: greenNav
                  ? AtsColors.solidPrimary(context)
                  : AtsColors.resolve(context, AtsColors.surface),
              statusBarIconBrightness:
                  greenNav || Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness:
                  greenNav || Theme.of(context).brightness == Brightness.dark
                  ? Brightness.dark
                  : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: AtsColors.resolve(context, AtsColors.background),
              body: Material(
                color: Colors.black,
                child: ClipRect(
                  child: Column(
                    children: [
                      MiniProgramStatusBar(
                        backgroundColor: greenNav
                            ? AtsColors.solidPrimary(context)
                            : AtsColors.resolve(context, AtsColors.surface),
                        foregroundColor: greenNav
                            ? Colors.white
                            : AtsColors.resolve(context, AtsColors.text),
                      ),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: greenNav
                                  ? AtsColors.solidPrimary(context)
                                  : AtsColors.resolve(
                                      context,
                                      AtsColors.background,
                                    ),
                              child: route.isTabRoot
                                  ? route == AtsRoute.home
                                        ? AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 230,
                                            ),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            layoutBuilder:
                                                (
                                                  currentChild,
                                                  previousChildren,
                                                ) {
                                                  return Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      ...previousChildren,
                                                      ?currentChild,
                                                    ],
                                                  );
                                                },
                                            transitionBuilder:
                                                (child, animation) {
                                                  final begin = Offset(
                                                    _controller.forward
                                                        ? 0.08
                                                        : -0.08,
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
                                              child: page,
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              top: MiniProgramCapsuleOverlay
                                                  .reservedHeight,
                                            ),
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 230,
                                              ),
                                              switchInCurve:
                                                  Curves.easeOutCubic,
                                              switchOutCurve:
                                                  Curves.easeInCubic,
                                              layoutBuilder:
                                                  (
                                                    currentChild,
                                                    previousChildren,
                                                  ) {
                                                    return Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        ...previousChildren,
                                                        ?currentChild,
                                                      ],
                                                    );
                                                  },
                                              transitionBuilder:
                                                  (child, animation) {
                                                    final begin = Offset(
                                                      _controller.forward
                                                          ? 0.08
                                                          : -0.08,
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
                                                child: page,
                                              ),
                                            ),
                                          )
                                  : Column(
                                      children: [
                                        ColoredBox(
                                          color: greenNav
                                              ? AtsColors.solidPrimary(context)
                                              : AtsColors.resolve(
                                                  context,
                                                  AtsColors.background,
                                                ),
                                          child: MiniProgramPageHeader(
                                            title: route.title,
                                            onBack: _controller.canGoBack
                                                ? _controller.back
                                                : null,
                                            foregroundColor: greenNav
                                                ? Colors.white
                                                : AtsColors.resolve(
                                                    context,
                                                    AtsColors.text,
                                                  ),
                                          ),
                                        ),
                                        Expanded(child: page),
                                      ],
                                    ),
                            ),
                            Positioned(
                              top: 5,
                              right: 10,
                              child: MiniProgramCapsuleOverlay(
                                miniProgramId: MiniProgramLauncherIds.ats,
                                onMore: _showMore,
                                onClose: _exit,
                              ),
                            ),
                          ],
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
          if (!widget._routed) return content;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_controller.canGoBack) {
                _controller.back();
              } else {
                _exit();
              }
            },
            child: content,
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
    return Container(
      decoration: BoxDecoration(
        color: AtsColors.resolve(context, AtsColors.surface),
        border: showTabs
            ? Border(
                top: BorderSide(
                  color: AtsColors.resolve(context, AtsColors.divider),
                ),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTabs)
            SizedBox(
              key: const Key('mini-program-tab-bar'),
              height: 48,
              child: _MiniTabBar(index: index, onChanged: onChanged),
            ),
          MiniProgramSwipeExitRegion(
            key: const Key('mini-program-exit-swipe'),
            onExit: onExit,
            child: SizedBox(
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
          ),
        ],
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
                            ? AtsColors.resolve(context, AtsColors.primary)
                            : AtsColors.resolve(context, AtsColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizeMiniProgramLabel(context, labels[i]),
                        style: TextStyle(
                          color: index == i
                              ? AtsColors.resolve(context, AtsColors.primary)
                              : AtsColors.resolve(context, AtsColors.textMuted),
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
                          color: AtsColors.resolve(context, AtsColors.red),
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
