part of 'profile_pages.dart';

class AtsEditEducationPage extends StatefulWidget {
  const AtsEditEducationPage({super.key});

  @override
  State<AtsEditEducationPage> createState() => _AtsEditEducationPageState();
}

class _AtsEditEducationPageState extends State<AtsEditEducationPage> {
  final _school = TextEditingController();
  final _major = TextEditingController();
  final _content = TextEditingController();
  String _education = '本科';

  @override
  void dispose() {
    _school.dispose();
    _major.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '教育经历已保存'),
      children: [
        AtsCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              AtsFormRow(
                label: '学校名称',
                required: true,
                child: AtsFormTextField(
                  controller: _school,
                  hintText: '请输入学校名称',
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '学历',
                required: true,
                child: _DropdownValue(
                  value: _education,
                  values: const ['高中', '大专', '本科', '硕士', '博士'],
                  onChanged: (value) => setState(() => _education = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '专业',
                child: AtsFormTextField(
                  controller: _major,
                  hintText: '请输入专业名称',
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '时间段',
                required: true,
                child: _PickerValue(
                  value: '2018.09 - 2022.06',
                  onTap: () => atsToast(context, '选择教育时间'),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '在校经历',
                child: AtsFormTextField(
                  controller: _content,
                  hintText: '选填，请输入在校经历',
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditPageLayout extends StatelessWidget {
  const _EditPageLayout({required this.children, required this.onSave});

  final List<Widget> children;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: children,
          ),
        ),
        _BottomSaveBar(onSave: onSave),
      ],
    );
  }
}

class _EditIntro extends StatelessWidget {
  const _EditIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: AtsColors.resolve(context, AtsColors.textMuted),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSaveBar extends StatelessWidget {
  const _BottomSaveBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AtsColors.resolve(context, AtsColors.surface),
        border: Border(
          top: BorderSide(color: AtsColors.resolve(context, AtsColors.divider)),
        ),
      ),
      child: AtsPrimaryButton(label: '保存', onPressed: onSave),
    );
  }
}

class _PickerValue extends StatelessWidget {
  const _PickerValue({required this.value, required this.onTap});

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
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.text),
                  fontSize: 13,
                ),
              ),
            ),
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

class _DropdownValue extends StatelessWidget {
  const _DropdownValue({
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
