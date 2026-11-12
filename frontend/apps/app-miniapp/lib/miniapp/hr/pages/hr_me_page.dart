part of 'profile_pages.dart';

class HrMePage extends StatelessWidget {
  const HrMePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('hr-me-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          '我的',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
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
                  style: TextStyle(
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
                      style: HrText.resolve(
                        context,
                        HrText.appBarTitle,
                      ).copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.user.department} · ${controller.user.position}',
                      style: HrText.resolve(context, HrText.meta),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HrColors.resolve(context, HrColors.successBg),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '在职 · ${controller.user.employeeNo}',
                        style: HrText.resolve(context, HrText.mono).copyWith(
                          color: HrColors.resolve(context, HrColors.success),
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
                icon: Icon(
                  Icons.edit_outlined,
                  color: HrColors.resolve(context, HrColors.ink3),
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
                iconColor: HrColors.resolve(context, HrColors.info),
                iconBackground: HrColors.resolve(context, HrColors.infoBg),
                label: '个人信息',
                value: controller.user.employeeNo,
                onTap: () => controller.open(HrRoute.personalInfo),
              ),
              _MenuRow(
                icon: Icons.campaign_outlined,
                iconColor: HrColors.resolve(context, HrColors.success),
                iconBackground: HrColors.resolve(context, HrColors.successBg),
                label: '公司公告',
                value: controller.unreadAnnouncementCount > 0
                    ? '${controller.unreadAnnouncementCount} 条未读'
                    : '全部已读',
                onTap: () => controller.open(HrRoute.announcements),
              ),
              _MenuRow(
                icon: Icons.notifications_none_rounded,
                iconColor: HrColors.resolve(context, HrColors.warning),
                iconBackground: HrColors.resolve(context, HrColors.warningBg),
                label: '消息通知',
                value: controller.unreadNotificationCount > 0
                    ? '${controller.unreadNotificationCount} 条未读'
                    : '全部已读',
                onTap: () => controller.open(HrRoute.notifications),
              ),
              _MenuRow(
                icon: Icons.receipt_long_outlined,
                iconColor: HrColors.resolve(context, HrColors.warning),
                iconBackground: HrColors.resolve(context, HrColors.warningBg),
                label: '工资单',
                value: '最近 ${controller.payslips.length} 期',
                onTap: () => controller.open(HrRoute.payslips),
              ),
              _MenuRow(
                icon: Icons.people_outline_rounded,
                iconColor: HrColors.resolve(context, HrColors.info),
                iconBackground: HrColors.resolve(context, HrColors.infoBg),
                label: '企业通讯录',
                value: '${controller.directory.length} 位同事',
                onTap: () => controller.open(HrRoute.directory),
              ),
              _MenuRow(
                icon: Icons.support_agent_outlined,
                iconColor: HrColors.resolve(context, HrColors.info),
                iconBackground: HrColors.resolve(context, HrColors.infoBg),
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
                iconColor: HrColors.resolve(context, HrColors.ink3),
                iconBackground: HrColors.resolve(context, HrColors.bg2),
                label: '直属主管',
                value: controller.user.manager,
                onTap: null,
              ),
              _MenuRow(
                icon: Icons.face_retouching_natural,
                iconColor: HrColors.resolve(context, HrColors.success),
                iconBackground: HrColors.resolve(context, HrColors.successBg),
                label: '人脸参考照片',
                value: '已支持打卡核验',
                onTap: () => controller.open(HrRoute.faceEnrolment),
              ),
              _MenuRow(
                icon: Icons.switch_account_outlined,
                iconColor: HrColors.resolve(context, HrColors.warning),
                iconBackground: HrColors.resolve(context, HrColors.warningBg),
                label: '切换账号',
                onTap: () => controller.open(HrRoute.signIn),
              ),
              _MenuRow(
                icon: Icons.settings_outlined,
                iconColor: HrColors.resolve(context, HrColors.ink3),
                iconBackground: HrColors.resolve(context, HrColors.bg2),
                label: '设置',
                onTap: () => controller.open(HrRoute.settings),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          background: HrColors.resolve(context, HrColors.infoBg),
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.api_rounded,
                color: HrColors.resolve(context, HrColors.info),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.useMockData ? '当前：静态模拟数据' : '当前：真实 HR API',
                      style: HrText.resolve(context, HrText.cardTitle).copyWith(
                        color: HrColors.resolve(context, HrColors.info),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Horilla 接口层已保留，可通过 HR_USE_MOCK_DATA=false 切换。',
                      style: HrText.resolve(context, HrText.meta).copyWith(
                        color: HrColors.resolve(context, HrColors.info),
                      ),
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
          style: HrText.resolve(context, HrText.mono).copyWith(
            color: HrColors.resolve(context, HrColors.ink4),
            fontSize: 9.5,
          ),
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
          Icon(
            icon,
            size: 19,
            color: HrColors.resolve(context, HrColors.brand),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: HrText.resolve(
              context,
              HrText.mono,
            ).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 1),
          Text(
            localizeMiniProgramLabel(context, label),
            style: HrText.resolve(context, HrText.meta).copyWith(fontSize: 10),
          ),
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
                    localizeMiniProgramLabel(context, label),
                    style: HrText.resolve(context, HrText.body).copyWith(
                      color: HrColors.resolve(context, HrColors.ink),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null)
                  Flexible(
                    child: Text(
                      localizeMiniProgramLabel(context, value!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HrText.resolve(context, HrText.meta),
                    ),
                  ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: HrColors.resolve(context, HrColors.ink4),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 63,
            endIndent: 16,
            color: HrColors.resolve(context, HrColors.line2),
          ),
      ],
    );
  }
}
