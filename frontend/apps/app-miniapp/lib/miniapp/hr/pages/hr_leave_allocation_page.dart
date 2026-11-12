part of 'service_pages.dart';

class HrLeaveAllocationPage extends StatefulWidget {
  const HrLeaveAllocationPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrLeaveAllocationPage> createState() => _HrLeaveAllocationPageState();
}

class _HrLeaveAllocationPageState extends State<HrLeaveAllocationPage> {
  final _reason = TextEditingController();
  String _type = '年假';
  double _days = 1;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('额度追加申请', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('额外假期额度由 HR 审批，不进入直属主管审批流。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('假期类型', style: HrText.eyebrow),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in ['年假', '病假', '调休', '事假'])
                    ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      showCheckmark: false,
                      selectedColor: HrColors.brandTint,
                      backgroundColor: HrColors.bg2,
                      side: BorderSide(
                        color: _type == type
                            ? HrColors.brandTintBorder
                            : HrColors.line,
                      ),
                      labelStyle: TextStyle(
                        color: _type == type ? HrColors.brand : HrColors.ink3,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('申请天数', style: HrText.eyebrow),
                        const SizedBox(height: 6),
                        Text(
                          _days == _days.roundToDouble()
                              ? _days.toStringAsFixed(0)
                              : _days.toStringAsFixed(1),
                          style: HrText.mono.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: _days > 0.5
                        ? () => setState(() => _days -= 0.5)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _days += 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: HrColors.line2),
              const SizedBox(height: 12),
              Text(
                '当前 $_type 余额 '
                '${_currentBalance(widget.controller, _type)} 天',
                style: HrText.meta,
              ),
            ],
          ),
        ),
        const HrSectionHeader(
          title: '申请原因',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        TextField(
          controller: _reason,
          minLines: 4,
          maxLines: 6,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: '请说明需要额外额度的原因',
            counterStyle: HrText.meta,
          ),
        ),
        const SizedBox(height: 14),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交 HR 审批',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_reason.text.trim().isEmpty) {
      hrToast(context, '请填写额度追加原因');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submitLeaveAllocation(
        type: _type,
        days: _days,
        reason: _reason.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '$_type额度追加申请已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  static String _currentBalance(HrAppController controller, String type) {
    for (final balance in controller.leaveBalances) {
      if (balance.type == type) {
        return balance.availableDays == balance.availableDays.roundToDouble()
            ? '${balance.availableDays.toInt()}'
            : '${balance.availableDays}';
      }
    }
    return '--';
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HrColors.line),
        ),
        child: Icon(
          icon,
          size: 19,
          color: onTap == null ? HrColors.ink4 : HrColors.ink,
        ),
      ),
    );
  }
}
