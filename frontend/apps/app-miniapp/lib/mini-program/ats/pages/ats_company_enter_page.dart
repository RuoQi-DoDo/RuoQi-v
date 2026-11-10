part of 'company_pages.dart';

class AtsCompanyEnterPage extends StatefulWidget {
  const AtsCompanyEnterPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsCompanyEnterPage> createState() => _AtsCompanyEnterPageState();
}

class _AtsCompanyEnterPageState extends State<AtsCompanyEnterPage> {
  final _companyName = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _industry = '互联网';
  String _staffSize = '20-99人';
  bool _agreed = true;

  @override
  void dispose() {
    _companyName.dispose();
    _contactName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    if (_companyName.text.trim().isEmpty ||
        _contactName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      atsToast(context, '请填写公司和联系人信息');
      return;
    }
    if (!_agreed) {
      atsToast(context, '请先阅读并同意入驻协议');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AtsColors.primary,
          size: 48,
        ),
        title: const Text('入驻资料已提交'),
        content: const Text(
          '工作人员将在 1-2 个工作日内完成审核，审核结果会通过系统消息通知你。',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.open(AtsRoute.companyEdit);
            },
            child: const Text('进入企业主页'),
          ),
        ],
      ),
    );
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
                color: AtsColors.mint,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      color: AtsColors.primary,
                      size: 28,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '免费入驻，开始招聘',
                            style: TextStyle(
                              color: AtsColors.primaryDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '提交企业基本信息后即可发布职位，认证企业将获得更多曝光。',
                            style: TextStyle(
                              color: AtsColors.primary,
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
                        hintText: '请输入营业执照上的名称',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '所属行业',
                      required: true,
                      child: _CompanyDropdown(
                        value: _industry,
                        values: atsIndustries,
                        onChanged: (value) => setState(() => _industry = value),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '企业规模',
                      child: _CompanyDropdown(
                        value: _staffSize,
                        values: const [
                          '20人以下',
                          '20-99人',
                          '100-499人',
                          '500-999人',
                          '1000人以上',
                        ],
                        onChanged: (value) =>
                            setState(() => _staffSize = value),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '联系人',
                      required: true,
                      child: AtsFormTextField(
                        controller: _contactName,
                        hintText: '请输入联系人姓名',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '联系电话',
                      required: true,
                      child: AtsFormTextField(
                        controller: _phone,
                        hintText: '请输入手机号',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '办公地址',
                      child: AtsFormTextField(
                        controller: _address,
                        hintText: '请输入详细办公地址',
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
                    const Text(
                      '企业 Logo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 11),
                    InkWell(
                      onTap: () => atsToast(context, '请选择企业 Logo'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: AtsColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AtsColors.divider),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          color: AtsColors.textMuted,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      activeColor: AtsColors.primary,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '我已阅读并同意'),
                          TextSpan(
                            text: '《企业入驻协议》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 10,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        _CompanyBottomBar(label: '提交入驻申请', onPressed: _submit),
      ],
    );
  }
}
