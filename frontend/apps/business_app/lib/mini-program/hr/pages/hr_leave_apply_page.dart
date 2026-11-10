part of 'time_pages.dart';

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
