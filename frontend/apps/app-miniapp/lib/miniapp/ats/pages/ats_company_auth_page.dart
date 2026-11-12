part of 'company_pages.dart';

class AtsCompanyAuthPage extends StatefulWidget {
  const AtsCompanyAuthPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsCompanyAuthPage> createState() => _AtsCompanyAuthPageState();
}

class _AtsCompanyAuthPageState extends State<AtsCompanyAuthPage> {
  final _companyName = TextEditingController(text: '上海世佳科技有限公司');
  final _creditCode = TextEditingController();
  final _legalName = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _companyName.dispose();
    _creditCode.dispose();
    _legalName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              AtsCard(
                color: _submitted
                    ? const Color(0xFFFFFAF4)
                    : AtsColors.resolve(context, AtsColors.mint),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _submitted
                          ? Icons.hourglass_top_rounded
                          : Icons.verified_user_outlined,
                      color: _submitted
                          ? AtsColors.resolve(context, AtsColors.orange)
                          : AtsColors.resolve(context, AtsColors.primary),
                      size: 28,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _submitted ? '认证资料审核中' : '完成企业认证',
                            style: TextStyle(
                              color: _submitted
                                  ? const Color(0xFF9A5B16)
                                  : AtsColors.resolve(
                                      context,
                                      AtsColors.primaryDark,
                                    ),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _submitted
                                ? '预计 1-2 个工作日完成审核，请留意系统通知。'
                                : '认证后可获得企业标识，提升求职者信任和职位曝光。',
                            style: TextStyle(
                              color: _submitted
                                  ? AtsColors.resolve(context, AtsColors.orange)
                                  : AtsColors.resolve(
                                      context,
                                      AtsColors.primary,
                                    ),
                              fontSize: 11,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    AtsFormRow(
                      label: '企业名称',
                      required: true,
                      child: AtsFormTextField(
                        controller: _companyName,
                        hintText: '请输入企业全称',
                        readOnly: _submitted,
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '信用代码',
                      required: true,
                      child: AtsFormTextField(
                        controller: _creditCode,
                        hintText: '请输入统一社会信用代码',
                        readOnly: _submitted,
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '法人姓名',
                      required: true,
                      child: AtsFormTextField(
                        controller: _legalName,
                        hintText: '请输入法人姓名',
                        readOnly: _submitted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '认证材料',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 7),
                        AtsTag(
                          '必传',
                          foreground: AtsColors.resolve(context, AtsColors.red),
                          background: Color(0xFFFFF0F0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '请上传清晰完整的营业执照照片，仅用于企业资质审核。',
                      style: TextStyle(
                        color: AtsColors.resolve(context, AtsColors.textMuted),
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _submitted
                          ? null
                          : () => atsToast(context, '请选择营业执照照片'),
                      child: Container(
                        height: 118,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AtsColors.resolve(
                            context,
                            AtsColors.background,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AtsColors.resolve(
                              context,
                              AtsColors.divider,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _submitted
                                  ? Icons.description_outlined
                                  : Icons.add_a_photo_outlined,
                              color: _submitted
                                  ? AtsColors.resolve(
                                      context,
                                      AtsColors.primary,
                                    )
                                  : AtsColors.resolve(
                                      context,
                                      AtsColors.textMuted,
                                    ),
                              size: 30,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _submitted ? '营业执照已上传' : '点击上传营业执照',
                              style: TextStyle(
                                color: AtsColors.resolve(
                                  context,
                                  AtsColors.textMuted,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                color: Color(0xFFFFFAF4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AtsColors.resolve(context, AtsColors.orange),
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '平台将对认证材料严格保密，仅用于核验企业主体真实性，不会向其他用户公开。',
                        style: TextStyle(
                          color: AtsColors.resolve(
                            context,
                            AtsColors.textSecondary,
                          ),
                          fontSize: 11,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _CompanyBottomBar(
          label: _submitted ? '资料审核中' : '提交认证',
          onPressed: _submitted
              ? null
              : () {
                  if (_creditCode.text.trim().isEmpty ||
                      _legalName.text.trim().isEmpty) {
                    atsToast(context, '请完整填写认证信息');
                    return;
                  }
                  setState(() => _submitted = true);
                  atsToast(context, '认证资料已提交');
                },
        ),
      ],
    );
  }
}

class _CompanyBottomBar extends StatelessWidget {
  const _CompanyBottomBar({
    required this.label,
    required this.onPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: BoxDecoration(
        color: AtsColors.resolve(context, AtsColors.surface),
        border: Border(
          top: BorderSide(color: AtsColors.resolve(context, AtsColors.divider)),
        ),
      ),
      child: Row(
        children: [
          if (secondaryLabel != null) ...[
            Expanded(
              child: AtsOutlineButton(
                label: secondaryLabel!,
                onPressed: onSecondaryPressed,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: AtsPrimaryButton(label: label, onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}

class _CompanyPicker extends StatelessWidget {
  const _CompanyPicker({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: AtsColors.resolve(context, AtsColors.background),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AtsColors.resolve(context, AtsColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyDropdown extends StatelessWidget {
  const _CompanyDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AtsColors.resolve(context, AtsColors.background),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          icon: Icon(
            Icons.chevron_right,
            size: 18,
            color: AtsColors.resolve(context, AtsColors.textMuted),
          ),
          style: TextStyle(color: AtsColors.resolve(context, AtsColors.text)),
        ),
      ),
    );
  }
}
