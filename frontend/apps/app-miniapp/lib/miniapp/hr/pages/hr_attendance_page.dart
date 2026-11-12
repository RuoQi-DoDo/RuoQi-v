part of 'time_pages.dart';

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
      color: HrColors.resolve(context, HrColors.brand),
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
                  style: HrText.resolve(
                    context,
                    HrText.appBarTitle,
                  ).copyWith(fontSize: 25),
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
                    color: HrColors.resolve(context, HrColors.surface),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: HrColors.resolve(context, HrColors.line),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${selectedMonth.month}月',
                        style: TextStyle(
                          color: HrColors.resolve(context, HrColors.brand),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: HrColors.resolve(context, HrColors.brand),
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
                    Divider(
                      height: 1,
                      color: HrColors.resolve(context, HrColors.line2),
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
            style: HrText.resolve(
              context,
              HrText.meta,
            ).copyWith(color: HrColors.resolve(context, HrColors.ink4)),
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
                    color: HrColors.resolve(context, HrColors.brandTint),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.beach_access_outlined,
                    color: HrColors.resolve(context, HrColors.brand),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的休假',
                        style: HrText.resolve(context, HrText.cardTitle),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '年假剩余 8 天 · 病假剩余 6 天',
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
          Text('月度工时', style: HrText.resolve(context, HrText.eyebrow)),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  hrMinutes(data.workedMinutes),
                  style: HrText.resolve(context, HrText.mono).copyWith(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              Text(
                '目标 ${data.expectedHours} 小时',
                style: HrText.resolve(context, HrText.meta),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: HrColors.resolve(context, HrColors.bg2),
              valueColor: AlwaysStoppedAnimation(
                HrColors.resolve(context, HrColors.brand),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Metric(label: '出勤', value: '${data.presentDays} 天'),
              _Metric(
                label: '迟到',
                value: '${data.lateIns} 次',
                color: data.lateIns > 0
                    ? HrColors.resolve(context, HrColors.warning)
                    : HrColors.resolve(context, HrColors.ink),
              ),
              _Metric(
                label: '早退',
                value: '${data.earlyOuts} 次',
                color: data.earlyOuts > 0
                    ? HrColors.resolve(context, HrColors.warning)
                    : HrColors.resolve(context, HrColors.ink),
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
          Text(
            label,
            style: HrText.resolve(context, HrText.meta).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: HrText.resolve(
              context,
              HrText.mono,
            ).copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: color),
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
              Expanded(
                child: Text(
                  '本周工时',
                  style: TextStyle(
                    color: HrColors.resolve(context, HrColors.ink),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${hrWeekday(today)} · ${hrMinutes(values[todayIndex])}',
                style: HrText.resolve(context, HrText.mono).copyWith(
                  color: HrColors.resolve(context, HrColors.ink),
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
                                  ? HrColors.resolve(context, HrColors.line2)
                                  : const Color(0xFFF2D4CE),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            hrWeekdayShort(week[i]),
                            style: HrText.resolve(context, HrText.mono)
                                .copyWith(
                                  color: i == todayIndex
                                      ? HrColors.resolve(
                                          context,
                                          HrColors.brand,
                                        )
                                      : HrColors.resolve(
                                          context,
                                          HrColors.ink4,
                                        ),
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
                    style: HrText.resolve(
                      context,
                      HrText.mono,
                    ).copyWith(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    hrWeekdayShort(day.date),
                    style: HrText.resolve(context, HrText.meta).copyWith(
                      fontSize: 10,
                      color: HrColors.resolve(context, HrColors.ink4),
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
                    style: HrText.resolve(
                      context,
                      HrText.mono,
                    ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        day.shift,
                        style: HrText.resolve(context, HrText.meta),
                      ),
                      if (day.late) ...[
                        const SizedBox(width: 6),
                        HrStatusChip(
                          label: '迟到',
                          background: HrColors.resolve(
                            context,
                            HrColors.warningBg,
                          ),
                          foreground: HrColors.resolve(
                            context,
                            HrColors.warning,
                          ),
                        ),
                      ],
                      if (day.earlyOut) ...[
                        const SizedBox(width: 4),
                        HrStatusChip(
                          label: '早退',
                          background: HrColors.resolve(
                            context,
                            HrColors.warningBg,
                          ),
                          foreground: HrColors.resolve(
                            context,
                            HrColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              hrDuration(day.workedMinutes * 60),
              style: HrText.resolve(
                context,
                HrText.mono,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: HrColors.resolve(context, HrColors.ink4),
            ),
          ],
        ),
      ),
    );
  }
}
