part of 'profile_pages.dart';

class AtsEditWorkPage extends StatefulWidget {
  const AtsEditWorkPage({super.key});

  @override
  State<AtsEditWorkPage> createState() => _AtsEditWorkPageState();
}

class _AtsEditWorkPageState extends State<AtsEditWorkPage> {
  final _company = TextEditingController();
  final _position = TextEditingController();
  final _description = TextEditingController();
  String _industry = '互联网';

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '工作经历已保存'),
      children: [
        AtsCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              AtsFormRow(
                label: '公司名称',
                required: true,
                child: AtsFormTextField(
                  controller: _company,
                  hintText: '请输入公司名称',
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '所在行业',
                child: _DropdownValue(
                  value: _industry,
                  values: atsIndustries,
                  onChanged: (value) => setState(() => _industry = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '在职时间',
                required: true,
                child: _PickerValue(
                  value: '2022.06 - 至今',
                  onTap: () => atsToast(context, '选择在职时间'),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '职位名称',
                required: true,
                child: AtsFormTextField(
                  controller: _position,
                  hintText: '请输入职位名称',
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '工作内容',
                child: AtsFormTextField(
                  controller: _description,
                  hintText: '请描述你的工作内容',
                  maxLines: 4,
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '技能标签',
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in const ['Flutter', 'Dart', '团队协作'])
                      AtsTag(
                        tag,
                        foreground: AtsColors.primary,
                        background: AtsColors.mint,
                      ),
                    const AtsTag(
                      '+ 添加',
                      foreground: AtsColors.primary,
                      background: AtsColors.mint,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
