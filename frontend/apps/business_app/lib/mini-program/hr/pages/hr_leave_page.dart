part of 'time_pages.dart';

class HrLeavePage extends StatelessWidget {
  const HrLeavePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('hr-leave-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '我的休假',
                style: HrText.appBarTitle.copyWith(fontSize: 25),
              ),
            ),
            HrStatusChip(
              label: '${controller.leaveBalances.length} 类额度',
              background: HrColors.brandTint,
              foreground: HrColors.brand,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 9.0;
            final width = (constraints.maxWidth - gap * 2) / 3;
            return Row(
              children: [
                for (var i = 0; i < controller.leaveBalances.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: width,
                    child: _BalanceCard(balance: controller.leaveBalances[i]),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        HrPrimaryButton(
          label: '发起请假',
          icon: Icons.add_rounded,
          onPressed: () => controller.open(HrRoute.leaveApply),
        ),
        const SizedBox(height: 12),
        HrCard(
          onTap: () => controller.open(HrRoute.leaveAllocation),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HrColors.infoBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add_card_outlined,
                  color: HrColors.info,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('额度追加申请', style: HrText.cardTitle),
                    SizedBox(height: 2),
                    Text('向 HR 申请额外假期额度', style: HrText.meta),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: HrColors.ink4),
            ],
          ),
        ),
        HrSectionHeader(
          title: '我的申请',
          padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
          action: '新建',
          onAction: () => controller.open(HrRoute.leaveApply),
        ),
        for (final request in controller.leaveRequests) ...[
          _LeaveRequestCard(request: request),
          const SizedBox(height: 10),
        ],
        if (controller.holidays.isNotEmpty) ...[
          const HrSectionHeader(title: '即将到来的假期'),
          HrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < controller.holidays.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: HrColors.line2,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: HrColors.brandTint,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            '${controller.holidays[i].date.month}/${controller.holidays[i].date.day}',
                            style: const TextStyle(
                              color: HrColors.brand,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.holidays[i].name,
                                style: HrText.cardTitle.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.holidays[i].description,
                                style: HrText.meta,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final HrLeaveBalance balance;

  static const _colors = [HrColors.brand, HrColors.info, HrColors.success];

  @override
  Widget build(BuildContext context) {
    final color = _colors[balance.colorIndex % _colors.length];
    final fraction =
        (balance.availableDays / (balance.availableDays + balance.usedDays))
            .clamp(0.0, 1.0);
    return HrCard(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 13),
      child: Column(
        children: [
          SizedBox(
            width: 66,
            height: 66,
            child: CustomPaint(
              painter: _DonutPainter(color: color, fraction: fraction),
              child: Center(
                child: Text(
                  _number(balance.availableDays),
                  style: HrText.mono.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            balance.type,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HrText.cardTitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '天可用',
            style: HrText.meta.copyWith(fontSize: 10, color: HrColors.ink4),
          ),
        ],
      ),
    );
  }

  static String _number(double value) =>
      value == value.roundToDouble() ? '${value.toInt()}' : '$value';
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.color, required this.fraction});

  final Color color;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = HrColors.line;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (fraction <= 0) {
      return;
    }
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, fill);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.fraction != fraction || old.color != color;
}

class _LeaveRequestCard extends StatelessWidget {
  const _LeaveRequestCard({required this.request});

  final HrLeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (request.status) {
      HrLeaveStatus.approved => (HrColors.successBg, HrColors.success),
      HrLeaveStatus.pending => (HrColors.warningBg, HrColors.warning),
      HrLeaveStatus.rejected => (HrColors.dangerBg, HrColors.danger),
      HrLeaveStatus.cancelled => (HrColors.bg2, HrColors.ink3),
    };
    return HrCard(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.type}${request.halfDay ? ' · 半天' : ''}',
                  style: HrText.cardTitle.copyWith(fontSize: 14.5),
                ),
              ),
              HrStatusChip(
                label: request.status.label,
                background: background,
                foreground: foreground,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${hrDateRange(request.startDate, request.endDate)} · '
            '${_days(request.days)}',
            style: HrText.body.copyWith(color: HrColors.ink3),
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: HrColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(request.reason, style: HrText.meta),
            ),
          ],
        ],
      ),
    );
  }

  static String _days(double days) =>
      days == days.roundToDouble() ? '${days.toInt()} 天' : '$days 天';
}
