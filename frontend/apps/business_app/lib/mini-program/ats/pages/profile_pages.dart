import 'package:flutter/material.dart';

import '../ats_models.dart';
import '../ats_routes.dart';
import '../ats_style.dart';

class AtsProfilePage extends StatelessWidget {
  const AtsProfilePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final isRecruiter = controller.role == AtsUserRole.recruiter;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AtsColors.primary, Color(0xFF48C9A8)],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: controller.loggedIn
                        ? () => controller.open(AtsRoute.userInfo)
                        : () => controller.open(AtsRoute.login),
                    borderRadius: BorderRadius.circular(99),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            controller.loggedIn
                                ? controller.userName.characters.first
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.loggedIn
                                  ? controller.userName
                                  : '未登录 / 注册',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                controller.loggedIn
                                    ? controller.role.label
                                    : '游客模式',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (controller.loggedIn) {
                        controller.open(AtsRoute.userInfo);
                      } else {
                        controller.open(AtsRoute.login);
                      }
                    },
                    tooltip: '基本信息',
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Material(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _showRoleSwitcher(context, controller),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isRecruiter
                              ? Icons.business_center_outlined
                              : Icons.person_search_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            !controller.loggedIn
                                ? '游客模式可浏览全站，登录后可投递、收藏和沟通'
                                : isRecruiter
                                ? '当前为招聘者身份，可管理公司和职位'
                                : '当前为求职者身份，完善简历获得更多机会',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Text(
                          '切换身份',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -10),
          child: Column(
            children: [
              AtsCard(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: isRecruiter
                          ? Icons.business_outlined
                          : Icons.description_outlined,
                      label: isRecruiter ? '公司管理' : '我的简历',
                      badge: isRecruiter ? null : '待完善',
                      onTap: () => controller.open(
                        isRecruiter ? AtsRoute.companyEdit : AtsRoute.resume,
                      ),
                    ),
                    _QuickAction(
                      icon: isRecruiter
                          ? Icons.work_outline_rounded
                          : Icons.assignment_outlined,
                      label: isRecruiter ? '职位管理' : '我的投递',
                      badge: isRecruiter ? null : '2',
                      onTap: () => controller.open(
                        isRecruiter
                            ? AtsRoute.positions
                            : AtsRoute.applications,
                      ),
                    ),
                    _QuickAction(
                      icon: isRecruiter
                          ? Icons.people_outline
                          : Icons.star_border_rounded,
                      label: isRecruiter ? '人才库' : '我的收藏',
                      onTap: () => controller.open(
                        isRecruiter ? AtsRoute.resumeList : AtsRoute.collect,
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.history_rounded,
                      label: '浏览记录',
                      onTap: () => controller.open(AtsRoute.browse),
                    ),
                  ],
                ),
              ),
              if (isRecruiter) ...[
                const AtsSectionHeader(title: '招聘管理'),
                _MenuCard(
                  children: [
                    AtsListRow(
                      icon: Icons.domain_add_outlined,
                      title: '公司入驻',
                      subtitle: '创建或完善企业资料',
                      onTap: () => controller.open(AtsRoute.companyEnter),
                    ),
                    AtsListRow(
                      icon: Icons.verified_user_outlined,
                      title: '公司认证',
                      subtitle: '提交营业执照，提高可信度',
                      onTap: () => controller.open(AtsRoute.companyAuth),
                    ),
                    AtsListRow(
                      icon: Icons.post_add_outlined,
                      title: '发布职位',
                      onTap: () => controller.open(AtsRoute.positionEdit),
                    ),
                    AtsListRow(
                      icon: Icons.forum_outlined,
                      title: '已沟通',
                      trailing: const _MenuBadge('3'),
                      onTap: () => controller.open(AtsRoute.connected),
                      showDivider: false,
                    ),
                  ],
                ),
              ] else ...[
                const AtsSectionHeader(title: '求职服务'),
                _MenuCard(
                  children: [
                    AtsListRow(
                      icon: Icons.description_outlined,
                      title: '我的简历',
                      subtitle: '完善度 85%，继续补充可提升曝光',
                      onTap: () => controller.open(AtsRoute.resume),
                    ),
                    AtsListRow(
                      icon: Icons.assignment_turned_in_outlined,
                      title: '我的投递',
                      trailing: const _MenuBadge('2'),
                      onTap: () => controller.open(AtsRoute.applications),
                    ),
                    AtsListRow(
                      icon: Icons.star_border_rounded,
                      title: '我的收藏',
                      onTap: () => controller.open(AtsRoute.collect),
                    ),
                    AtsListRow(
                      icon: Icons.visibility_outlined,
                      title: '谁看过我',
                      onTap: () => controller.open(AtsRoute.connected),
                      showDivider: false,
                    ),
                  ],
                ),
              ],
              const AtsSectionHeader(title: '更多服务'),
              _MenuCard(
                children: [
                  AtsListRow(
                    icon: Icons.support_agent,
                    title: '在线客服',
                    onTap: () => controller.open(AtsRoute.robot),
                  ),
                  AtsListRow(
                    icon: Icons.help_outline_rounded,
                    title: '帮助中心',
                    onTap: () => controller.open(AtsRoute.help),
                  ),
                  AtsListRow(
                    icon: Icons.qr_code_2_rounded,
                    title: '我的推广码',
                    onTap: () => controller.open(AtsRoute.promoCode),
                  ),
                  AtsListRow(
                    icon: Icons.privacy_tip_outlined,
                    title: '隐私设置',
                    onTap: () => controller.open(AtsRoute.hideSetting),
                  ),
                  AtsListRow(
                    icon: Icons.settings_outlined,
                    title: '系统设置',
                    onTap: () => controller.open(AtsRoute.settings),
                  ),
                  AtsListRow(
                    icon: Icons.info_outline_rounded,
                    title: '关于我们',
                    onTap: () => controller.open(AtsRoute.aboutUs),
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                '企业直聘 v1.0.0',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  void _showRoleSwitcher(BuildContext context, AtsAppController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: AtsColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '切换身份',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                '不同身份拥有独立的首页和功能入口',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              for (final role in AtsUserRole.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: controller.role == role
                        ? AtsColors.mint
                        : AtsColors.background,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        controller.setRole(role);
                        Navigator.of(sheetContext).pop();
                        atsToast(context, '已切换为${role.label}');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: role == AtsUserRole.candidate
                                    ? AtsColors.primary
                                    : AtsColors.blue,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                role == AtsUserRole.candidate
                                    ? Icons.person_search_outlined
                                    : Icons.business_center_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.label,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    role == AtsUserRole.candidate
                                        ? '找工作、投递简历、收藏职位'
                                        : '发布职位、查看简历、招聘人才',
                                    style: const TextStyle(
                                      color: AtsColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.role == role)
                              const Icon(
                                Icons.check_circle,
                                color: AtsColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 24, color: AtsColors.text),
                  if (badge != null)
                    Positioned(
                      left: 16,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AtsColors.red,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: const TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _MenuBadge extends StatelessWidget {
  const _MenuBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 18),
          height: 18,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AtsColors.red,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 9, height: 1),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 19, color: AtsColors.textMuted),
      ],
    );
  }
}

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
          style: const TextStyle(color: AtsColors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AtsColors.text, fontSize: 12),
        ),
      ],
    );
  }
}

class AtsResumePage extends StatelessWidget {
  const AtsResumePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final resume = atsResumes.first;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          onTap: () => controller.open(AtsRoute.userInfo),
          child: Row(
            children: [
              AtsAvatar(label: controller.userName, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          controller.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.edit_outlined,
                          size: 15,
                          color: AtsColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${resume.age}岁 · ${resume.education} · '
                      '${resume.experience}工作经验',
                      style: const TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AtsColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '85%',
                      style: TextStyle(
                        color: AtsColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '完整度',
                      style: TextStyle(color: AtsColors.primary, fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '个人优势',
          action: '编辑',
          onAction: () => controller.open(AtsRoute.editSkill),
          child: Text(
            resume.skill,
            style: const TextStyle(
              color: AtsColors.textSecondary,
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '求职期望',
          action: '编辑',
          onAction: () => controller.open(AtsRoute.editExpectation),
          child: Column(
            children: [
              _ResumeInfoRow(label: '意向岗位', value: resume.intent),
              _ResumeInfoRow(label: '期望薪资', value: resume.salary),
              _ResumeInfoRow(label: '求职状态', value: resume.jobStatus),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '工作经历',
          action: '添加',
          onAction: () => controller.open(AtsRoute.editWork),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ExperienceHeader(
                title: '上海青禾网络科技',
                period: '2022.06 - 至今',
                role: 'Flutter 开发工程师',
              ),
              const SizedBox(height: 9),
              const Text(
                '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程，'
                '关键页面渲染性能提升 35%。',
                style: TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [AtsTag('Flutter'), AtsTag('Dart'), AtsTag('性能优化')],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '项目经历',
          action: '添加',
          onAction: () => controller.open(AtsRoute.editProject),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExperienceHeader(
                title: '招聘 App 跨端重构',
                period: '2023.03 - 2023.11',
                role: '项目负责人',
              ),
              SizedBox(height: 8),
              Text(
                '统一 iOS、Android 与 Web 三端研发链路，持续集成效率提升 40%。',
                style: TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ResumeSection(
          title: '教育经历',
          action: '添加',
          onAction: () => controller.open(AtsRoute.editEducation),
          child: const _ExperienceHeader(
            title: '江南大学',
            period: '2018.09 - 2022.06',
            role: '计算机科学与技术 · 本科',
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ResumeSection extends StatelessWidget {
  const _ResumeSection({
    required this.title,
    required this.child,
    this.action,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AtsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (action != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: Text(action!),
                  style: TextButton.styleFrom(
                    foregroundColor: AtsColors.primary,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ResumeInfoRow extends StatelessWidget {
  const _ResumeInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(color: AtsColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AtsColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceHeader extends StatelessWidget {
  const _ExperienceHeader({
    required this.title,
    required this.period,
    required this.role,
  });

  final String title;
  final String period;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AtsColors.mint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            title.contains('大学')
                ? Icons.school_outlined
                : title.contains('项目')
                ? Icons.folder_outlined
                : Icons.business_outlined,
            color: AtsColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$role · $period',
                style: const TextStyle(
                  color: AtsColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AtsResumeDetailPage extends StatelessWidget {
  const AtsResumeDetailPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final resume = atsResumes.first;
    final favorite = controller.favorites.contains(resume.id);
    final invited = controller.applications.contains(resume.id);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              AtsCard(
                child: Row(
                  children: [
                    AtsAvatar(label: resume.name, size: 57),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${resume.gender} · ${resume.age}岁 · '
                            '${resume.education} · ${resume.experience}',
                            style: const TextStyle(
                              color: AtsColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 7),
                          AtsTag(
                            resume.jobStatus,
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
              _ResumeSection(
                title: '个人优势',
                child: Text(
                  resume.skill,
                  style: const TextStyle(
                    color: AtsColors.textSecondary,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '求职意向',
                child: Column(
                  children: [
                    _ResumeInfoRow(label: '期望岗位', value: resume.intent),
                    _ResumeInfoRow(label: '期望薪资', value: resume.salary),
                    _ResumeInfoRow(label: '求职状态', value: resume.jobStatus),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '工作经历',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ExperienceHeader(
                      title: '上海青禾网络科技',
                      period: '2022.06 - 至今',
                      role: 'Flutter 开发工程师',
                    ),
                    SizedBox(height: 9),
                    Text(
                      '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程。',
                      style: TextStyle(
                        color: AtsColors.textSecondary,
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ResumeSection(
                title: '教育经历',
                child: const _ExperienceHeader(
                  title: '江南大学',
                  period: '2018.09 - 2022.06',
                  role: '计算机科学与技术 · 本科',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AtsColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: AtsOutlineButton(
                  label: favorite ? '取消收藏' : '收藏简历',
                  icon: favorite ? Icons.star : Icons.star_border,
                  foreground: favorite ? AtsColors.orange : AtsColors.text,
                  onPressed: () {
                    controller.toggleFavorite(resume.id);
                    atsToast(context, favorite ? '已取消收藏' : '已收藏简历');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AtsPrimaryButton(
                  label: invited ? '取消邀请' : '面试邀请',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () {
                    controller.toggleApplication(resume.id);
                    atsToast(context, invited ? '已取消面试邀请' : '面试邀请已发送');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AtsApplicationsPage extends StatefulWidget {
  const AtsApplicationsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsApplicationsPage> createState() => _AtsApplicationsPageState();
}

class _AtsApplicationsPageState extends State<AtsApplicationsPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const statuses = ['全部', '已投递', '已查看', '面试邀请'];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              for (var i = 0; i < statuses.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _tab = i),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _tab == i ? AtsColors.mint : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        statuses[i],
                        style: TextStyle(
                          color: _tab == i
                              ? AtsColors.primary
                              : AtsColors.textSecondary,
                          fontSize: 12,
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
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (var i = 0; i < 2; i++)
                AtsCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () => widget.controller.open(AtsRoute.jobDetail),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              atsJobs[i].title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            atsJobs[i].salary,
                            style: const TextStyle(
                              color: AtsColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        atsJobs[i].company,
                        style: const TextStyle(
                          color: AtsColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          AtsTag(
                            i == 0 ? '已查看' : '已投递',
                            foreground: i == 0
                                ? AtsColors.primary
                                : AtsColors.blue,
                            background: i == 0
                                ? AtsColors.mint
                                : const Color(0xFFEEF4FF),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            i == 0 ? '今天 10:20' : '昨天 16:45',
                            style: const TextStyle(
                              color: AtsColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '查看详情',
                            style: TextStyle(
                              color: AtsColors.primary,
                              fontSize: 11,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AtsColors.primary,
                          ),
                        ],
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

class AtsCollectPage extends StatelessWidget {
  const AtsCollectPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final jobs = atsJobs
        .where((job) => controller.favorites.contains(job.id))
        .toList();
    final displayJobs = jobs.isEmpty ? atsJobs.take(1).toList() : jobs;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final job in displayJobs)
          AtsJobCard(
            job: job,
            margin: const EdgeInsets.only(bottom: 10),
            onTap: () => controller.open(AtsRoute.jobDetail),
          ),
        if (jobs.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '以上为推荐收藏，点击职位详情可收藏更多岗位',
              textAlign: TextAlign.center,
              style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
            ),
          ),
      ],
    );
  }
}

class AtsBrowsePage extends StatelessWidget {
  const AtsBrowsePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 9),
          child: Text(
            '今天',
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AtsCard(
          margin: const EdgeInsets.only(bottom: 10),
          onTap: () => controller.open(AtsRoute.jobDetail),
          child: Row(
            children: [
              _TimelineIcon(icon: Icons.work_outline),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atsJobs.first.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${atsJobs.first.company} · 14:32',
                      style: const TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AtsColors.textMuted,
                size: 19,
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 10, 2, 9),
          child: Text(
            '昨天',
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AtsCard(
          onTap: () => controller.open(AtsRoute.companyDetail),
          child: Row(
            children: [
              _TimelineIcon(
                icon: Icons.business_outlined,
                color: AtsColors.blue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atsCompanies.first.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '公司主页 · 18:05',
                      style: TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AtsColors.textMuted,
                size: 19,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineIcon extends StatelessWidget {
  const _TimelineIcon({required this.icon, this.color = AtsColors.primary});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class AtsConnectedPage extends StatelessWidget {
  const AtsConnectedPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final recruiter = controller.role == AtsUserRole.recruiter;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          color: AtsColors.mint,
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                color: AtsColors.primary,
                size: 28,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '本周有 12 位新访客',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AtsColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      recruiter ? '持续更新职位可吸引更多人才' : '完善简历可获得更多曝光',
                      style: const TextStyle(
                        color: AtsColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '最近访客'),
        for (final resume in atsResumes)
          AtsCard(
            margin: const EdgeInsets.only(bottom: 9),
            onTap: () => controller.open(
              recruiter ? AtsRoute.resumeDetail : AtsRoute.privateChat,
            ),
            child: Row(
              children: [
                AtsAvatar(
                  label: resume.name,
                  size: 42,
                  color: resume.gender == '女'
                      ? const Color(0xFFEC6A88)
                      : AtsColors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${resume.intent} · ${resume.experience}',
                        style: const TextStyle(
                          color: AtsColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '刚刚浏览',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AtsPromoCodePage extends StatelessWidget {
  const AtsPromoCodePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AtsColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                AtsAvatar(label: controller.userName, size: 60),
                const SizedBox(height: 10),
                Text(
                  controller.userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '邀请码：212121',
                  style: TextStyle(
                    color: AtsColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 178,
                  height: 178,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AtsColors.divider),
                  ),
                  child: const _FakeQrCode(),
                ),
                const SizedBox(height: 16),
                const Text(
                  '微信扫描上方二维码即可注册',
                  style: TextStyle(
                    color: AtsColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '截图保存二维码到手机或微信识别',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
                const SizedBox(height: 20),
                AtsPrimaryButton(
                  label: '保存推广码',
                  icon: Icons.download_outlined,
                  onPressed: () => atsToast(context, '推广码已保存'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 18, color: AtsColors.primary),
              SizedBox(width: 6),
              Text(
                '企业直聘',
                style: TextStyle(
                  color: AtsColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FakeQrCode extends StatelessWidget {
  const _FakeQrCode();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 21 * 21,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 21,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 21;
        final col = index % 21;
        final corner =
            (row < 7 && col < 7) ||
            (row < 7 && col > 13) ||
            (row > 13 && col < 7);
        final fill = corner
            ? (row == 0 ||
                  row == 6 ||
                  col == 0 ||
                  col == 6 ||
                  (row >= 2 && row <= 4 && col >= 2 && col <= 4) ||
                  (col >= 15 && col <= 19 && row == 0) ||
                  (row >= 15 && row <= 19 && col == 0))
            : ((index * 7 + col * 3) % 11 < 4);
        return ColoredBox(color: fill ? AtsColors.text : Colors.transparent);
      },
    );
  }
}

class AtsHideSettingPage extends StatefulWidget {
  const AtsHideSettingPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsHideSettingPage> createState() => _AtsHideSettingPageState();
}

class _AtsHideSettingPageState extends State<AtsHideSettingPage> {
  bool _hideResume = false;
  bool _hideCompany = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                value: _hideResume,
                onChanged: (value) => setState(() => _hideResume = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '对招聘方隐藏简历',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '开启后招聘方将无法主动查看你的完整简历',
                  style: TextStyle(fontSize: 10, color: AtsColors.textMuted),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _hideCompany,
                onChanged: (value) => setState(() => _hideCompany = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '隐藏求职活跃状态',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '隐藏最近活跃时间，减少被打扰',
                  style: TextStyle(fontSize: 10, color: AtsColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '屏蔽的企业'),
        AtsCard(
          child: Column(
            children: [
              for (final company in widget.controller.hiddenCompanies)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.business_outlined,
                    color: AtsColors.textMuted,
                  ),
                  title: Text(company, style: const TextStyle(fontSize: 13)),
                  trailing: TextButton(
                    onPressed: () {
                      widget.controller.removeHiddenCompany(company);
                      setState(() {});
                    },
                    child: const Text('取消屏蔽'),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => atsToast(context, '请输入要屏蔽的企业名称'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加屏蔽企业'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AtsPrimaryButton(
          label: '保存隐私设置',
          onPressed: () => atsToast(context, '隐私设置已保存'),
        ),
      ],
    );
  }
}

class AtsEditSkillPage extends StatefulWidget {
  const AtsEditSkillPage({super.key});

  @override
  State<AtsEditSkillPage> createState() => _AtsEditSkillPageState();
}

class _AtsEditSkillPageState extends State<AtsEditSkillPage> {
  final _controller = TextEditingController(text: atsResumes.first.skill);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '个人优势已保存'),
      children: [
        const _EditIntro(title: '我的优势', subtitle: '一句话介绍自己，突出与目标岗位匹配的核心优势'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 7,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: '例如：4年移动端研发经验，擅长 Flutter 性能优化……',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}

class AtsEditExpectationPage extends StatefulWidget {
  const AtsEditExpectationPage({super.key});

  @override
  State<AtsEditExpectationPage> createState() => _AtsEditExpectationPageState();
}

class _AtsEditExpectationPageState extends State<AtsEditExpectationPage> {
  String _jobType = '全职';
  String _position = 'Flutter 开发工程师';
  String _industry = '互联网';
  String _salary = '20-30K';

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '求职期望已保存'),
      children: [
        AtsCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              AtsFormRow(
                label: '求职类型',
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
                label: '期望职位',
                required: true,
                child: _DropdownValue(
                  value: _position,
                  values: atsPositions,
                  onChanged: (value) => setState(() => _position = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '期望行业',
                required: true,
                child: _DropdownValue(
                  value: _industry,
                  values: atsIndustries,
                  onChanged: (value) => setState(() => _industry = value),
                ),
              ),
              const Divider(height: 1),
              AtsFormRow(
                label: '薪资要求',
                required: true,
                child: _DropdownValue(
                  value: _salary,
                  values: const [
                    '8-12K',
                    '12-20K',
                    '20-30K',
                    '30-40K',
                    '40K以上',
                  ],
                  onChanged: (value) => setState(() => _salary = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

class AtsEditWorkContentPage extends StatefulWidget {
  const AtsEditWorkContentPage({super.key});

  @override
  State<AtsEditWorkContentPage> createState() => _AtsEditWorkContentPageState();
}

class _AtsEditWorkContentPageState extends State<AtsEditWorkContentPage> {
  final _controller = TextEditingController(
    text:
        '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程，'
        '关键页面渲染性能提升 35%。',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '工作内容已保存'),
      children: [
        const _EditIntro(title: '工作内容', subtitle: '用简洁的语言描述职责、成果和关键数据'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 8,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '请输入工作内容',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}

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

class AtsEditProjectContentPage extends StatefulWidget {
  const AtsEditProjectContentPage({super.key});

  @override
  State<AtsEditProjectContentPage> createState() =>
      _AtsEditProjectContentPageState();
}

class _AtsEditProjectContentPageState extends State<AtsEditProjectContentPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '项目内容已保存'),
      children: [
        const _EditIntro(title: '项目内容', subtitle: '介绍项目背景、你的职责和取得的成果'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 8,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '请输入项目内容',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}

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
            style: const TextStyle(
              color: AtsColors.textMuted,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AtsColors.divider)),
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
          color: AtsColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AtsColors.text, fontSize: 13),
              ),
            ),
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
