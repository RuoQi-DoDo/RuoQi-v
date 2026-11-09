import 'package:flutter/material.dart';

import '../hr_controller.dart';
import '../hr_format.dart';
import '../hr_models.dart';
import '../hr_routes.dart';
import '../hr_style.dart';

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
      color: HrColors.brand,
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
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              if (controller.approvals.isNotEmpty)
                HrStatusChip(
                  label: '${controller.approvals.length} 待审批',
                  background: HrColors.warningBg,
                  foreground: HrColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${controller.user.department} · ${controller.team.length} 位直属成员',
            style: HrText.meta,
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
                      color: HrColors.success,
                    ),
                    _TeamMetric(
                      label: '休假中',
                      value: '$onLeave',
                      color: HrColors.warning,
                    ),
                    _TeamMetric(
                      label: '未打卡',
                      value: '$notIn',
                      color: HrColors.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(height: 1, color: HrColors.line2),
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
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: HrColors.line2,
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
            style: HrText.mono.copyWith(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: HrText.meta.copyWith(fontSize: 10.5)),
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
      HrTeamState.checkedIn => (HrColors.successBg, HrColors.success),
      HrTeamState.onLeave => (HrColors.warningBg, HrColors.warning),
      HrTeamState.notIn => (HrColors.dangerBg, HrColors.danger),
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
                  style: HrText.cardTitle.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HrText.meta,
                ),
              ],
            ),
          ),
          if (member.clockIn != null)
            Text(
              member.clockIn!,
              style: HrText.mono.copyWith(
                color: HrColors.ink3,
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
                              ? HrColors.dangerBg
                              : counts[i] == 1
                              ? HrColors.warningBg
                              : HrColors.bg,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          counts[i] == 0 ? '–' : '${counts[i]}',
                          style: HrText.mono.copyWith(
                            color: counts[i] >= 2
                                ? HrColors.danger
                                : counts[i] == 1
                                ? HrColors.warning
                                : HrColors.ink4,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hrWeekdayShort(monday.add(Duration(days: i))),
                        style: HrText.meta.copyWith(
                          color: HrColors.ink4,
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
            style: HrText.meta.copyWith(
              color: HrColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class HrApprovalsPage extends StatefulWidget {
  const HrApprovalsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrApprovalsPage> createState() => _HrApprovalsPageState();
}

class _HrApprovalsPageState extends State<HrApprovalsPage> {
  HrApprovalKind? _filter;

  @override
  Widget build(BuildContext context) {
    final approvals = _filter == null
        ? widget.controller.approvals
        : widget.controller.approvals
              .where((item) => item.kind == _filter)
              .toList();
    return RefreshIndicator(
      color: HrColors.brand,
      onRefresh: widget.controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '审批中心',
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              HrStatusChip(
                label: '${widget.controller.approvals.length} 待处理',
                background: HrColors.warningBg,
                foreground: HrColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('集中处理团队成员的申请，决策后可立即撤销。', style: HrText.meta),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: '全部 · ${widget.controller.approvals.length}',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final kind in HrApprovalKind.values) ...[
                  const SizedBox(width: 7),
                  _FilterChip(
                    label:
                        '${kind.label} · ${widget.controller.approvals.where((item) => item.kind == kind).length}',
                    selected: _filter == kind,
                    onTap: () => setState(() => _filter = kind),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (approvals.isEmpty)
            const HrEmptyState(
              icon: Icons.check_rounded,
              title: '全部处理完成',
              message: '当前筛选下没有等待处理的申请。',
            )
          else
            for (final item in approvals) ...[
              _ApprovalCard(
                item: item,
                onApprove: () => _decide(item, approve: true),
                onReject: item.canReject
                    ? () => _decide(item, approve: false)
                    : null,
              ),
              const SizedBox(height: 11),
            ],
        ],
      ),
    );
  }

  Future<void> _decide(HrApprovalItem item, {required bool approve}) async {
    await widget.controller.decideApproval(item, approve: approve);
    if (!mounted) {
      return;
    }
    hrToast(
      context,
      approve ? '已通过 ${item.name} 的申请' : '已驳回 ${item.name} 的申请',
      action: SnackBarAction(
        label: '撤销',
        onPressed: () {
          widget.controller.undoLastDecision();
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? HrColors.ink : HrColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? HrColors.ink : HrColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? HrColors.surface : HrColors.ink3,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.item,
    required this.onApprove,
    required this.onReject,
  });

  final HrApprovalItem item;
  final VoidCallback onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      key: Key('hr-approval-${item.id}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HrAvatar(name: item.name, index: item.employeeId, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: HrText.cardTitle.copyWith(fontSize: 14),
                    ),
                    Text(item.kind.label, style: HrText.meta),
                  ],
                ),
              ),
              Text(
                hrRelative(item.submittedAt),
                style: HrText.mono.copyWith(
                  color: HrColors.ink4,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HrColors.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.ask, style: HrText.cardTitle.copyWith(fontSize: 13)),
                if (item.reason.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(item.reason, style: HrText.meta),
                ],
              ],
            ),
          ),
          if (item.warning != null) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: HrColors.warningBg,
                border: Border.all(color: HrColors.warningBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.warning!,
                style: HrText.meta.copyWith(
                  color: HrColors.warningInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 13),
          if (onReject != null)
            Row(
              children: [
                Expanded(
                  child: HrPrimaryButton(label: '通过', onPressed: onApprove),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: HrOutlineButton(
                    label: '驳回',
                    danger: true,
                    onPressed: onReject,
                  ),
                ),
              ],
            )
          else ...[
            HrPrimaryButton(label: '通过', onPressed: onApprove),
            const SizedBox(height: 7),
            Text(
              '该类型申请如需驳回，请前往 Horilla 网页端处理。',
              style: HrText.meta.copyWith(color: HrColors.ink4),
            ),
          ],
        ],
      ),
    );
  }
}

class HrDirectoryPage extends StatefulWidget {
  const HrDirectoryPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrDirectoryPage> createState() => _HrDirectoryPageState();
}

class _HrDirectoryPageState extends State<HrDirectoryPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final entries = widget.controller.directory.where((entry) {
      if (query.isEmpty) {
        return true;
      }
      return entry.name.toLowerCase().contains(query) ||
          entry.department.toLowerCase().contains(query) ||
          entry.position.toLowerCase().contains(query);
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('企业通讯录', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        Text(
          '共 ${widget.controller.directory.length} 位同事 · '
          '可直接查看联系方式',
          style: HrText.meta,
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: '搜索姓名、部门或职位',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const HrEmptyState(
            icon: Icons.search_off_rounded,
            title: '没有找到同事',
            message: '试试搜索姓名、部门或职位关键词。',
          )
        else
          HrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: HrColors.line2,
                    ),
                  InkWell(
                    onTap: () => _showContact(entries[i], i),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 13, 12),
                      child: Row(
                        children: [
                          HrAvatar(
                            name: entries[i].name,
                            index: entries[i].id,
                            size: 42,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entries[i].name,
                                  style: HrText.cardTitle.copyWith(
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${entries[i].department} · ${entries[i].position}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HrText.meta,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: HrColors.ink4,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showContact(HrDirectoryEntry entry, int index) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: HrColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              HrAvatar(name: entry.name, index: entry.id, size: 64),
              const SizedBox(height: 10),
              Text(
                entry.name,
                style: HrText.appBarTitle.copyWith(fontSize: 21),
              ),
              const SizedBox(height: 3),
              Text(
                '${entry.department} · ${entry.position}',
                style: HrText.meta,
              ),
              const SizedBox(height: 18),
              HrCard(
                shadow: false,
                background: HrColors.bg,
                child: Column(
                  children: [
                    _ContactRow(
                      icon: Icons.mail_outline_rounded,
                      label: entry.email,
                    ),
                    const SizedBox(height: 12),
                    _ContactRow(icon: Icons.phone_outlined, label: entry.phone),
                    if (entry.extension != null) ...[
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.dialpad_rounded,
                        label: '分机 ${entry.extension}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: HrOutlineButton(
                      label: '发送邮件',
                      icon: Icons.mail_outline,
                      onPressed: () {
                        Navigator.of(context).pop();
                        hrToast(this.context, '邮件入口已模拟');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: HrPrimaryButton(
                      label: '发起沟通',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        hrToast(this.context, '已向 ${entry.name} 发起沟通');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HrColors.brand),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: HrText.body)),
      ],
    );
  }
}
