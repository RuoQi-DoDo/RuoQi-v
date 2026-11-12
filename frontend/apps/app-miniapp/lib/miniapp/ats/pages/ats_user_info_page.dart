part of 'profile_pages.dart';

class AtsUserInfoPage extends StatefulWidget {
  const AtsUserInfoPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsUserInfoPage> createState() => _AtsUserInfoPageState();
}

class _AtsUserInfoPageState extends State<AtsUserInfoPage> {
  late final TextEditingController _nameController;
  String _gender = '女';
  String _education = '本科';
  String _experience = '3-5年';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      atsToast(context, '请输入姓名');
      return;
    }
    widget.controller.setUserName(_nameController.text);
    widget.controller.back();
    atsToast(context, '基本信息已保存');
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
                child: Column(
                  children: [
                    AtsFormRow(
                      label: '姓名',
                      required: true,
                      child: AtsFormTextField(
                        controller: _nameController,
                        hintText: '请输入姓名',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '性别',
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '男', label: Text('男')),
                          ButtonSegment(value: '女', label: Text('女')),
                        ],
                        selected: {_gender},
                        onSelectionChanged: (value) {
                          setState(() => _gender = value.first);
                        },
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '出生年月',
                      child: _PickerValue(
                        value: '1999年08月',
                        onTap: () => atsToast(context, '选择出生年月'),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '最高学历',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _education,
                          isExpanded: true,
                          items: const ['大专', '本科', '硕士', '博士']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _education = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '工作经验',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _experience,
                          isExpanded: true,
                          items: const ['应届生', '1年以内', '1-3年', '3-5年', '5-10年']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _experience = value);
                            }
                          },
                        ),
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
                      '账号信息',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _AccountLine(label: '绑定手机', value: '138****6688'),
                    const SizedBox(height: 10),
                    _AccountLine(
                      label: '当前身份',
                      value: widget.controller.role.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomSaveBar(onSave: _save),
      ],
    );
  }
}

class _AccountLine extends StatelessWidget {
  const _AccountLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.textSecondary),
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.text),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
