part of 'profile_pages.dart';

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AtsColors.solidPrimary(context),
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF116E56)
                    : const Color(0xFF48C9A8),
              ],
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
                            color: AtsColors.resolve(
                              context,
                              AtsColors.surface,
                            ).withValues(alpha: 0.22),
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
                                color: AtsColors.resolve(
                                  context,
                                  AtsColors.surface,
                                ).withValues(alpha: 0.2),
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
                color: AtsColors.resolve(
                  context,
                  AtsColors.surface,
                ).withValues(alpha: 0.18),
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
              Text(
                '企业直聘 v1.0.0',
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.textMuted),
                  fontSize: 10,
                ),
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
          decoration: BoxDecoration(
            color: AtsColors.resolve(context, AtsColors.surface),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: AtsColors.resolve(context, AtsColors.divider),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '切换身份',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '不同身份拥有独立的首页和功能入口',
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.textMuted),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 18),
              for (final role in AtsUserRole.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: controller.role == role
                        ? AtsColors.resolve(context, AtsColors.mint)
                        : AtsColors.resolve(context, AtsColors.background),
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
                                    ? AtsColors.solidPrimary(context)
                                    : AtsColors.resolve(
                                        context,
                                        AtsColors.blue,
                                      ),
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
                                    style: TextStyle(
                                      color: AtsColors.resolve(
                                        context,
                                        AtsColors.textMuted,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.role == role)
                              Icon(
                                Icons.check_circle,
                                color: AtsColors.resolve(
                                  context,
                                  AtsColors.primary,
                                ),
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
                  Icon(
                    icon,
                    size: 24,
                    color: AtsColors.resolve(context, AtsColors.text),
                  ),
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
                          color: AtsColors.resolve(context, AtsColors.red),
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
                localizeMiniProgramLabel(context, label),
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.textSecondary),
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
            color: AtsColors.resolve(context, AtsColors.red),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            localizeMiniProgramLabel(context, text),
            style: const TextStyle(color: Colors.white, fontSize: 9, height: 1),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 19,
          color: AtsColors.resolve(context, AtsColors.textMuted),
        ),
      ],
    );
  }
}
