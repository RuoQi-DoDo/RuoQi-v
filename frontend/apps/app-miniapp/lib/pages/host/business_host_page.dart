import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../miniapp/ats/ats_miniapp.dart';
import '../../miniapp/common/miniapp_pin.dart';
import '../../miniapp/launcher/launcher.dart';
import '../../miniapp/launcher/miniapp_catalog.dart';
import '../calls/calls_page.dart';
import '../common/page_theme.dart';
import '../discover/discover_page.dart';
import '../profile/me_page.dart';
import '../settings/settings_page.dart';
import 'host_tab_bar.dart';

/// Attach this controller to the business home scroll view to share pull-down
/// mini-program navigation with the host.
typedef BusinessHomeBuilder =
    Widget Function(BuildContext context, ScrollController scrollController);

enum _HostSubview { home, picker, ats }

/// Shared navigation and mini-program host; the first tab is supplied by the business.
class BusinessHostPage extends StatefulWidget {
  const BusinessHostPage({
    super.key,
    required this.homeBuilder,
    this.homeLabel = '聊天',
    this.homeIcon = Icons.home_outlined,
    this.homeActiveIcon = Icons.home_rounded,
    this.loginBuilder,
    this.onLogout,
  });
  final BusinessHomeBuilder homeBuilder;
  final String homeLabel;
  final IconData homeIcon;
  final IconData homeActiveIcon;
  final WidgetBuilder? loginBuilder;
  final VoidCallback? onLogout;
  @override
  State<BusinessHostPage> createState() => _BusinessHostPageState();
}

class _BusinessHostPageState extends State<BusinessHostPage>
    with TickerProviderStateMixin {
  static const double _pullOpenThreshold = 0.16;
  static const double _closeThreshold = 0.06;
  static const double _maxReleaseVelocity = 1.8;
  static const double _panelRevealStart = 0.015;
  static const double _panelRevealEnd = 1;
  static const double _panelMinScale = 0.42;

  _HostSubview _subview = _HostSubview.home;
  _HostSubview _atsReturnSubview = _HostSubview.home;
  HostTab _hostTab = HostTab.home;
  late final AnimationController _pullController;
  late final AnimationController _closeController;
  late final AnimationController _loadingController;
  late final ScrollController _hostScrollController;
  bool _pullDragging = false;
  bool _pullAnimating = false;
  bool _pullPointerCanDrag = false;
  double _pullTarget = 0;
  double _pullReleaseProgress = 0;
  double _pullPointerStartY = 0;
  double _pullPointerLastY = 0;
  bool _closeDragging = false;
  bool _closeAnimating = false;
  bool _startupRestoreScheduled = false;
  int _closeAnimationGeneration = 0;
  int _pullAnimationGeneration = 0;
  VelocityTracker? _pullVelocityTracker;
  MiniProgramPinController? _pinController;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = MiniProgramPinScope.maybeOf(context);
    _pinController = controller;
    if (_startupRestoreScheduled || !(controller?.isInitialized ?? false)) {
      return;
    }
    _startupRestoreScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restorePinnedMiniProgram();
    });
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
    if (_subview != _HostSubview.picker || _closeAnimating) {
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
          _subview = _HostSubview.home;
          _pullController.value = 0;
          _closeController.value = 0;
        }
      });
    });
  }

  void _openAtsMiniProgram() {
    setState(() {
      _atsReturnSubview = _subview;
      _subview = _HostSubview.ats;
    });
  }

  void _exitAtsMiniProgram() {
    setState(() => _subview = _atsReturnSubview);
  }

  Future<void> _openMiniProgramLauncherItem(
    MiniProgramLauncherItem item,
  ) async {
    if (item.id == MiniProgramLauncherIds.ats) {
      _openAtsMiniProgram();
      return;
    }
    await openMiniProgram(context, item);
  }

  Future<void> _restorePinnedMiniProgram() async {
    final pinnedId = _pinController?.pinnedId;
    if (!mounted || pinnedId == null) {
      return;
    }
    MiniProgramLauncherItem? pinnedItem;
    for (final item in availableMiniPrograms) {
      if (item.id == pinnedId) {
        pinnedItem = item;
        break;
      }
    }
    if (pinnedItem == null) {
      await _pinController?.unpin();
      return;
    }
    await _openMiniProgramLauncherItem(pinnedItem);
  }

  void _openSettingsPage() {
    Navigator.of(context).push<void>(
      SettingsPage.route(
        onLogout: widget.onLogout,
        loginBuilder: widget.loginBuilder,
      ),
    );
  }

  void _selectHostTab(HostTab tab) {
    if (_hostTab == tab) {
      return;
    }
    setState(() => _hostTab = tab);
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
    _pullReleaseProgress = _pullController.value.clamp(0.0, 1.0);
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
        _subview == _HostSubview.home &&
        _hostTab == HostTab.home &&
        !_pullAnimating &&
        (!_hostScrollController.hasClients ||
            _hostScrollController.offset <=
                _hostScrollController.position.minScrollExtent + 0.5);
    _pullVelocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _handlePullPointerMove(PointerMoveEvent event) {
    _pullVelocityTracker?.addPosition(event.timeStamp, event.position);
    if (!_pullPointerCanDrag ||
        _subview != _HostSubview.home ||
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

  double _panelRevealProgress(double progress) {
    final normalized =
        ((progress - _panelRevealStart) / (_panelRevealEnd - _panelRevealStart))
            .clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(normalized);
  }

  void _animatePullTo(double target, {required double velocity}) {
    final generation = ++_pullAnimationGeneration;
    final simulation = SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 250, ratio: 0.9),
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
        _subview = target == 1 ? _HostSubview.picker : _HostSubview.home;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _subview == _HostSubview.home &&
          !_pullAnimating &&
          _pullController.value == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        switch (_subview) {
          case _HostSubview.home:
            break;
          case _HostSubview.picker:
            _closeMiniProgramPicker();
          case _HostSubview.ats:
            _exitAtsMiniProgram();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: _subview == _HostSubview.ats,
            child: TickerMode(
              enabled: _subview != _HostSubview.ats,
              child: _buildCustomerSurface(context),
            ),
          ),
          if (_subview == _HostSubview.ats)
            AtsMiniProgram(
              key: const ValueKey('ats-mini-program'),
              onExit: _exitAtsMiniProgram,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSurface(BuildContext context) {
    final showPicker =
        _subview == _HostSubview.picker ||
        _pullController.value > 0 ||
        _pullAnimating;
    final pickerInteractive =
        _subview == _HostSubview.picker || (_pullAnimating && _pullTarget == 1);
    final showLoadingDots =
        _pullDragging || (_pullAnimating && _pullTarget == 1);
    final hostInteractive = _subview == _HostSubview.home && !pickerInteractive;
    final pickerBackdropColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF303030)
        : const Color(0xFFF2F2F2);
    return Stack(
      key: const ValueKey('customer-host-picker-stack'),
      fit: StackFit.expand,
      children: [
        if (showPicker)
          Positioned.fill(child: ColoredBox(color: pickerBackdropColor)),
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
                child: MiniProgramPickerPage(
                  key: const ValueKey('customer-mini-program-picker'),
                  onOpen: _openMiniProgramLauncherItem,
                  onCloseDragStart: _handlePickerCloseDragStart,
                  onCloseDragUpdate: _handlePickerCloseDragUpdate,
                  onCloseDragEnd: _handlePickerCloseDragEnd,
                  onCloseDragCancel: _handlePickerCloseDragCancel,
                ),
                builder: (context, child) {
                  final viewportHeight = MediaQuery.sizeOf(context).height;
                  final progress = _pullController.value.clamp(0.0, 1.0);
                  final closeProgress = _closeController.value.clamp(0.0, 1.0);
                  final openingFromPull = _pullAnimating && _pullTarget == 1;
                  final releaseRemaining = (1 - _pullReleaseProgress).clamp(
                    0.0001,
                    1.0,
                  );
                  final openingProgress =
                      ((progress - _pullReleaseProgress) / releaseRemaining)
                          .clamp(0.0, 1.0);
                  final releaseReveal = _panelRevealProgress(
                    _pullReleaseProgress,
                  );
                  final dragReveal = _panelRevealProgress(progress);
                  final scaleProgress = openingFromPull
                      ? releaseReveal +
                            (1 - releaseReveal) *
                                Curves.easeOutCubic.transform(openingProgress)
                      : _subview == _HostSubview.picker
                      ? 1.0
                      : dragReveal;
                  final opacity = _subview == _HostSubview.picker
                      ? 1.0
                      : progress == 0
                      ? 0.0
                      : 0.12 + 0.88 * scaleProgress;
                  final showingPanel =
                      _subview == _HostSubview.picker ||
                      _pullAnimating ||
                      _pullDragging ||
                      progress > 0;
                  final panelScale = showingPanel
                      ? _panelMinScale + (1 - _panelMinScale) * scaleProgress
                      : _panelMinScale;
                  return Transform.translate(
                    offset: Offset(0, -closeProgress * viewportHeight),
                    child: Transform.scale(
                      key: const Key('mini-program-panel-scale'),
                      alignment: const Alignment(0, -0.78),
                      scale: panelScale,
                      child: Opacity(opacity: opacity, child: child),
                    ),
                  );
                },
              ),
            ),
          ),
        if (showLoadingDots && _subview == _HostSubview.home)
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
                final hostProgress = _subview == _HostSubview.picker
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

  Widget _buildHostPage(BuildContext context, {required Key key}) => Material(
    child: Column(
      key: key,
      children: [
        Expanded(
          child: IndexedStack(
            index: _hostTab.index,
            children: [
              Listener(
                onPointerDown: _handlePullPointerDown,
                onPointerMove: _handlePullPointerMove,
                onPointerUp: _handlePullPointerUp,
                onPointerCancel: _handlePullPointerCancel,
                child: ScrollConfiguration(
                  behavior: const _NoOverscrollGlowBehavior(),
                  child: Builder(
                    builder: (context) =>
                        widget.homeBuilder(context, _hostScrollController),
                  ),
                ),
              ),
              const CallsPage(),
              const DiscoverPage(),
              MePage(onOpenSettings: _openSettingsPage),
            ],
          ),
        ),
        Theme(
          data: _hostTab == HostTab.home
              ? Theme.of(context)
              : sharedPageTheme(context),
          child: HostTabBar(
            selected: _hostTab,
            onSelected: _selectHostTab,
            homeLabel: widget.homeLabel,
            homeIcon: widget.homeIcon,
            homeActiveIcon: widget.homeActiveIcon,
          ),
        ),
      ],
    ),
  );
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
