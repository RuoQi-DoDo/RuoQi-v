part of 'profile_pages.dart';

class HrPersonalInfoPage extends StatefulWidget {
  const HrPersonalInfoPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrPersonalInfoPage> createState() => _HrPersonalInfoPageState();
}

class _HrPersonalInfoPageState extends State<HrPersonalInfoPage> {
  late final TextEditingController _name;
  late final TextEditingController _department;
  late final TextEditingController _position;
  late final TextEditingController _manager;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.user;
    _name = TextEditingController(text: user.name);
    _department = TextEditingController(text: user.department);
    _position = TextEditingController(text: user.position);
    _manager = TextEditingController(text: user.manager);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _department.dispose();
    _position.dispose();
    _manager.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('个人信息', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('部分字段由 HR 系统维护，当前演示允许编辑。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _InfoField(label: '姓名', controller: _name),
              _InfoField(label: '部门', controller: _department),
              _InfoField(label: '职位', controller: _position),
              _InfoField(label: '直属主管', controller: _manager),
              _InfoField(
                label: '邮箱',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              _InfoField(
                label: '手机号',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ReadonlyRow(
                label: '员工编号',
                value: widget.controller.user.employeeNo,
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              _ReadonlyRow(
                label: '入职日期',
                value: hrDate(widget.controller.user.joinDate, withYear: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HrPrimaryButton(
          label: '保存修改',
          icon: Icons.check_rounded,
          onPressed: _save,
        ),
      ],
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      hrToast(context, '姓名不能为空');
      return;
    }
    widget.controller.updateProfile(
      name: _name.text,
      department: _department.text,
      position: _position.text,
      manager: _manager.text,
      email: _email.text,
      phone: _phone.text,
    );
    widget.controller.back();
    hrToast(context, '个人信息已更新');
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  const _ReadonlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Text(label, style: HrText.body),
          const Spacer(),
          Text(value, style: HrText.meta),
        ],
      ),
    );
  }
}
