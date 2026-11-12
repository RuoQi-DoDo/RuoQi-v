part of 'service_pages.dart';

class HrHelpdeskPage extends StatefulWidget {
  const HrHelpdeskPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrHelpdeskPage> createState() => _HrHelpdeskPageState();
}

class _HrHelpdeskPageState extends State<HrHelpdeskPage> {
  final _subject = TextEditingController();
  final _description = TextEditingController();
  String _category = '人事政策';
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          '员工服务台',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '找不到入口或需要人工协助，可以在这里提交服务工单。',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('问题类型', style: HrText.resolve(context, HrText.eyebrow)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ['人事政策', '考勤异常', '薪酬福利', '系统故障'])
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      showCheckmark: false,
                      selectedColor: HrColors.resolve(
                        context,
                        HrColors.brandTint,
                      ),
                      backgroundColor: HrColors.resolve(context, HrColors.bg2),
                      side: BorderSide(
                        color: _category == category
                            ? HrColors.resolve(
                                context,
                                HrColors.brandTintBorder,
                              )
                            : HrColors.resolve(context, HrColors.line),
                      ),
                      labelStyle: TextStyle(
                        color: _category == category
                            ? HrColors.resolve(context, HrColors.brand)
                            : HrColors.resolve(context, HrColors.ink3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(
                  labelText: '问题标题',
                  hintText: '用一句话描述你的问题',
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _description,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: '详细说明',
                  hintText: '补充发生时间、相关页面和期望处理方式',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HrCard(
          background: HrColors.resolve(context, HrColors.infoBg),
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: HrColors.resolve(context, HrColors.info),
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '服务时间为工作日 09:00 - 18:00，通常会在 1 个工作日内回复。',
                  style: HrText.resolve(
                    context,
                    HrText.meta,
                  ).copyWith(color: HrColors.resolve(context, HrColors.info)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交服务工单',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _description.text.trim().isEmpty) {
      hrToast(context, '请填写问题标题和详细说明');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submitHelpdeskTicket(
        category: _category,
        subject: _subject.text.trim(),
        description: _description.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '服务工单已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
