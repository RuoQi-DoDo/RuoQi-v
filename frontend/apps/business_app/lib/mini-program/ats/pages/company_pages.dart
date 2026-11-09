import 'package:flutter/material.dart';

import '../ats_models.dart';
import '../ats_routes.dart';
import '../ats_style.dart';

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
                          gradient: const LinearGradient(
                            colors: [AtsColors.primary, Color(0xFF54CFAD)],
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
                    const Expanded(
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
                              color: AtsColors.textMuted,
                              fontSize: 10,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          AtsTag(
                            '已认证',
                            foreground: AtsColors.primary,
                            background: AtsColors.mint,
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
                            selectedColor: AtsColors.mint,
                            checkmarkColor: AtsColors.primary,
                            backgroundColor: AtsColors.background,
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: _welfare.contains(item)
                                  ? AtsColors.primary
                                  : AtsColors.textSecondary,
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
                                    color: AtsColors.background,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: AtsColors.divider,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AtsColors.textMuted,
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

class AtsPositionsPage extends StatefulWidget {
  const AtsPositionsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsPositionsPage> createState() => _AtsPositionsPageState();
}

class _AtsPositionsPageState extends State<AtsPositionsPage> {
  int _tab = 0;
  final _offline = <String>{};

  @override
  Widget build(BuildContext context) {
    final tabs = ['招聘中', '待审核', '已下线', '全部'];
    final jobs = switch (_tab) {
      1 => <AtsJob>[],
      2 => atsJobs.where((job) => _offline.contains(job.id)).toList(),
      3 => atsJobs.take(3).toList(),
      _ => atsJobs.take(3).where((job) => !_offline.contains(job.id)).toList(),
    };
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: _tab == i
                                ? AtsColors.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          color: _tab == i
                              ? AtsColors.primary
                              : AtsColors.textSecondary,
                          fontSize: 13,
                          fontWeight: _tab == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: jobs.isEmpty
              ? AtsEmptyState(
                  icon: Icons.post_add_outlined,
                  title: _tab == 1 ? '暂无待审核职位' : '暂无下线职位',
                  subtitle: '发布新职位后将在这里展示',
                  action: AtsPrimaryButton(
                    label: '发布新职位',
                    onPressed: () =>
                        widget.controller.open(AtsRoute.positionEdit),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    AtsCard(
                      color: AtsColors.mint,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insights_outlined,
                            color: AtsColors.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              '今日职位曝光 328 次，收到 6 份新简历',
                              style: TextStyle(
                                color: AtsColors.primaryDark,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                widget.controller.open(AtsRoute.resumeList),
                            child: const Text('查看'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final job in jobs)
                      _ManagedJobCard(
                        job: job,
                        offline: _offline.contains(job.id),
                        onEdit: () =>
                            widget.controller.open(AtsRoute.positionEdit),
                        onToggle: () {
                          setState(() {
                            if (!_offline.add(job.id)) {
                              _offline.remove(job.id);
                            }
                          });
                          atsToast(
                            context,
                            _offline.contains(job.id) ? '职位已下线' : '职位已上线',
                          );
                        },
                      ),
                  ],
                ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          child: AtsPrimaryButton(
            label: '发布新职位',
            icon: Icons.add,
            onPressed: () => widget.controller.open(AtsRoute.positionEdit),
          ),
        ),
      ],
    );
  }
}

class _ManagedJobCard extends StatelessWidget {
  const _ManagedJobCard({
    required this.job,
    required this.offline,
    required this.onEdit,
    required this.onToggle,
  });

  final AtsJob job;
  final bool offline;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AtsTag(
                offline ? '已下线' : '招聘中',
                foreground: offline ? AtsColors.textMuted : AtsColors.primary,
                background: offline ? AtsColors.background : AtsColors.mint,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${job.salary} · ${job.location} · ${job.experience}',
            style: const TextStyle(color: AtsColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 13),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(
            children: [
              _JobStat(value: '328', label: '曝光'),
              _JobStat(value: '26', label: '浏览'),
              _JobStat(value: '6', label: '简历'),
              const Spacer(),
              TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  foregroundColor: AtsColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(offline ? '上线' : '下线'),
              ),
              const SizedBox(width: 4),
              OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AtsColors.primary,
                  side: const BorderSide(color: AtsColors.primary),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Text('编辑'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobStat extends StatelessWidget {
  const _JobStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AtsColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

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
                            deleteIconColor: AtsColors.primary,
                            backgroundColor: AtsColors.mint,
                            side: BorderSide.none,
                            labelStyle: const TextStyle(
                              color: AtsColors.primary,
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
                          side: const BorderSide(color: AtsColors.divider),
                          backgroundColor: Colors.white,
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
                color: _submitted ? const Color(0xFFFFFAF4) : AtsColors.mint,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _submitted
                          ? Icons.hourglass_top_rounded
                          : Icons.verified_user_outlined,
                      color: _submitted ? AtsColors.orange : AtsColors.primary,
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
                                  : AtsColors.primaryDark,
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
                                  ? AtsColors.orange
                                  : AtsColors.primary,
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
                    const Row(
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
                          foreground: AtsColors.red,
                          background: Color(0xFFFFF0F0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '请上传清晰完整的营业执照照片，仅用于企业资质审核。',
                      style: TextStyle(
                        color: AtsColors.textMuted,
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
                          color: AtsColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AtsColors.divider),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _submitted
                                  ? Icons.description_outlined
                                  : Icons.add_a_photo_outlined,
                              color: _submitted
                                  ? AtsColors.primary
                                  : AtsColors.textMuted,
                              size: 30,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _submitted ? '营业执照已上传' : '点击上传营业执照',
                              style: const TextStyle(
                                color: AtsColors.textMuted,
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
              const AtsCard(
                color: Color(0xFFFFFAF4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AtsColors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '平台将对认证材料严格保密，仅用于核验企业主体真实性，不会向其他用户公开。',
                        style: TextStyle(
                          color: AtsColors.textSecondary,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AtsColors.divider)),
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
          color: AtsColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AtsColors.textMuted,
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
        color: AtsColors.background,
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
          icon: const Icon(
            Icons.chevron_right,
            size: 18,
            color: AtsColors.textMuted,
          ),
          style: const TextStyle(color: AtsColors.text),
        ),
      ),
    );
  }
}
