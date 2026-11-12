part of 'request_pages.dart';

class HrRequestComposePage extends StatefulWidget {
  const HrRequestComposePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrRequestComposePage> createState() => _HrRequestComposePageState();
}

class _HrRequestComposePageState extends State<HrRequestComposePage> {
  late HrRequestKind _kind;
  final _title = TextEditingController();
  final _detail = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _shift = '常规班次';
  String _workType = '远程办公';
  String _asset = '外接显示器';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.controller.requestKind;
  }

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          '新建申请',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '选择申请类型，填写必要信息后提交审批。',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in HrRequestKind.values)
              ChoiceChip(
                label: Text(kind.shortLabel),
                selected: _kind == kind,
                showCheckmark: false,
                selectedColor: HrColors.resolve(context, HrColors.brandTint),
                backgroundColor: HrColors.resolve(context, HrColors.surface),
                side: BorderSide(
                  color: _kind == kind
                      ? HrColors.resolve(context, HrColors.brandTintBorder)
                      : HrColors.resolve(context, HrColors.line),
                ),
                labelStyle: TextStyle(
                  color: _kind == kind
                      ? HrColors.resolve(context, HrColors.brand)
                      : HrColors.resolve(context, HrColors.ink3),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                onSelected: (_) => setState(() => _kind = kind),
              ),
          ],
        ),
        const SizedBox(height: 16),
        HrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _kind.label,
                style: HrText.resolve(context, HrText.cardTitle),
              ),
              const SizedBox(height: 4),
              Text(
                _kind.description,
                style: HrText.resolve(context, HrText.meta),
              ),
              const SizedBox(height: 16),
              if (_kind == HrRequestKind.shift) ...[
                _PickerRow(
                  label: '调整班次',
                  value: _shift,
                  options: const ['常规班次', '晚班', '周末班'],
                  onChanged: (value) => setState(() => _shift = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.workType) ...[
                _PickerRow(
                  label: '办公方式',
                  value: _workType,
                  options: const ['远程办公', '办公室办公', '混合办公'],
                  onChanged: (value) => setState(() => _workType = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.asset) ...[
                _PickerRow(
                  label: '申请资产',
                  value: _asset,
                  options: const ['外接显示器', '笔记本电脑', '键盘鼠标', '耳机'],
                  onChanged: (value) => setState(() => _asset = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind != HrRequestKind.asset) ...[
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: HrColors.resolve(context, HrColors.bg2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '生效日期',
                          style: HrText.resolve(context, HrText.meta),
                        ),
                        const Spacer(),
                        Text(
                          '${hrDate(_date)} ${hrWeekday(_date)}',
                          style: HrText.resolve(
                            context,
                            HrText.mono,
                          ).copyWith(fontSize: 12),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 17,
                          color: HrColors.resolve(context, HrColors.brand),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.expense)
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: '填写报销金额',
                    prefixText: '¥ ',
                  ),
                ),
              if (_kind == HrRequestKind.expense) const SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText: switch (_kind) {
                    HrRequestKind.shift => '调班原因标题，例如：项目值班',
                    HrRequestKind.workType => '例如：客户现场支持',
                    HrRequestKind.expense => '报销事项，例如：客户拜访交通费',
                    HrRequestKind.asset => '申请用途，例如：居家办公',
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detail,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '补充说明，便于审批人了解具体情况'),
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
                  '默认使用模拟审批流。切换真实 API 后，提交内容将写入对应的 Horilla 接口。',
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
          label: _submitting ? '提交中…' : '提交申请',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '选择生效日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final typedTitle = _title.text.trim();
    final typedDetail = _detail.text.trim();
    final title = typedTitle.isEmpty ? _defaultTitle : typedTitle;
    final detailParts = <String>[
      if (_kind == HrRequestKind.shift) '$_shift · ${hrDate(_date)}',
      if (_kind == HrRequestKind.workType) '$_workType · ${hrDate(_date)}',
      if (_kind == HrRequestKind.asset) _asset,
      if (_kind == HrRequestKind.expense)
        '¥${_amount.text.trim().isEmpty ? '0.00' : _amount.text.trim()}',
      if (typedDetail.isNotEmpty) typedDetail,
    ];
    setState(() => _submitting = true);
    try {
      await widget.controller.submitRequest(
        title: title,
        detail: detailParts.join(' · '),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '${_kind.label}已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String get _defaultTitle => switch (_kind) {
    HrRequestKind.shift => '临时调班',
    HrRequestKind.workType => _workType,
    HrRequestKind.expense => '费用报销',
    HrRequestKind.asset => _asset,
  };
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: HrColors.resolve(context, HrColors.bg2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(label, style: HrText.resolve(context, HrText.meta)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              borderRadius: BorderRadius.circular(14),
              style: HrText.resolve(
                context,
                HrText.cardTitle,
              ).copyWith(fontSize: 12.5),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: HrColors.resolve(context, HrColors.brand),
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
