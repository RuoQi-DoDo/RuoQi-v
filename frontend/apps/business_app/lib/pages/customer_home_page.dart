你可以import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../mini-program/ats/ats_mini_program.dart';
import '../mini-program/hr/hr_mini_program.dart';
import '../mini-program/merchant/home_page.dart';
import '../mini-program/mini_program_shell.dart';
import '../mini-program/partner/home_page.dart';

enum _CustomerSubview { host, picker, ats }

/// 客户域独立首页。
///
/// 视觉与交互模拟微信宿主：客户首页作为外层 App，下拉打开小程序选择页，
/// 再从“企业直聘”进入 ATS 小程序。下拉距离直接驱动面板过渡，
/// 不经过刷新状态，也不展示系统 overscroll 光效。
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CustomerHomePage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with TickerProviderStateMixin {
  static const double _pullOpenThreshold = 0.16;
  static const double _closeThreshold = 0.06;
  static const double _maxReleaseVelocity = 1.8;

  _CustomerSubview _subview = _CustomerSubview.host;
  _CustomerSubview _atsReturnSubview = _CustomerSubview.host;
  late final AnimationController _pullController;
  late final AnimationController _closeController;
  late final AnimationController _loadingController;
  late final ScrollController _hostScrollController;
  bool _pullDragging = false;
  bool _pullAnimating = false;
  bool _pullPointerCanDrag = false;
  double _pullTarget = 0;
  double _pullPointerStartY = 0;
  double _pullPointerLastY = 0;
  bool _closeDragging = false;
  bool _closeAnimating = false;
  int _closeAnimationGeneration = 0;
  int _pullAnimationGeneration = 0;
  VelocityTracker? _pullVelocityTracker;

  @override
  void initState() {
    super.initState();
    _pullController = AnimationController.unbounded(vsync: this);
    _closeController = AnimationController.unbounded(vsync: this);
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _hostScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pullController.dispose();
    _closeController.dispose();
    _loadingController.dispose();
    _hostScrollController.dispose();
    super.dispose();
  }

  void _closeMiniProgramPicker() {
    if (_closeAnimating) {
      return;
    }
    setState(() {
      _closeDragging = false;
      _closeAnimating = true;
    });
    _animateCloseTo(1, velocity: 0);
  }

  void _handlePickerCloseDragStart(DragStartDetails details) {
    if (_subview != _CustomerSubview.picker || _closeAnimating) {
      return;
    }
    _closeAnimationGeneration++;
    _closeController.stop();
    setState(() {
      _closeDragging = true;
    });
  }

  void _handlePickerCloseDragUpdate(DragUpdateDetails details) {
    if (!_closeDragging || details.delta.dy >= 0) {
      return;
    }
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final resistance = 1 - 0.18 * _closeController.value;
    _closeController.value =
        (_closeController.value -
                details.delta.dy / viewportHeight * resistance)
            .clamp(0.0, 1.0);
  }

  void _handlePickerCloseDragEnd(DragEndDetails details) {
    if (!_closeDragging) {
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    final shouldClose =
        _closeController.value >= _closeThreshold || velocity < -520;
    setState(() {
      _closeDragging = false;
      _closeAnimating = true;
    });
    final normalizedVelocity = (velocity / MediaQuery.sizeOf(context).height)
        .clamp(-_maxReleaseVelocity, _maxReleaseVelocity);
    _animateCloseTo(shouldClose ? 1 : 0, velocity: normalizedVelocity);
  }

  void _handlePickerCloseDragCancel() {
    if (!_closeDragging) {
      return;
    }
    setState(() {
      _closeDragging = false;
      _closeAnimating = true;
    });
    _animateCloseTo(0, velocity: 0);
  }

  void _animateCloseTo(double target, {required double velocity}) {
    final generation = ++_closeAnimationGeneration;
    final simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 210, ratio: 0.9),
      _closeController.value,
      target,
      velocity.clamp(-_maxReleaseVelocity, _maxReleaseVelocity),
    );
    _closeController.stop();
    _closeController.animateWith(simulation).whenCompleteOrCancel(() {
      if (!mounted ||
          generation != _closeAnimationGeneration ||
          !_closeAnimating) {
        return;
      }
      _closeController.value = target;
      setState(() {
        _closeAnimating = false;
        _closeDragging = false;
        if (target == 1) {
          _subview = _CustomerSubview.host;
          _pullController.value = 0;
          _closeController.value = 0;
        }
      });
    });
  }

  void _openAtsMiniProgram() {
    setState(() {
      _atsReturnSubview = _subview;
      _subview = _CustomerSubview.ats;
    });
  }

  void _exitAtsMiniProgram() {
    setState(() => _subview = _atsReturnSubview);
  }

  void _openMerchantMiniProgram() {
    Navigator.of(context).push<void>(
      MiniProgramShell.route(
        title: '商户',
        icon: Icons.fingerprint,
        child: const MerchantHomePage(embedded: true),
      ),
    );
  }

  void _openPartnerMiniProgram() {
    Navigator.of(context).push<void>(
      MiniProgramShell.route(
        title: '伙伴',
        icon: Icons.handshake_outlined,
        child: const PartnerHomePage(embedded: true),
      ),
    );
  }

  void _openHrMiniProgram() {
    Navigator.of(context).push<void>(HrMiniProgram.route());
  }

  void _finishPull({required double velocity}) {
    if (!_pullDragging || _pullAnimating) {
      return;
    }
    _loadingController
      ..stop()
      ..value = 0;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final shouldOpen =
        _pullController.value >= _pullOpenThreshold || velocity > 520;
    setState(() {
      _pullDragging = false;
      _pullAnimating = true;
      _pullTarget = shouldOpen ? 1 : 0;
    });
    final normalizedVelocity = (velocity / viewportHeight).clamp(
      -_maxReleaseVelocity,
      _maxReleaseVelocity,
    );
    _animatePullTo(shouldOpen ? 1 : 0, velocity: normalizedVelocity);
  }

  void _handlePullPointerDown(PointerDownEvent event) {
    _pullPointerStartY = event.position.dy;
    _pullPointerLastY = event.position.dy;
    _pullPointerCanDrag =
        _subview == _CustomerSubview.host &&
        !_pullAnimating &&
        _hostScrollController.hasClients &&
        _hostScrollController.offset <=
            _hostScrollController.position.minScrollExtent + 0.5;
    _pullVelocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _handlePullPointerMove(PointerMoveEvent event) {
    _pullVelocityTracker?.addPosition(event.timeStamp, event.position);
    if (!_pullPointerCanDrag ||
        _subview != _CustomerSubview.host ||
        _pullAnimating) {
      return;
    }

    final travel = event.position.dy - _pullPointerStartY;
    if (!_pullDragging && travel <= kTouchSlop) {
      return;
    }
    final delta = _pullDragging
        ? event.position.dy - _pullPointerLastY
        : travel - kTouchSlop;
    _pullPointerLastY = event.position.dy;
    if (delta == 0) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final resistance = 1 - 0.18 * _pullController.value;
    final nextValue =
        (_pullController.value + delta / viewportHeight * resistance).clamp(
          0.0,
          1.0,
        );
    if (!_pullDragging) {
      _pullAnimationGeneration++;
      _pullController.stop();
      _loadingController.repeat();
      setState(() {
        _pullDragging = true;
        _pullController.value = nextValue;
      });
      return;
    }
    _pullController.value = nextValue;
  }

  void _handlePullPointerUp(PointerUpEvent event) {
    final tracker = _pullVelocityTracker;
    tracker?.addPosition(event.timeStamp, event.position);
    final velocity = tracker?.getVelocity().pixelsPerSecond.dy ?? 0;
    _pullVelocityTracker = null;
    _pullPointerCanDrag = false;
    _finishPull(velocity: velocity);
  }

  void _handlePullPointerCancel(PointerCancelEvent event) {
    _pullVelocityTracker = null;
    _pullPointerCanDrag = false;
    _finishPull(velocity: 0);
  }

  void _animatePullTo(double target, {required double velocity}) {
    final generation = ++_pullAnimationGeneration;
    final simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 210, ratio: 0.9),
      _pullController.value,
      target,
      velocity.clamp(-_maxReleaseVelocity, _maxReleaseVelocity),
    );
    _pullController.stop();
    _pullController.animateWith(simulation).whenCompleteOrCancel(() {
      if (!mounted ||
          generation != _pullAnimationGeneration ||
          !_pullAnimating) {
        return;
      }
      _pullController.value = target;
      setState(() {
        _pullAnimating = false;
        _pullTarget = 0;
        _subview = target == 1
            ? _CustomerSubview.picker
            : _CustomerSubview.host;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _subview == _CustomerSubview.host &&
          !_pullAnimating &&
          _pullController.value == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        switch (_subview) {
          case _CustomerSubview.host:
            break;
          case _CustomerSubview.picker:
            _closeMiniProgramPicker();
          case _CustomerSubview.ats:
            _exitAtsMiniProgram();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [...previousChildren, ?currentChild],
          );
        },
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _subview == _CustomerSubview.ats
            ? AtsMiniProgram(
                key: const ValueKey('ats-mini-program'),
                onExit: _exitAtsMiniProgram,
              )
            : _buildCustomerSurface(context),
      ),
    );
  }

  Widget _buildCustomerSurface(BuildContext context) {
    final showPicker =
        _subview == _CustomerSubview.picker ||
        _pullController.value > 0 ||
        _pullAnimating;
    final pickerInteractive =
        _subview == _CustomerSubview.picker ||
        (_pullAnimating && _pullTarget == 1);
    final showLoadingDots =
        _pullDragging || (_pullAnimating && _pullTarget == 1);
    final hostInteractive =
        _subview == _CustomerSubview.host && !pickerInteractive;
    return Stack(
      key: const ValueKey('customer-host-picker-stack'),
      fit: StackFit.expand,
      children: [
        if (showPicker)
          const Positioned.fill(child: ColoredBox(color: Color(0xFF121212))),
        if (showPicker)
          IgnorePointer(
            ignoring: !pickerInteractive,
            child: ExcludeSemantics(
              excluding: !pickerInteractive,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _pullController,
                  _closeController,
                ]),
                child: _MiniProgramPickerPage(
                  key: const ValueKey('customer-mini-program-picker'),
                  onOpenAts: _openAtsMiniProgram,
                  onOpenMerchant: _openMerchantMiniProgram,
                  onOpenPartner: _openPartnerMiniProgram,
                  onOpenHr: _openHrMiniProgram,
                  onCloseDragStart: _handlePickerCloseDragStart,
                  onCloseDragUpdate: _handlePickerCloseDragUpdate,
                  onCloseDragEnd: _handlePickerCloseDragEnd,
                  onCloseDragCancel: _handlePickerCloseDragCancel,
                ),
                builder: (context, child) {
                  final viewportHeight = MediaQuery.sizeOf(context).height;
                  final progress = _pullController.value.clamp(0.0, 1.0);
                  final closeProgress = _closeController.value.clamp(0.0, 1.0);
                  final reveal = Curves.easeInOutCubic.transform(
                    (progress / 0.72).clamp(0.0, 1.0),
                  );
                  final openingFromPull = _pullAnimating && _pullTarget == 1;
                  final opacity =
                      _subview == _CustomerSubview.picker || openingFromPull
                      ? openingFromPull && _subview != _CustomerSubview.picker
                            ? 0.28 + 0.72 * reveal
                            : reveal
                      : 0.0;
                  final scaleProgress = Curves.easeOutCubic.transform(
                    (progress / 0.78).clamp(0.0, 1.0),
                  );
                  final panelScale =
                      _subview == _CustomerSubview.picker || openingFromPull
                      ? 0.82 + 0.18 * scaleProgress
                      : 0.82;
                  final panelRadius =
                      20 * (1 - scaleProgress) + 12 * closeProgress;
                  return Transform.translate(
                    offset: Offset(0, -closeProgress * viewportHeight),
                    child: Transform.scale(
                      key: const Key('mini-program-panel-scale'),
                      scale: panelScale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(panelRadius),
                        child: Opacity(opacity: opacity, child: child),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (showLoadingDots && _subview == _CustomerSubview.host)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 48,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _pullDragging ? 1 : 0,
                child: _MiniProgramLoadingDots(animation: _loadingController),
              ),
            ),
          ),
        IgnorePointer(
          ignoring: !hostInteractive,
          child: ExcludeSemantics(
            excluding: !hostInteractive,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pullController, _closeController]),
              child: _buildHostPage(
                context,
                key: const ValueKey('customer-host-home'),
              ),
              builder: (context, child) {
                final viewportHeight = MediaQuery.sizeOf(context).height;
                final progress = _pullController.value.clamp(0.0, 1.0);
                final closeProgress = _closeController.value.clamp(0.0, 1.0);
                final hostProgress = _subview == _CustomerSubview.picker
                    ? 1 - closeProgress
                    : progress;
                return Transform.translate(
                  offset: Offset(0, hostProgress * viewportHeight),
                  child: child,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostPage(BuildContext context, {required Key key}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;

    return Scaffold(
      key: key,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'RuoQi',
              style: zh(
                theme.textTheme.headlineMedium!.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '客户模拟',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () => _showHostToast(context, '搜索功能为模拟入口'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '发起',
            onPressed: () => _showHostToast(context, '发起功能为模拟入口'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      body: Listener(
        onPointerDown: _handlePullPointerDown,
        onPointerMove: _handlePullPointerMove,
        onPointerUp: _handlePullPointerUp,
        onPointerCancel: _handlePullPointerCancel,
        child: ScrollConfiguration(
          behavior: const _NoOverscrollGlowBehavior(),
          child: CustomScrollView(
            key: const Key('customer-home-scroll'),
            controller: _hostScrollController,
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  _ChatRow(
                    title: '企业直聘',
                    preview: '面试邀请：上海世佳科技邀请你参加面试',
                    time: '刚刚',
                    unread: 1,
                    color: scheme.primary,
                    icon: Icons.work_outline_rounded,
                    onTap: () => _showHostToast(context, '该聊天由小程序消息模拟'),
                  ),
                  _ChatRow(
                    title: '佳佳',
                    preview: '周末一起去看展吗？',
                    time: '10:32',
                    unread: 2,
                    color: const Color(0xFFEC6A88),
                    icon: Icons.person_outline_rounded,
                    onTap: () => _showHostToast(context, '聊天详情为模拟入口'),
                  ),
                  _ChatRow(
                    title: '文件传输助手',
                    preview: '[文件] 简历-林小满.pdf',
                    time: '昨天',
                    unread: 0,
                    color:
                        theme.extension<RuQiThemeExtension>()?.info ??
                        scheme.secondary,
                    icon: Icons.folder_outlined,
                    onTap: () => _showHostToast(context, '文件传输为模拟入口'),
                  ),
                  _ChatRow(
                    title: '招聘交流群',
                    preview: '陈一鸣：感谢大家的建议',
                    time: '昨天',
                    unread: 0,
                    color: scheme.primary,
                    icon: Icons.groups_outlined,
                    onTap: () => _showHostToast(context, '群聊为模拟入口'),
                  ),
                  _ChatRow(
                    title: '腾讯新闻',
                    preview: '今日要闻：数字招聘的新趋势',
                    time: '周一',
                    unread: 0,
                    color: const Color(0xFFE36A2E),
                    icon: Icons.article_outlined,
                    onTap: () => _showHostToast(context, '公众号为模拟入口'),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _WeChatTabBar(),
    );
  }

  static void _showHostToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NoOverscrollGlowBehavior extends ScrollBehavior {
  const _NoOverscrollGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _MiniProgramLoadingDots extends StatelessWidget {
  const _MiniProgramLoadingDots({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('mini-program-loading-dots'),
      label: '正在打开小程序',
      child: SizedBox(
        height: 18,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < 3; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A8A8A).withValues(
                          alpha:
                              0.35 +
                              0.55 *
                                  ((math.sin(
                                            (animation.value + index * 0.18) *
                                                math.pi *
                                                2,
                                          ) +
                                          1) /
                                      2),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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

class _MiniProgramPickerPageState extends State<_MiniProgramPickerPage> {
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Theme(
      data: ruoQiTheme(brightness: Brightness.dark, accent: accent),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final muted =
              theme.extension<RuQiThemeExtension>()?.inkMuted ??
              scheme.onSurfaceVariant;
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
            _LauncherMiniProgramData(
              label: '更多',
              icon: Icons.apps_rounded,
              color: muted,
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
            _LauncherMiniProgramData(
              label: '设置',
              icon: Icons.tune_rounded,
              color: muted,
            ),
          ];

          return Scaffold(
            backgroundColor: scheme.surface,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 58,
                    child: Center(
                      child: Text(
                        '最近',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                          fontSize: 20,
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
                          onTap: () => _pickerToast(context, '查看更多最近使用'),
                        ),
                        const SizedBox(height: 14),
                        _LauncherGrid(
                          items: recent,
                          onOpenAts: widget.onOpenAts,
                          onOpenMerchant: widget.onOpenMerchant,
                          onOpenPartner: widget.onOpenPartner,
                          onOpenHr: widget.onOpenHr,
                          onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                        ),
                        const SizedBox(height: 30),
                        _PickerSectionHeader(
                          title: '常用的小程序',
                          trailing: '我的小程序',
                          onTap: () => _pickerToast(context, '管理我的小程序'),
                        ),
                        const SizedBox(height: 14),
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
                        const SizedBox(height: 30),
                        const _PickerSectionHeader(title: '刚刚看过（最近1小时）'),
                        const SizedBox(height: 14),
                        _ViewedMiniProgramCard(
                          onTap: () => _pickerToast(context, '求职课堂视频为模拟入口'),
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
      ),
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

class _PickerSwipeUpExitHandle extends StatelessWidget {
  const _PickerSwipeUpExitHandle({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.child,
  });

  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '底部上滑返回客户首页',
      child: GestureDetector(
        key: const Key('mini-program-picker-exit-swipe'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        onVerticalDragCancel: onDragCancel,
        child: child,
      ),
    );
  }
}

class _LauncherMiniProgramData {
  const _LauncherMiniProgramData({
    required this.label,
    required this.icon,
    required this.color,
    this.opensAts = false,
    this.opensMerchant = false,
    this.opensPartner = false,
    this.opensHr = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool opensAts;
  final bool opensMerchant;
  final bool opensPartner;
  final bool opensHr;
}

class _LauncherGrid extends StatelessWidget {
  const _LauncherGrid({
    required this.items,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onOpenHr,
    required this.onOther,
    this.highlightAtsForTest = false,
    this.highlightHrForTest = false,
  });

  final List<_LauncherMiniProgramData> items;
  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onOpenHr;
  final VoidCallback onOther;
  final bool highlightAtsForTest;
  final bool highlightHrForTest;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 102,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final key = item.opensAts && highlightAtsForTest
            ? const Key('mini-program-picker-ats')
            : item.opensMerchant
            ? const Key('mini-program-picker-merchant')
            : item.opensHr && highlightHrForTest
            ? const Key('mini-program-picker-hr')
            : item.opensPartner
            ? const Key('mini-program-picker-partner')
            : null;
        return _LauncherMiniProgramTile(
          key: key,
          data: item,
          onTap: item.opensAts
              ? onOpenAts
              : item.opensMerchant
              ? onOpenMerchant
              : item.opensHr
              ? onOpenHr
              : item.opensPartner
              ? onOpenPartner
              : onOther,
        );
      },
    );
  }
}

class _LauncherMiniProgramTile extends StatelessWidget {
  const _LauncherMiniProgramTile({
    super.key,
    required this.data,
    required this.onTap,
  });

  final _LauncherMiniProgramData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withValues(alpha: 0.28)),
            ),
            child: Icon(data.icon, color: data.color, size: 29),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewedMiniProgramCard extends StatelessWidget {
  const _ViewedMiniProgramCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 118,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 158,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF343746), Color(0xFF17181D)],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Icon(
                        Icons.school_outlined,
                        color: Color(0x22FFFFFF),
                        size: 100,
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 12,
                      child: Text(
                        '求职课堂',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '视频',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerBottomBar extends StatelessWidget {
  const _PickerBottomBar({required this.onSearch, required this.onMore});

  final VoidCallback onSearch;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    return Container(
      height: 60,
      color: scheme.surfaceContainer,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'RuoQi',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: '搜索',
            icon: Icon(Icons.search_rounded, color: muted, size: 26),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: '更多',
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String preview;
  final String time;
  final int unread;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$unread',
                              style: TextStyle(
                                color: scheme.onError,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeChatTabBar extends StatelessWidget {
  const _WeChatTabBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    const items = [
      (Icons.chat_bubble_rounded, 'RuoQi', true),
      (Icons.contacts_outlined, '通讯录', false),
      (Icons.explore_outlined, '发现', false),
      (Icons.person_outline_rounded, '我', false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (final (icon, label, selected) in items)
                Expanded(
                  child: InkWell(
                    onTap: selected
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$label 为模拟入口')),
                          ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 23,
                          color: selected ? scheme.primary : muted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected ? scheme.primary : muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

class _PickerSearchBar extends StatelessWidget {
  const _PickerSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                '搜索小程序',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSectionHeader extends StatelessWidget {
  const _PickerSectionHeader({required this.title, this.trailing, this.onTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: Text(trailing!),
          ),
      ],
    );
  }
}
