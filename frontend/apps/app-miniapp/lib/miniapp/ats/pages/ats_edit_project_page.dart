part of 'profile_pages.dart';

class AtsEditProjectPage extends StatefulWidget {
  const AtsEditProjectPage({super.key});

  @override
  State<AtsEditProjectPage> createState() => _AtsEditProjectPageState();
}

class _AtsEditProjectPageState extends State<AtsEditProjectPage> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _performance = TextEditingController(text: '持续集成效率提升 40%');

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _url.dispose();
    _description.dispose();
    _performance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '项目经历已保存'),
      children: [
        AtsCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              AtsFormRow(
                label: '项目名称',
                required: true,
                child: AtsFormTextField(controller: _name, hintText: '请输入项目名称'),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '担任角色',
                required: true,
                child: AtsFormTextField(controller: _role, hintText: '请输入担任角色'),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '项目时间',
                required: true,
                child: _PickerValue(
                  value: '2023.03 - 2023.11',
                  onTap: () => atsToast(context, '选择项目时间'),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '项目描述',
                child: AtsFormTextField(
                  controller: _description,
                  hintText: '请输入项目描述',
                  maxLines: 3,
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '项目业绩',
                child: AtsFormTextField(
                  controller: _performance,
                  hintText: '选填，请输入项目业绩',
                  maxLines: 2,
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '项目链接',
                child: AtsFormTextField(
                  controller: _url,
                  hintText: '选填，请填入项目链接',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
