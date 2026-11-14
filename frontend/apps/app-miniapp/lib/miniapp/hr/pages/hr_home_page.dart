part of 'home_pages.dart';

class HrHomePage extends StatelessWidget {
  const HrHomePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    final featured = data.announcements
        .where((item) => item.id == controller.home.featuredAnnouncementId)
        .firstOrNull;

    return RefreshIndicator(
      color: HrColors.resolve(context, HrColors.brand),
      onRefresh: controller.refresh,
      child: ListView(
        key: const Key('hr-home-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          MiniProgramPageHeader(
            title: controller.route.title,
            foregroundColor: HrColors.resolve(context, HrColors.ink),
          ),
          _HomeHeader(controller: controller),
          const SizedBox(height: 18),
          _PunchCard(controller: controller),
          if (controller.user.isManager) ...[
            const SizedBox(height: 14),
            _ApprovalBand(
              pending: controller.approvals.length,
              onTap: () => controller.open(HrRoute.approvals),
            ),
          ],
          const HrSectionHeader(title: '快捷操作'),
          _QuickActions(controller: controller),
          if (controller.home.onLeaveToday.isNotEmpty) ...[
            const SizedBox(height: 18),
            _OnLeaveCard(
              colleagues: controller.home.onLeaveToday,
              onTap: () => controller.open(HrRoute.team),
            ),
          ],
          if (featured != null) ...[
            const SizedBox(height: 20),
            HrCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
              onTap: () => controller.openAnnouncement(featured.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '最新公告',
                          style: HrText.resolve(context, HrText.eyebrow),
                        ),
                      ),
                      InkWell(
                        onTap: () => controller.open(HrRoute.announcements),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '查看全部',
                            style: TextStyle(
                              color: HrColors.resolve(context, HrColors.brand),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    featured.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HrText.resolve(
                      context,
                      HrText.cardTitle,
                    ).copyWith(fontSize: 17, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featured.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HrText.resolve(
                      context,
                      HrText.body,
                    ).copyWith(color: HrColors.resolve(context, HrColors.ink3)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      HrStatusChip(
                        label: featured.category,
                        background: HrColors.resolve(
                          context,
                          HrColors.brandTint,
                        ),
                        foreground: HrColors.resolve(context, HrColors.brand),
                      ),
                      const Spacer(),
                      Text(
                        hrRelative(featured.createdAt),
                        style: HrText.resolve(context, HrText.meta).copyWith(
                          color: HrColors.resolve(context, HrColors.ink4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '早上好'
        : hour < 18
        ? '下午好'
        : '晚上好';
    return Row(
      children: [
        const HrLogoMark(size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: HrText.resolve(
                  context,
                  HrText.meta,
                ).copyWith(fontSize: 11.5),
              ),
              const SizedBox(height: 1),
              Text(
                controller.user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HrText.resolve(
                  context,
                  HrText.appBarTitle,
                ).copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        _HeaderIcon(
          key: const Key('hr-home-notifications'),
          icon: Icons.notifications_none_rounded,
          badge: controller.unreadNotificationCount,
          onTap: () => controller.open(HrRoute.notifications),
        ),
        const SizedBox(width: 9),
        InkWell(
          onTap: () => controller.open(HrRoute.me),
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HrColors.brand,
              shape: BoxShape.circle,
            ),
            child: Text(
              controller.user.name.characters.last,
              style: TextStyle(
                color: HrColors.surface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    super.key,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '消息通知',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: HrColors.resolve(context, HrColors.surface),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: HrColors.resolve(context, HrColors.line)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: HrColors.resolve(context, HrColors.ink),
                size: 21,
              ),
              if (badge > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: HrColors.resolve(context, HrColors.brandLight),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HrColors.resolve(context, HrColors.surface),
                        width: 1.2,
                      ),
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

class _PunchCard extends StatelessWidget {
  const _PunchCard({required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final punch = controller.punch;
    final shift = 8 * 3600;
    final progress = (punch.workedSeconds / shift).clamp(0.0, 1.0);
    final now = DateTime.now();
    final state = punch.isClockedIn ? '今日工作中' : '今日尚未打卡';
    final stateHint = punch.isClockedIn
        ? '距离标准工时还剩 ${hrDuration(math.max(0, shift - punch.workedSeconds))}'
        : '到岗后点击右侧按钮开始计时';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HrColors.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: HrShadows.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${hrDate(now)} ${hrWeekday(now)}'.toUpperCase(),
                  style: HrText.resolve(context, HrText.eyebrow).copyWith(
                    color: HrColors.resolve(context, HrColors.onDark2),
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: HrColors.resolve(context, HrColors.onDarkTile),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: HrColors.resolve(context, HrColors.onDark2),
                    ),
                    SizedBox(width: 3),
                    Text(
                      '考勤范围内',
                      style: TextStyle(
                        color: HrColors.resolve(context, HrColors.onDark2),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state,
                      style: HrText.resolve(context, HrText.meta).copyWith(
                        color: HrColors.resolve(context, HrColors.onDark2),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hrDuration(punch.workedSeconds, withSeconds: true),
                        style: HrText.resolve(context, HrText.mono).copyWith(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stateHint,
                      style: HrText.resolve(context, HrText.meta).copyWith(
                        color: HrColors.resolve(context, HrColors.onDark2),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                button: true,
                label: punch.isClockedIn ? '下班打卡' : '上班打卡',
                child: InkWell(
                  key: const Key('hr-punch-button'),
                  onTap: controller.busy
                      ? null
                      : () => controller.open(HrRoute.punch),
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: CustomPaint(
                      painter: _PunchRingPainter(progress: progress),
                      child: Center(
                        child: Container(
                          width: 93,
                          height: 93,
                          decoration: BoxDecoration(
                            color: punch.isClockedIn
                                ? HrColors.resolve(context, HrColors.surface)
                                : HrColors.resolve(
                                    context,
                                    HrColors.brandLight,
                                  ),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.power_settings_new_rounded,
                                size: 19,
                                color: punch.isClockedIn
                                    ? HrColors.resolve(context, HrColors.ink)
                                    : Colors.white,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                punch.isClockedIn ? '下班打卡' : '上班打卡',
                                style: TextStyle(
                                  color: punch.isClockedIn
                                      ? HrColors.resolve(context, HrColors.ink)
                                      : Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}% / 8h',
                                style: TextStyle(
                                  color:
                                      (punch.isClockedIn
                                              ? HrColors.resolve(
                                                  context,
                                                  HrColors.ink,
                                                )
                                              : Colors.white)
                                          .withValues(alpha: 0.65),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PunchMetric(
                  label: '首次到岗',
                  value: punch.clockInTime ?? '--:--',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _PunchMetric(
                  label: '休息',
                  value: hrDuration(punch.breakSeconds),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _PunchMetric(
                  label: '加班',
                  value: hrDuration(punch.overtimeSeconds),
                  accent: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PunchMetric extends StatelessWidget {
  const _PunchMetric({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
      decoration: BoxDecoration(
        color: HrColors.resolve(context, HrColors.onDarkTile),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizeMiniProgramLabel(context, label),
            maxLines: 1,
            style: HrText.resolve(context, HrText.eyebrow).copyWith(
              color: HrColors.resolve(context, HrColors.onDark2),
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: HrText.resolve(context, HrText.mono).copyWith(
                color: accent ? const Color(0xFF62C99A) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PunchRingPainter extends CustomPainter {
  const _PunchRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const band = 7.5;
    final rect = (Offset.zero & size).deflate(band / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band
      ..color = HrColors.onDarkLine;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress <= 0) {
      return;
    }
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band
      ..color = HrColors.brandLight;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(_PunchRingPainter old) => old.progress != progress;
}

class _ApprovalBand extends StatelessWidget {
  const _ApprovalBand({required this.pending, required this.onTap});

  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      key: const Key('hr-home-approvals'),
      onTap: onTap,
      shadow: false,
      background: HrColors.resolve(context, HrColors.warningBg),
      borderColor: HrColors.resolve(context, HrColors.warningBorder),
      padding: const EdgeInsets.fromLTRB(18, 15, 14, 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pending 个申请等待你审批',
                  style: HrText.resolve(context, HrText.cardTitle).copyWith(
                    color: HrColors.resolve(context, HrColors.warningInk),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '请假 1 · 办公方式 1 · 报销 1 · 补卡 1',
                  style: HrText.resolve(context, HrText.meta).copyWith(
                    color: HrColors.resolve(context, HrColors.warningInk),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: HrColors.resolve(context, HrColors.warningInk),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickActionData>[
      _QuickActionData(
        label: '发起请假',
        icon: Icons.event_available_outlined,
        color: HrColors.resolve(context, HrColors.brand),
        background: HrColors.resolve(context, HrColors.brandTint),
        onTap: () => controller.open(HrRoute.leaveApply),
      ),
      _QuickActionData(
        label: '休假额度',
        icon: Icons.donut_large_outlined,
        color: HrColors.resolve(context, HrColors.success),
        background: HrColors.resolve(context, HrColors.successBg),
        onTap: () => controller.open(HrRoute.leave),
      ),
      _QuickActionData(
        label: '我的考勤',
        icon: Icons.schedule_outlined,
        color: HrColors.resolve(context, HrColors.warning),
        background: HrColors.resolve(context, HrColors.warningBg),
        onTap: () => controller.switchTab(1),
      ),
      _QuickActionData(
        label: '企业通讯录',
        icon: Icons.people_outline_rounded,
        color: HrColors.resolve(context, HrColors.info),
        background: HrColors.resolve(context, HrColors.infoBg),
        onTap: () => controller.open(HrRoute.directory),
      ),
      _QuickActionData(
        label: '工资单',
        icon: Icons.receipt_long_outlined,
        color: HrColors.resolve(context, HrColors.warning),
        background: HrColors.resolve(context, HrColors.warningBg),
        onTap: () => controller.open(HrRoute.payslips),
      ),
      _QuickActionData(
        label: '新建申请',
        icon: Icons.add_rounded,
        color: HrColors.resolve(context, HrColors.brand),
        background: HrColors.resolve(context, HrColors.brandTint),
        onTap: () => controller.composeRequest(),
      ),
      _QuickActionData(
        label: '审批中心',
        icon: Icons.approval_outlined,
        color: HrColors.resolve(context, HrColors.info),
        background: HrColors.resolve(context, HrColors.infoBg),
        onTap: () => controller.open(HrRoute.approvals),
      ),
      _QuickActionData(
        label: '公司公告',
        icon: Icons.campaign_outlined,
        color: HrColors.resolve(context, HrColors.success),
        background: HrColors.resolve(context, HrColors.successBg),
        onTap: () => controller.open(HrRoute.announcements),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 98,
        crossAxisSpacing: 9,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          key: Key('hr-quick-${action.label}'),
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: action.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(action.icon, color: action.color, size: 25),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HrText.resolve(
                  context,
                  HrText.cardTitle,
                ).copyWith(fontSize: 11.5),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
}

class _OnLeaveCard extends StatelessWidget {
  const _OnLeaveCard({required this.colleagues, required this.onTap});

  final List<HrOnLeave> colleagues;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            height: 40,
            child: Stack(
              children: [
                for (var i = 0; i < colleagues.length; i++)
                  Positioned(
                    left: i * 28,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: HrColors.resolve(context, HrColors.surface),
                        shape: BoxShape.circle,
                      ),
                      child: HrAvatar(
                        name: colleagues[i].name,
                        index: i,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${colleagues.length} 位同事今天休假',
                  style: HrText.resolve(
                    context,
                    HrText.cardTitle,
                  ).copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  colleagues.map((item) => item.name).join('、'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HrText.resolve(context, HrText.meta),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: HrColors.resolve(context, HrColors.ink4),
          ),
        ],
      ),
    );
  }
}
