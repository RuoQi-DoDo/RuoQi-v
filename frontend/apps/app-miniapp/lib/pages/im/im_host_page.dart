part of 'im_home_page.dart';

enum _ImSubview { host, picker, ats }

enum _HostTab { chats, contacts, discover, me }

/// IM 业务组独立首页。
///
/// 视觉与交互模拟微信宿主：客户首页作为外层 App，下拉打开小程序选择页，
/// 再从“企业直聘”进入 ATS 小程序。下拉距离直接驱动面板过渡，
/// 不经过刷新状态，也不展示系统 overscroll 光效。
class ImHomePage extends StatefulWidget {
  const ImHomePage({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ImHomePage();
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
  State<ImHomePage> createState() => _ImHomePageState();
}

class _ImHomePageState extends State<ImHomePage> with TickerProviderStateMixin {
  static const double _pullOpenThreshold = 0.16;
  static const double _closeThreshold = 0.06;
  static const double _maxReleaseVelocity = 1.8;
  static const double _panelRevealStart = 0.015;
  static const double _panelRevealEnd = 1;
  static const double _panelMinScale = 0.42;

  _ImSubview _subview = _ImSubview.host;
  _ImSubview _atsReturnSubview = _ImSubview.host;
  _HostTab _hostTab = _HostTab.chats;
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
    if (_subview != _ImSubview.picker || _closeAnimating) {
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
          _subview = _ImSubview.host;
          _pullController.value = 0;
          _closeController.value = 0;
        }
      });
    });
  }

  void _openAtsMiniProgram() {
    setState(() {
      _atsReturnSubview = _subview;
      _subview = _ImSubview.ats;
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

  void _openPlatformMiniProgram() {
    Navigator.of(context).push<void>(PlatformMiniProgram.route());
  }

  void _openSettingsPage() {
    Navigator.of(context).push<void>(_SettingsPage.route());
  }

  void _selectHostTab(_HostTab tab) {
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
        _subview == _ImSubview.host &&
        _hostTab == _HostTab.chats &&
        !_pullAnimating &&
        _hostScrollController.hasClients &&
        _hostScrollController.offset <=
            _hostScrollController.position.minScrollExtent + 0.5;
    _pullVelocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _handlePullPointerMove(PointerMoveEvent event) {
    _pullVelocityTracker?.addPosition(event.timeStamp, event.position);
    if (!_pullPointerCanDrag || _subview != _ImSubview.host || _pullAnimating) {
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
        _subview = target == 1 ? _ImSubview.picker : _ImSubview.host;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _subview == _ImSubview.host &&
          !_pullAnimating &&
          _pullController.value == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        switch (_subview) {
          case _ImSubview.host:
            break;
          case _ImSubview.picker:
            _closeMiniProgramPicker();
          case _ImSubview.ats:
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
        child: _subview == _ImSubview.ats
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
        _subview == _ImSubview.picker ||
        _pullController.value > 0 ||
        _pullAnimating;
    final pickerInteractive =
        _subview == _ImSubview.picker || (_pullAnimating && _pullTarget == 1);
    final showLoadingDots =
        _pullDragging || (_pullAnimating && _pullTarget == 1);
    final hostInteractive = _subview == _ImSubview.host && !pickerInteractive;
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
                child: _MiniProgramPickerPage(
                  key: const ValueKey('customer-mini-program-picker'),
                  onOpenAts: _openAtsMiniProgram,
                  onOpenMerchant: _openMerchantMiniProgram,
                  onOpenPartner: _openPartnerMiniProgram,
                  onOpenHr: _openHrMiniProgram,
                  onOpenPlatform: _openPlatformMiniProgram,
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
                      : _subview == _ImSubview.picker
                      ? 1.0
                      : dragReveal;
                  final opacity = _subview == _ImSubview.picker
                      ? 1.0
                      : progress == 0
                      ? 0.0
                      : 0.12 + 0.88 * scaleProgress;
                  final showingPanel =
                      _subview == _ImSubview.picker ||
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
        if (showLoadingDots && _subview == _ImSubview.host)
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
                final hostProgress = _subview == _ImSubview.picker
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
    if (_hostTab != _HostTab.chats) {
      return _buildUtilityHostPage(context, key: key);
    }
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
      bottomNavigationBar: _WeChatTabBar(
        selected: _hostTab,
        onSelected: _selectHostTab,
      ),
    );
  }

  Widget _buildUtilityHostPage(BuildContext context, {required Key key}) {
    final hostTheme = _weChatHostTheme(context);
    return Theme(
      data: hostTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final title = switch (_hostTab) {
            _HostTab.contacts => '通讯录',
            _HostTab.discover => '发现',
            _HostTab.me => '',
            _HostTab.chats => '',
          };
          final content = switch (_hostTab) {
            _HostTab.contacts => _ContactsPage(
              onTap: (message) => _showHostToast(context, message),
            ),
            _HostTab.discover => _DiscoverPage(
              onTap: (message) => _showHostToast(context, message),
            ),
            _HostTab.me => _MePage(
              onTap: (message) => _showHostToast(context, message),
              onOpenSettings: _openSettingsPage,
            ),
            _HostTab.chats => const SizedBox.shrink(),
          };
          return Scaffold(
            key: key,
            backgroundColor: scheme.surface,
            appBar: _hostTab == _HostTab.me
                ? null
                : AppBar(
                    centerTitle: true,
                    backgroundColor: scheme.surfaceContainerLowest,
                    surfaceTintColor: Colors.transparent,
                    title: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip: '搜索',
                        onPressed: () =>
                            _showHostToast(context, '$title搜索为模拟入口'),
                        icon: const Icon(Icons.search_rounded),
                      ),
                      if (_hostTab == _HostTab.contacts)
                        IconButton(
                          tooltip: '添加',
                          onPressed: () =>
                              _showHostToast(context, '$title添加入口为模拟入口'),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      const SizedBox(width: 6),
                    ],
                    shape: Border(
                      bottom: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
            body: SafeArea(top: _hostTab == _HostTab.me, child: content),
            bottomNavigationBar: _WeChatTabBar(
              selected: _hostTab,
              onSelected: _selectHostTab,
            ),
          );
        },
      ),
    );
  }

  static void _showHostToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

ThemeData _weChatHostTheme(BuildContext context) {
  final accent = Theme.of(context).colorScheme.primary;
  final brightness = Theme.of(context).brightness;
  final baseTheme = ruoQiTheme(brightness: brightness, accent: accent);
  if (brightness == Brightness.light) {
    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFEDEDED),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: const Color(0xFFEDEDED),
        surfaceContainerLowest: const Color(0xFFF7F7F7),
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: const Color(0xFFF2F2F2),
        onSurface: const Color(0xFF111111),
        onSurfaceVariant: const Color(0xFF707070),
        outlineVariant: const Color(0xFFDEDEDE),
      ),
    );
  }
  return baseTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFF181818),
    colorScheme: baseTheme.colorScheme.copyWith(
      surface: const Color(0xFF181818),
      surfaceContainerLowest: const Color(0xFF181818),
      surfaceContainerLow: const Color(0xFF222222),
      surfaceContainer: const Color(0xFF242424),
      surfaceContainerHigh: const Color(0xFF282828),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFA8A8A8),
      outlineVariant: const Color(0xFF303030),
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
