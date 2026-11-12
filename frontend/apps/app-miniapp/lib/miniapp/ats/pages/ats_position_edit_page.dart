part of 'company_pages.dart';

class AtsPositionEditPage extends StatefulWidget {
  const AtsPositionEditPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsPositionEditPage> createState() => _AtsPositionEditPageState();
}

class _AtsPositionEditPageState extends State<AtsPositionEditPage> {
  final _title = TextEditingController();
  final _salary = TextEditingController();
  final _address = TextEditingController();
  final _department = TextEditingController();
  final _description = TextEditingController();
  final _skills = <String>['Flutter', 'Dart', '性能优化'];
  String _experience = '3-5年';
  String _education = '本科';
  String _jobType = '全职';

  @override
  void dispose() {
    _title.dispose();
    _salary.dispose();
    _address.dispose();
    _department.dispose();
    _description.dispose();
    super.dispose();
  }

  void _addSkill() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('添加技能标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如：跨端开发'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && !_skills.contains(value)) {
                setState(() => _skills.add(value));
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _save() {
    if (_title.text.trim().isEmpty || _salary.text.trim().isEmpty) {
      atsToast(context, '请填写职位名称和薪资范围');
      return;
    }
    atsToast(context, '职位已保存并发布');
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    AtsFormRow(
                      label: '职位名称',
                      required: true,
                      child: AtsFormTextField(
                        controller: _title,
                        hintText: '例如：Flutter 开发工程师',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '招聘类型',
                      required: true,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: '全职', label: Text('全职')),
                          ButtonSegment(value: '兼职', label: Text('兼职')),
                          ButtonSegment(value: '实习', label: Text('实习')),
                        ],
                        selected: {_jobType},
                        onSelectionChanged: (value) {
                          setState(() => _jobType = value.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '薪资范围',
                      required: true,
                      child: AtsFormTextField(
                        controller: _salary,
                        hintText: '例如：20-35K·14薪',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '经验要求',
                      child: _CompanyDropdown(
                        value: _experience,
                        values: const ['应届生', '1年以内', '1-3年', '3-5年', '5-10年'],
                        onChanged: (value) =>
                            setState(() => _experience = value),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '学历要求',
                      child: _CompanyDropdown(
                        value: _education,
                        values: const ['不限', '大专', '本科', '硕士', '博士'],
                        onChanged: (value) =>
                            setState(() => _education = value),
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '工作地点',
                      child: AtsFormTextField(
                        controller: _address,
                        hintText: '请输入工作地点',
                      ),
                    ),
                    const Divider(height: 1),
                    AtsFormRow(
                      label: '所属部门',
                      child: AtsFormTextField(
                        controller: _department,
                        hintText: '请输入部门名称',
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
                      padding: EdgeInsets.only(top: 13),
                      child: Text(
                        '技能标签',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (var i = 0; i < _skills.length; i++)
                          InputChip(
                            label: Text(_skills[i]),
                            onDeleted: () =>
                                setState(() => _skills.removeAt(i)),
                            deleteIconColor: AtsColors.resolve(
                              context,
                              AtsColors.primary,
                            ),
                            backgroundColor: AtsColors.resolve(
                              context,
                              AtsColors.mint,
                            ),
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: AtsColors.resolve(
                                context,
                                AtsColors.primary,
                              ),
                              fontSize: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                        ActionChip(
                          onPressed: _addSkill,
                          avatar: const Icon(Icons.add, size: 15),
                          label: const Text('添加'),
                          side: BorderSide(
                            color: AtsColors.resolve(
                              context,
                              AtsColors.divider,
                            ),
                          ),
                          backgroundColor: AtsColors.resolve(
                            context,
                            AtsColors.surface,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 13, bottom: 9),
                      child: Text(
                        '职位描述',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AtsFormTextField(
                      controller: _description,
                      hintText: '请描述岗位职责、任职要求、团队情况等，建议分行填写',
                      maxLines: 8,
                    ),
                    const SizedBox(height: 13),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        _CompanyBottomBar(
          label: '保存并发布',
          secondaryLabel: '预览',
          onSecondaryPressed: () => atsToast(context, '预览已生成'),
          onPressed: _save,
        ),
      ],
    );
  }
}
