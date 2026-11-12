part of 'team_pages.dart';

class HrTeamPage extends StatelessWidget {
  const HrTeamPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final checkedIn = controller.team
        .where((member) => member.state == HrTeamState.checkedIn)
        .length;
    final onLeave = controller.team
        .where((member) => member.state == HrTeamState.onLeave)
        .length;
    final notIn = controller.team.length - checkedIn - onLeave;

    return RefreshIndicator(
      color: HrColors.resolve(context, HrColors.brand),
      onRefresh: controller.refresh,
      child: ListView(
        key: const Key('hr-team-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '我的团队',
                  style: HrText.resolve(
                    context,
                    HrText.appBarTitle,
                  ).copyWith(fontSize: 25),
                ),
              ),
              if (controller.approvals.isNotEmpty)
                HrStatusChip(
                  label: '${controller.approvals.length} 待审批',
                  background: HrColors.resolve(context, HrColors.warningBg),
                  foreground: HrColors.resolve(context, HrColors.warning),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${controller.user.department} · ${controller.team.length} 位直属成员',
            style: HrText.resolve(context, HrText.meta),
          ),
          const SizedBox(height: 17),
          HrCard(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _TeamMetric(
                      label: '已到岗',
                      value: '$checkedIn',
                      color: HrColors.resolve(context, HrColors.success),
                    ),
                    _TeamMetric(
                      label: '休假中',
                      value: '$onLeave',
                      color: HrColors.resolve(context, HrColors.warning),
                    ),
                    _TeamMetric(
                      label: '未打卡',
                      value: '$notIn',
                      color: HrColors.resolve(context, HrColors.brand),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Divider(
                  height: 1,
                  color: HrColors.resolve(context, HrColors.line2),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: HrOutlineButton(
                        label: '审批中心',
                        icon: Icons.approval_outlined,
                        onPressed: () => controller.open(HrRoute.approvals),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HrOutlineButton(
                        label: '通讯录',
                        icon: Icons.people_outline_rounded,
                        onPressed: () => controller.open(HrRoute.directory),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          HrSectionHeader(
            title: '今日动态',
            action: '刷新',
            onAction: controller.refresh,
          ),
          HrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < controller.team.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: HrColors.resolve(context, HrColors.line2),
                    ),
                  _TeamMemberRow(member: controller.team[i], index: i),
                ],
              ],
            ),
          ),
          const HrSectionHeader(title: '本周排班风险'),
          _ClashCard(team: controller.team),
        ],
      ),
    );
  }
}

class _TeamMetric extends StatelessWidget {
  const _TeamMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: HrText.resolve(
              context,
              HrText.mono,
            ).copyWith(color: color, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: HrText.resolve(
              context,
              HrText.meta,
            ).copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.member, required this.index});

  final HrTeamMember member;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (member.state) {
      HrTeamState.checkedIn => (
        HrColors.resolve(context, HrColors.successBg),
        HrColors.resolve(context, HrColors.success),
      ),
      HrTeamState.onLeave => (
        HrColors.resolve(context, HrColors.warningBg),
        HrColors.resolve(context, HrColors.warning),
      ),
      HrTeamState.notIn => (
        HrColors.resolve(context, HrColors.dangerBg),
        HrColors.resolve(context, HrColors.danger),
      ),
    };
    final subtitle = member.state == HrTeamState.onLeave
        ? '${member.position} · ${member.leaveType ?? '休假'}'
        : member.position;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      child: Row(
        children: [
          HrAvatar(name: member.name, index: index, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: HrText.resolve(
                    context,
                    HrText.cardTitle,
                  ).copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HrText.resolve(context, HrText.meta),
                ),
              ],
            ),
          ),
          if (member.clockIn != null)
            Text(
              member.clockIn!,
              style: HrText.resolve(context, HrText.mono).copyWith(
                color: HrColors.resolve(context, HrColors.ink3),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            HrStatusChip(
              label: member.state.label,
              background: background,
              foreground: foreground,
            ),
        ],
      ),
    );
  }
}

class _ClashCard extends StatelessWidget {
  const _ClashCard({required this.team});

  final List<HrTeamMember> team;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final counts = <int>[0, 0, 0, 1, 2, 0, 0];
    return HrCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: counts[i] >= 2
                              ? HrColors.resolve(context, HrColors.dangerBg)
                              : counts[i] == 1
                              ? HrColors.resolve(context, HrColors.warningBg)
                              : HrColors.resolve(context, HrColors.bg),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          counts[i] == 0 ? '–' : '${counts[i]}',
                          style: HrText.resolve(context, HrText.mono).copyWith(
                            color: counts[i] >= 2
                                ? HrColors.resolve(context, HrColors.danger)
                                : counts[i] == 1
                                ? HrColors.resolve(context, HrColors.warning)
                                : HrColors.resolve(context, HrColors.ink4),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hrWeekdayShort(monday.add(Duration(days: i))),
                        style: HrText.resolve(context, HrText.meta).copyWith(
                          color: HrColors.resolve(context, HrColors.ink4),
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '周四王思远、周宁同时休假，建议提前安排客户支持值班。',
            style: HrText.resolve(context, HrText.meta).copyWith(
              color: HrColors.resolve(context, HrColors.danger),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
