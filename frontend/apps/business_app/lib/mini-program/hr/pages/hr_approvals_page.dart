part of 'team_pages.dart';

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
