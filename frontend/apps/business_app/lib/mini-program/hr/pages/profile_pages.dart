import 'package:flutter/material.dart';

import '../hr_controller.dart';
import '../hr_format.dart';
import '../hr_routes.dart';
import '../hr_style.dart';

class HrMePage extends StatelessWidget {
  const HrMePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('hr-me-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('我的', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 16),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HrColors.brand,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Text(
                  controller.user.name.characters.last,
                  style: const TextStyle(
                    color: HrColors.surface,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.user.name,
                      style: HrText.appBarTitle.copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.user.department} · ${controller.user.position}',
                      style: HrText.meta,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HrColors.successBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '在职 · ${controller.user.employeeNo}',
                        style: HrText.mono.copyWith(
                          color: HrColors.success,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '编辑个人信息',
                onPressed: () => controller.open(HrRoute.personalInfo),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: HrColors.ink3,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HrCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          child: Row(
            children: [
              _ProfileStat(
                value:
                    '${controller.leaveBalances.first.availableDays.toInt()}',
                label: '年假余额',
                icon: Icons.beach_access_outlined,
              ),
              _ProfileStat(
                value: '${controller.approvals.length}',
                label: '待审批',
                icon: Icons.approval_outlined,
              ),
              _ProfileStat(
                value: '${controller.requests.length}',
                label: '我的申请',
                icon: Icons.inbox_outlined,
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '人事服务'),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MenuRow(
                icon: Icons.person_outline_rounded,
                iconColor: HrColors.info,
                iconBackground: HrColors.infoBg,
                label: '个人信息',
                value: controller.user.employeeNo,
                onTap: () => controller.open(HrRoute.personalInfo),
              ),
              _MenuRow(
                icon: Icons.campaign_outlined,
                iconColor: HrColors.success,
                iconBackground: HrColors.successBg,
                label: '公司公告',
                value: controller.unreadAnnouncementCount > 0
                    ? '${controller.unreadAnnouncementCount} 条未读'
                    : '全部已读',
                onTap: () => controller.open(HrRoute.announcements),
              ),
              _MenuRow(
                icon: Icons.notifications_none_rounded,
                iconColor: HrColors.warning,
                iconBackground: HrColors.warningBg,
                label: '消息通知',
                value: controller.unreadNotificationCount > 0
                    ? '${controller.unreadNotificationCount} 条未读'
                    : '全部已读',
                onTap: () => controller.open(HrRoute.notifications),
              ),
              _MenuRow(
                icon: Icons.receipt_long_outlined,
                iconColor: HrColors.warning,
                iconBackground: HrColors.warningBg,
                label: '工资单',
                value: '最近 ${controller.payslips.length} 期',
                onTap: () => controller.open(HrRoute.payslips),
              ),
              _MenuRow(
                icon: Icons.people_outline_rounded,
                iconColor: HrColors.info,
                iconBackground: HrColors.infoBg,
                label: '企业通讯录',
                value: '${controller.directory.length} 位同事',
                onTap: () => controller.open(HrRoute.directory),
              ),
              _MenuRow(
                icon: Icons.support_agent_outlined,
                iconColor: HrColors.info,
                iconBackground: HrColors.infoBg,
                label: '员工服务台',
                value: '提交服务工单',
                onTap: () => controller.open(HrRoute.helpdesk),
                showDivider: false,
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '账号与偏好'),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MenuRow(
                icon: Icons.manage_accounts_outlined,
                iconColor: HrColors.ink3,
                iconBackground: HrColors.bg2,
                label: '直属主管',
                value: controller.user.manager,
                onTap: null,
              ),
              _MenuRow(
                icon: Icons.face_retouching_natural,
                iconColor: HrColors.success,
                iconBackground: HrColors.successBg,
                label: '人脸参考照片',
                value: '已支持打卡核验',
                onTap: () => controller.open(HrRoute.faceEnrolment),
              ),
              _MenuRow(
                icon: Icons.switch_account_outlined,
                iconColor: HrColors.warning,
                iconBackground: HrColors.warningBg,
                label: '切换账号',
                onTap: () => controller.open(HrRoute.signIn),
              ),
              _MenuRow(
                icon: Icons.settings_outlined,
                iconColor: HrColors.ink3,
                iconBackground: HrColors.bg2,
                label: '设置',
                onTap: () => controller.open(HrRoute.settings),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          background: HrColors.infoBg,
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.api_rounded, color: HrColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.useMockData ? '当前：静态模拟数据' : '当前：真实 HR API',
                      style: HrText.cardTitle.copyWith(
                        color: HrColors.info,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Horilla 接口层已保留，可通过 HR_USE_MOCK_DATA=false 切换。',
                      style: HrText.meta.copyWith(color: HrColors.info),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'RuoQi 人事 · 静态原型 1.0.0',
          textAlign: TextAlign.center,
          style: HrText.mono.copyWith(color: HrColors.ink4, fontSize: 9.5),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: HrColors.brand),
          const SizedBox(height: 5),
          Text(
            value,
            style: HrText.mono.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(label, style: HrText.meta.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    style: HrText.body.copyWith(
                      color: HrColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null)
                  Flexible(
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HrText.meta,
                    ),
                  ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: HrColors.ink4,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 63,
            endIndent: 16,
            color: HrColors.line2,
          ),
      ],
    );
  }
}

class HrAnnouncementsPage extends StatelessWidget {
  const HrAnnouncementsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: HrColors.brand,
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '公司公告',
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              if (controller.unreadAnnouncementCount > 0)
                HrStatusChip(
                  label: '${controller.unreadAnnouncementCount} 条未读',
                  background: HrColors.brandTint,
                  foreground: HrColors.brand,
                ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('公司政策、员工关怀与重要通知。', style: HrText.meta),
          const SizedBox(height: 16),
          for (final item in controller.announcements) ...[
            HrCard(
              key: Key('hr-announcement-${item.id}'),
              onTap: () => controller.openAnnouncement(item.id),
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.unread ? HrColors.brand : HrColors.readDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HrStatusChip(
                              label: item.category,
                              background: HrColors.bg2,
                              foreground: HrColors.ink3,
                            ),
                            const Spacer(),
                            Text(
                              hrRelative(item.createdAt),
                              style: HrText.meta.copyWith(
                                color: HrColors.ink4,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: HrText.cardTitle.copyWith(
                            fontSize: 15,
                            color: item.unread ? HrColors.ink : HrColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: HrText.body.copyWith(color: HrColors.ink3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class HrAnnouncementDetailPage extends StatelessWidget {
  const HrAnnouncementDetailPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final item = controller.selectedAnnouncement;
    if (item == null) {
      return const Center(child: Text('公告不存在'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(
          children: [
            HrStatusChip(
              label: item.category,
              background: HrColors.brandTint,
              foreground: HrColors.brand,
            ),
            const Spacer(),
            Text(hrRelative(item.createdAt), style: HrText.meta),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          item.title,
          style: HrText.appBarTitle.copyWith(fontSize: 25, height: 1.3),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            HrAvatar(name: item.author, size: 32, index: item.id),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.author,
                  style: HrText.cardTitle.copyWith(fontSize: 11.5),
                ),
                Text(
                  '${hrDate(item.createdAt, withYear: true)} · 人力资源部',
                  style: HrText.meta.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.summary,
                style: HrText.body.copyWith(
                  color: HrColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: HrColors.line2),
              const SizedBox(height: 15),
              for (var i = 0; i < item.content.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    item.content[i],
                    style: _isHeading(item.content[i])
                        ? HrText.cardTitle.copyWith(
                            fontSize: 14,
                            color: HrColors.ink,
                          )
                        : HrText.body.copyWith(fontSize: 13.5, height: 1.65),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          padding: const EdgeInsets.all(14),
          background: HrColors.bg,
          borderColor: HrColors.line2,
          shadow: false,
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: HrColors.success,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(child: Text('此公告面向全体员工发布，阅读状态已同步。', style: HrText.meta)),
            ],
          ),
        ),
      ],
    );
  }

  static bool _isHeading(String text) =>
      text.startsWith('一、') ||
      text.startsWith('二、') ||
      text.startsWith('三、') ||
      text.startsWith('四、');
}

class HrNotificationsPage extends StatelessWidget {
  const HrNotificationsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '消息通知',
                style: HrText.appBarTitle.copyWith(fontSize: 25),
              ),
            ),
            if (controller.unreadNotificationCount > 0)
              TextButton(
                onPressed: controller.markAllNotificationsRead,
                style: TextButton.styleFrom(foregroundColor: HrColors.brand),
                child: const Text(
                  '全部已读',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${controller.unreadNotificationCount} 条未读 · 共 ${controller.notifications.length} 条',
          style: HrText.meta,
        ),
        const SizedBox(height: 16),
        for (final item in controller.notifications) ...[
          HrCard(
            onTap: item.unread
                ? () => controller.markNotificationRead(item.id)
                : null,
            padding: const EdgeInsets.all(15),
            borderColor: item.unread ? HrColors.line : HrColors.line2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _notificationColor(item.icon),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _notificationIcon(item.icon),
                    color: _notificationInk(item.icon),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: HrText.cardTitle.copyWith(fontSize: 13),
                            ),
                          ),
                          if (item.unread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: HrColors.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: HrText.body.copyWith(color: HrColors.ink3),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        hrRelative(item.createdAt),
                        style: HrText.meta.copyWith(
                          color: HrColors.ink4,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  static IconData _notificationIcon(String name) => switch (name) {
    'calendar' => Icons.event_available_outlined,
    'approval' => Icons.approval_outlined,
    'payslip' => Icons.receipt_long_outlined,
    _ => Icons.schedule_outlined,
  };

  static Color _notificationInk(String name) => switch (name) {
    'calendar' => HrColors.success,
    'approval' => HrColors.warning,
    'payslip' => HrColors.info,
    _ => HrColors.brand,
  };

  static Color _notificationColor(String name) => switch (name) {
    'calendar' => HrColors.successBg,
    'approval' => HrColors.warningBg,
    'payslip' => HrColors.infoBg,
    _ => HrColors.brandTint,
  };
}

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

class HrSettingsPage extends StatelessWidget {
  const HrSettingsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('设置', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('消息、安全与数据偏好。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                value: controller.notificationsEnabled,
                onChanged: controller.setNotificationsEnabled,
                activeTrackColor: HrColors.brand,
                title: const Text(
                  '消息通知',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('审批、考勤与公告提醒', style: HrText.meta),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              SwitchListTile.adaptive(
                value: controller.biometricEnabled,
                onChanged: controller.setBiometricEnabled,
                activeTrackColor: HrColors.brand,
                title: const Text(
                  '生物识别解锁',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('使用指纹或面容快速进入', style: HrText.meta),
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '数据与存储'),
        HrCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.cleaning_services_outlined,
                  color: HrColors.ink3,
                  size: 20,
                ),
                title: const Text('清理缓存', style: HrText.cardTitle),
                subtitle: const Text('12.6 MB', style: HrText.meta),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: HrColors.ink4,
                ),
                onTap: () => hrToast(context, '缓存已清理'),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_outlined,
                  color: HrColors.ink3,
                  size: 20,
                ),
                title: const Text('数据来源', style: HrText.cardTitle),
                subtitle: Text(
                  controller.useMockData ? '静态模拟数据' : 'Horilla API',
                  style: HrText.meta,
                ),
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '关于'),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrLogoMark(size: 48),
              SizedBox(height: 12),
              Text('RuoQi 人事', style: HrText.cardTitle),
              SizedBox(height: 4),
              Text(
                '参考 Horilla HR Mobile 信息架构实现的人事小程序页面。当前默认使用静态模拟数据，真实 API 适配层已保留。',
                style: HrText.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
