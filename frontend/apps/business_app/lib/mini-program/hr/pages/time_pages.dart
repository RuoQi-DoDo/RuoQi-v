import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hr_controller.dart';
import '../hr_format.dart';
import '../hr_models.dart';
import '../hr_routes.dart';
import '../hr_style.dart';

class HrAttendancePage extends StatefulWidget {
  const HrAttendancePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrAttendancePage> createState() => _HrAttendancePageState();
}

class _HrAttendancePageState extends State<HrAttendancePage> {
  int _monthOffset = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.attendance;
    final selectedMonth = DateTime(
      data.month.year,
      data.month.month + _monthOffset,
    );
    return RefreshIndicator(
      color: HrColors.brand,
      onRefresh: widget.controller.refresh,
      child: ListView(
        key: const Key('hr-attendance-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '我的考勤',
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              InkWell(
                onTap: () => _showMonthPicker(selectedMonth),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: HrColors.surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: HrColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${selectedMonth.month}月',
                        style: const TextStyle(
                          color: HrColors.brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: HrColors.brand,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HourAccountCard(data: data),
          const SizedBox(height: 14),
          _WeekChart(days: data.days),
          HrSectionHeader(
            title: '考勤明细',
            action: '补卡申请',
            onAction: () {
              widget.controller.selectAttendanceDate(DateTime.now());
            },
          ),
          HrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.days.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      color: HrColors.line2,
                      indent: 16,
                      endIndent: 16,
                    ),
                  _AttendanceRow(
                    day: data.days[i],
                    onTap: () => widget.controller.selectAttendanceDate(
                      data.days[i].date,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '点击任意日期可发起补卡申请',
            textAlign: TextAlign.center,
            style: HrText.meta.copyWith(color: HrColors.ink4),
          ),
          HrSectionHeader(
            title: '休假与缺勤',
            action: '查看休假',
            onAction: () => widget.controller.open(HrRoute.leave),
          ),
          HrCard(
            onTap: () => widget.controller.open(HrRoute.leave),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: HrColors.brandTint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.beach_access_outlined,
                    color: HrColors.brand,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('我的休假', style: HrText.cardTitle),
                      SizedBox(height: 3),
                      Text('年假剩余 8 天 · 病假剩余 6 天', style: HrText.meta),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: HrColors.ink4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthPicker(DateTime selected) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: HrColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: HrColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              for (var offset = 0; offset >= -5; offset--)
                ListTile(
                  title: Text(
                    '${DateTime(selected.year, selected.month + offset).year} 年 '
                    '${DateTime(selected.year, selected.month + offset).month} 月',
                    style: HrText.cardTitle,
                  ),
                  trailing: offset == _monthOffset
                      ? const Icon(Icons.check, color: HrColors.brand)
                      : null,
                  onTap: () => Navigator.of(context).pop(offset),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _monthOffset = picked);
    }
  }
}

class _HourAccountCard extends StatelessWidget {
  const _HourAccountCard({required this.data});

  final HrAttendanceSnapshot data;

  @override
  Widget build(BuildContext context) {
    final expectedMinutes = data.expectedHours * 60;
    final progress = (data.workedMinutes / expectedMinutes).clamp(0.0, 1.0);
    return HrCard(
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('月度工时', style: HrText.eyebrow),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  hrMinutes(data.workedMinutes),
                  style: HrText.mono.copyWith(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Text('目标 ${data.expectedHours} 小时', style: HrText.meta),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: HrColors.bg2,
              valueColor: const AlwaysStoppedAnimation(HrColors.brand),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Metric(label: '出勤', value: '${data.presentDays} 天'),
              _Metric(
                label: '迟到',
                value: '${data.lateIns} 次',
                color: data.lateIns > 0 ? HrColors.warning : HrColors.ink,
              ),
              _Metric(
                label: '早退',
                value: '${data.earlyOuts} 次',
                color: data.earlyOuts > 0 ? HrColors.warning : HrColors.ink,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.color = HrColors.ink,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: HrText.meta.copyWith(fontSize: 11)),
          const SizedBox(height: 3),
          Text(
            value,
            style: HrText.mono.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.days});

  final List<HrAttendanceDay> days;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final week = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    int minutesOn(DateTime date) {
      for (final day in days) {
        if (_sameDay(day.date, date)) {
          return day.workedMinutes;
        }
      }
      return 0;
    }

    final values = [for (final date in week) minutesOn(date)];
    final maxMinutes = values.fold<int>(9 * 60, math.max);
    final todayIndex = today.weekday - 1;
    return HrCard(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '本周工时',
                  style: TextStyle(
                    color: HrColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${hrWeekday(today)} · ${hrMinutes(values[todayIndex])}',
                style: HrText.mono.copyWith(
                  color: HrColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 122,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < week.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            height: values[i] == 0
                                ? 5
                                : 86 * (values[i] / maxMinutes),
                            decoration: BoxDecoration(
                              color: i == todayIndex
                                  ? HrColors.brand
                                  : values[i] == 0
                                  ? HrColors.line2
                                  : const Color(0xFFF2D4CE),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            hrWeekdayShort(week[i]),
                            style: HrText.mono.copyWith(
                              color: i == todayIndex
                                  ? HrColors.brand
                                  : HrColors.ink4,
                              fontSize: 10,
                              fontWeight: i == todayIndex
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.day, required this.onTap});

  final HrAttendanceDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  Text(
                    day.date.day.toString(),
                    style: HrText.mono.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    hrWeekdayShort(day.date),
                    style: HrText.meta.copyWith(
                      fontSize: 10,
                      color: HrColors.ink4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.clockIn ?? '--:--'}  -  ${day.clockOut ?? '工作中'}',
                    style: HrText.mono.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(day.shift, style: HrText.meta),
                      if (day.late) ...[
                        const SizedBox(width: 6),
                        const HrStatusChip(
                          label: '迟到',
                          background: HrColors.warningBg,
                          foreground: HrColors.warning,
                        ),
                      ],
                      if (day.earlyOut) ...[
                        const SizedBox(width: 4),
                        const HrStatusChip(
                          label: '早退',
                          background: HrColors.warningBg,
                          foreground: HrColors.warning,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              hrDuration(day.workedMinutes * 60),
              style: HrText.mono.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: HrColors.ink4,
            ),
          ],
        ),
      ),
    );
  }
}

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

class HrLeaveApplyPage extends StatefulWidget {
  const HrLeaveApplyPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrLeaveApplyPage> createState() => _HrLeaveApplyPageState();
}

class _HrLeaveApplyPageState extends State<HrLeaveApplyPage> {
  final _reason = TextEditingController();
  String _type = '年假';
  DateTime _start = DateTime.now().add(const Duration(days: 1));
  DateTime _end = DateTime.now().add(const Duration(days: 1));
  bool _halfDay = false;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _halfDay ? 0.5 : _workdays(_start, _end);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('发起请假', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('请选择假期类型与时间，提交后将进入直属主管审批。', style: HrText.meta),
        const HrSectionHeader(
          title: '假期类型',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ['年假', '病假', '调休', '事假'])
              ChoiceChip(
                label: Text(type),
                selected: _type == type,
                onSelected: (_) => setState(() => _type = type),
                selectedColor: HrColors.brandTint,
                backgroundColor: HrColors.surface,
                side: BorderSide(
                  color: _type == type
                      ? HrColors.brandTintBorder
                      : HrColors.line,
                ),
                labelStyle: TextStyle(
                  color: _type == type ? HrColors.brand : HrColors.ink3,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
        const HrSectionHeader(
          title: '请假时间',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _DateRow(
                label: '开始日期',
                value: '${hrDate(_start)} ${hrWeekday(_start)}',
                onTap: () => _pickDate(start: true),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              _DateRow(
                label: '结束日期',
                value: '${hrDate(_end)} ${hrWeekday(_end)}',
                enabled: !_halfDay,
                onTap: _halfDay ? null : () => _pickDate(start: false),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              SwitchListTile.adaptive(
                value: _halfDay,
                onChanged: (value) => setState(() {
                  _halfDay = value;
                  if (value) {
                    _end = _start;
                  }
                }),
                activeTrackColor: HrColors.brand,
                title: const Text(
                  '仅半天',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('半天请假按 0.5 天计算', style: HrText.meta),
              ),
            ],
          ),
        ),
        HrCard(
          margin: const EdgeInsets.only(top: 12),
          background: HrColors.warningBg,
          borderColor: HrColors.warningBorder,
          shadow: false,
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: HrColors.warningInk,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '本次预计请假 $days 天，剩余额度会在审批通过后扣减。',
                  style: HrText.meta.copyWith(
                    color: HrColors.warningInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const HrSectionHeader(
          title: '请假事由',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        TextField(
          controller: _reason,
          minLines: 4,
          maxLines: 6,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: '请简要说明请假原因',
            counterStyle: HrText.meta,
          ),
        ),
        const SizedBox(height: 14),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交审批',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : () => _submit(days),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: start ? '选择开始日期' : '选择结束日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (start) {
        _start = picked;
        if (_end.isBefore(picked)) {
          _end = picked;
        }
      } else {
        _end = picked.isBefore(_start) ? _start : picked;
      }
    });
  }

  Future<void> _submit(double days) async {
    setState(() => _submitting = true);
    try {
      await widget.controller.submitLeave(
        type: _type,
        startDate: _start,
        endDate: _end,
        reason: _reason.text,
        halfDay: _halfDay,
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '请假申请已提交 · $days 天');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  static double _workdays(DateTime start, DateTime end) {
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    var days = 0;
    while (!cursor.isAfter(last)) {
      if (cursor.weekday <= DateTime.friday) {
        days++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return math.max(1, days).toDouble();
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Text(
              label,
              style: HrText.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              value,
              style: HrText.mono.copyWith(
                color: enabled ? HrColors.ink2 : HrColors.ink4,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.calendar_month_outlined,
              size: 17,
              color: enabled ? HrColors.brand : HrColors.ink4,
            ),
          ],
        ),
      ),
    );
  }
}

class HrCorrectionPage extends StatefulWidget {
  const HrCorrectionPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrCorrectionPage> createState() => _HrCorrectionPageState();
}

class _HrCorrectionPageState extends State<HrCorrectionPage> {
  final _clockIn = TextEditingController(text: '09:04');
  final _clockOut = TextEditingController(text: '18:10');
  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _clockIn.dispose();
    _clockOut.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.controller.selectedAttendanceDate;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('补卡申请', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        Text(
          '${hrDate(date, withYear: true)} · ${hrWeekday(date)}',
          style: HrText.meta,
        ),
        const SizedBox(height: 18),
        HrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('更正打卡时间', style: HrText.cardTitle),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _clockIn,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: '上班时间',
                        hintText: '09:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _clockOut,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: '下班时间',
                        hintText: '18:00',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const HrSectionHeader(
          title: '补卡原因',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        TextField(
          controller: _reason,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(hintText: '例如：下班离开工位时忘记打卡'),
        ),
        const SizedBox(height: 14),
        HrCard(
          background: HrColors.infoBg,
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: HrColors.info, size: 19),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '补卡申请会同时通知直属主管与 HR。每人每月最多可发起 3 次。',
                  style: HrText.meta.copyWith(color: HrColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交补卡申请',
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_clockIn.text.trim().isEmpty || _clockOut.text.trim().isEmpty) {
      hrToast(context, '请填写完整的打卡时间');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submitCorrection(
        clockIn: _clockIn.text.trim(),
        clockOut: _clockOut.text.trim(),
        reason: _reason.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '补卡申请已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
