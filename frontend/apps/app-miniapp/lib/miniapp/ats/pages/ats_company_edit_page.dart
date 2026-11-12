part of 'company_pages.dart';

class AtsCompanyEditPage extends StatefulWidget {
  const AtsCompanyEditPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsCompanyEditPage> createState() => _AtsCompanyEditPageState();
}

class _AtsCompanyEditPageState extends State<AtsCompanyEditPage> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _introduce;
  String _industry = '互联网';
  String _staffSize = '100-499人';
  final Set<String> _welfare = {'五险一金', '年终奖', '周末双休'};

  @override
  void initState() {
    super.initState();
    final company = atsCompanies.first;
    _name = TextEditingController(text: company.name);
    _address = TextEditingController(text: company.address);
    _introduce = TextEditingController(text: company.introduce);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _introduce.dispose();
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
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => atsToast(context, '请选择新的企业 Logo'),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AtsColors.resolve(context, AtsColors.primary),
                              Color(0xFF54CFAD),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business, size: 30, color: Colors.white),
                            SizedBox(height: 3),
                            Text(
                              '更换',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '企业主页资料',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '完善资料可以提升企业可信度和职位曝光',
                            style: TextStyle(
                              color: AtsColors.resolve(
                                context,
                                AtsColors.textMuted,
                              ),
                              fontSize: 10,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          AtsTag(
                            '已认证',
                            foreground: AtsColors.resolve(
                              context,
                              AtsColors.primary,
                            ),
                            background: AtsColors.resolve(
                              context,
                              AtsColors.mint,
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
                      label: '公司名称',
                      required: true,
                      child: AtsFormTextField(
                        controller: _name,
                        hintText: '请输入公司全称',
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
                      label: '公司规模',
                      required: true,
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
                      label: '工作时间',
                      child: _CompanyPicker(
                        value: '09:00 - 18:00',
                        onTap: () => atsToast(context, '设置工作时间'),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '休息时间',
                      child: _CompanyPicker(
                        value: '周末双休',
                        onTap: () => atsToast(context, '设置休息时间'),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '加班情况',
                      child: _CompanyPicker(
                        value: '弹性工作',
                        onTap: () => atsToast(context, '设置加班情况'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 13, bottom: 10),
                      child: Text(
                        '福利待遇',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final item in const [
                          '五险一金',
                          '六险一金',
                          '年终奖',
                          '周末双休',
                          '弹性工作',
                          '餐补',
                          '年度体检',
                          '带薪年假',
                        ])
                          FilterChip(
                            label: Text(item),
                            selected: _welfare.contains(item),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _welfare.add(item);
                                } else {
                                  _welfare.remove(item);
                                }
                              });
                            },
                            selectedColor: AtsColors.resolve(
                              context,
                              AtsColors.mint,
                            ),
                            checkmarkColor: AtsColors.resolve(
                              context,
                              AtsColors.primary,
                            ),
                            backgroundColor: AtsColors.resolve(
                              context,
                              AtsColors.background,
                            ),
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: _welfare.contains(item)
                                  ? AtsColors.resolve(
                                      context,
                                      AtsColors.primary,
                                    )
                                  : AtsColors.resolve(
                                      context,
                                      AtsColors.textSecondary,
                                    ),
                              fontSize: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 13),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AtsCard(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    AtsFormRow(
                      label: '公司地址',
                      required: true,
                      child: AtsFormTextField(
                        controller: _address,
                        hintText: '请输入公司地址',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '公司介绍',
                      child: AtsFormTextField(
                        controller: _introduce,
                        hintText: '介绍公司的业务、团队和文化',
                        maxLines: 5,
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
                      '企业相册',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          Expanded(
                            child: InkWell(
                              onTap: () => atsToast(context, '请选择办公环境照片'),
                              borderRadius: BorderRadius.circular(9),
                              child: AspectRatio(
                                aspectRatio: 1.25,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AtsColors.resolve(
                                      context,
                                      AtsColors.background,
                                    ),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: AtsColors.resolve(
                                        context,
                                        AtsColors.divider,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AtsColors.resolve(
                                      context,
                                      AtsColors.textMuted,
                                    ),
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (i != 2) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _CompanyBottomBar(
          label: '保存公司资料',
          onPressed: () => atsToast(context, '公司资料已保存'),
        ),
      ],
    );
  }
}
