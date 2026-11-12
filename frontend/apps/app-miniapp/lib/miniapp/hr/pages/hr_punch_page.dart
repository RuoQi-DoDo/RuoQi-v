part of 'punch_pages.dart';

class HrPunchPage extends StatefulWidget {
  const HrPunchPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrPunchPage> createState() => _HrPunchPageState();
}

class _HrPunchPageState extends State<HrPunchPage> {
  late final Timer _timer;
  DateTime _now = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final punch = widget.controller.punch;
    final clockIn = !punch.isClockedIn;
    final progress = (punch.workedSeconds / (8 * 3600)).clamp(0.0, 1.0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '上下班打卡',
                style: HrText.resolve(
                  context,
                  HrText.appBarTitle,
                ).copyWith(fontSize: 25),
              ),
            ),
            HrStatusChip(
              label: punch.inGeofence ? '考勤范围内' : '超出范围',
              background: punch.inGeofence
                  ? HrColors.resolve(context, HrColors.successBg)
                  : HrColors.resolve(context, HrColors.dangerBg),
              foreground: punch.inGeofence
                  ? HrColors.resolve(context, HrColors.success)
                  : HrColors.resolve(context, HrColors.danger),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${hrDate(_now, withYear: true)} ${hrWeekday(_now)}',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: HrColors.ink,
            borderRadius: BorderRadius.circular(28),
            boxShadow: HrShadows.hero,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前时间',
                          style: HrText.resolve(context, HrText.eyebrow)
                              .copyWith(
                                color: HrColors.resolve(
                                  context,
                                  HrColors.onDark2,
                                ),
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _clock(_now),
                          style: HrText.resolve(context, HrText.mono).copyWith(
                            color: Colors.white,
                            fontSize: 33,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 102,
                    height: 102,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 98,
                          height: 98,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            backgroundColor: HrColors.resolve(
                              context,
                              HrColors.onDarkLine,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              HrColors.resolve(context, HrColors.brandLight),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: HrText.resolve(context, HrText.mono)
                                  .copyWith(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              '今日工时',
                              style: HrText.resolve(context, HrText.meta)
                                  .copyWith(
                                    color: HrColors.resolve(
                                      context,
                                      HrColors.onDark2,
                                    ),
                                    fontSize: 9.5,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: HrColors.resolve(context, HrColors.onDarkLine),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DarkMetric(
                      label: '工作计时',
                      value: hrDuration(punch.workedSeconds, withSeconds: true),
                    ),
                  ),
                  Expanded(
                    child: _DarkMetric(
                      label: '首次到岗',
                      value: punch.clockInTime ?? '--:--',
                    ),
                  ),
                  Expanded(
                    child: _DarkMetric(
                      label: '今日加班',
                      value: hrDuration(punch.overtimeSeconds),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: HrColors.resolve(context, HrColors.successBg),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: HrColors.resolve(context, HrColors.success),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      punch.location,
                      style: HrText.resolve(
                        context,
                        HrText.cardTitle,
                      ).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '定位精度 18 米 · 已进入公司考勤围栏',
                      style: HrText.resolve(context, HrText.meta),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: HrColors.resolve(context, HrColors.success),
                size: 21,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HrCard(
          background: HrColors.resolve(context, HrColors.warningBg),
          borderColor: HrColors.resolve(context, HrColors.warningBorder),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: HrColors.resolve(context, HrColors.warningInk),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  punch.isClockedIn
                      ? '你已上班打卡。下班前请确认当天工作与休息时间，打卡后会同步到考勤记录。'
                      : '尚未上班打卡。默认班次为 09:00 - 18:00，班次可在考勤详情中查看。',
                  style: HrText.resolve(context, HrText.meta).copyWith(
                    color: HrColors.resolve(context, HrColors.warningInk),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HrPrimaryButton(
          label: _submitting
              ? '正在打卡…'
              : clockIn
              ? '确认上班打卡'
              : '确认下班打卡',
          icon: Icons.fingerprint_rounded,
          onPressed: _submitting ? null : _submit,
        ),
        const SizedBox(height: 10),
        HrOutlineButton(
          label: '人脸核验后打卡',
          icon: Icons.face_retouching_natural,
          onPressed: _submitting
              ? null
              : () => widget.controller.open(HrRoute.faceCheck),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final clockIn = !widget.controller.punch.isClockedIn;
    setState(() => _submitting = true);
    try {
      final ok = await widget.controller.punchNow();
      if (!mounted) {
        return;
      }
      if (ok) {
        widget.controller.back();
        hrToast(context, clockIn ? '上班打卡成功' : '下班打卡成功');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  static String _clock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';
}

class _DarkMetric extends StatelessWidget {
  const _DarkMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HrText.resolve(context, HrText.meta).copyWith(
            color: HrColors.resolve(context, HrColors.onDark2),
            fontSize: 9.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: HrText.resolve(context, HrText.mono).copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
