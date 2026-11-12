part of 'time_pages.dart';

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
        Text(
          '补卡申请',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '${hrDate(date, withYear: true)} · ${hrWeekday(date)}',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 18),
        HrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('更正打卡时间', style: HrText.resolve(context, HrText.cardTitle)),
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
          background: HrColors.resolve(context, HrColors.infoBg),
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: HrColors.resolve(context, HrColors.info),
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '补卡申请会同时通知直属主管与 HR。每人每月最多可发起 3 次。',
                  style: HrText.resolve(
                    context,
                    HrText.meta,
                  ).copyWith(color: HrColors.resolve(context, HrColors.info)),
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
