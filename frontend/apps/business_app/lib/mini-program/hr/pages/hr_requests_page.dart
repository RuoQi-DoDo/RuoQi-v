part of 'request_pages.dart';

class HrRequestsPage extends StatelessWidget {
  const HrRequestsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    const kinds = HrRequestKind.values;
    return RefreshIndicator(
      color: HrColors.brand,
      onRefresh: controller.refresh,
      child: ListView(
        key: const Key('hr-requests-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '申请中心',
                  style: HrText.appBarTitle.copyWith(fontSize: 25),
                ),
              ),
              HrStatusChip(
                label: '${_pendingCount(controller.requests)} 个审批中',
                background: HrColors.warningBg,
                foreground: HrColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('常用人事服务集中在这里，提交后可随时查看进度。', style: HrText.meta),
          const SizedBox(height: 18),
          HrCard(
            background: HrColors.ink,
            borderColor: HrColors.ink,
            onTap: () => controller.composeRequest(),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: HrColors.brandLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: HrColors.surface,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '新建申请',
                        style: TextStyle(
                          color: HrColors.surface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '调班、办公方式、报销与办公资产',
                        style: TextStyle(
                          color: HrColors.onDark2,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: HrColors.surface,
                  size: 20,
                ),
              ],
            ),
          ),
          const HrSectionHeader(title: '申请类型'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kinds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 116,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final kind = kinds[index];
              final (icon, color, background) = _styleFor(kind);
              return HrCard(
                key: Key('hr-request-kind-${kind.name}'),
                onTap: () => controller.openRequest(kind, _routeFor(kind)),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      kind.label,
                      style: HrText.cardTitle.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kind.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HrText.meta.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
          HrSectionHeader(
            title: '我的申请',
            action: '新建',
            onAction: () => controller.composeRequest(),
          ),
          if (controller.requests.isEmpty)
            const HrEmptyState(
              icon: Icons.inbox_outlined,
              title: '暂无申请',
              message: '提交申请后会在这里显示审批进度。',
            )
          else
            for (final item in controller.requests) ...[
              _RequestCard(item: item),
              const SizedBox(height: 10),
            ],
          const HrSectionHeader(title: '薪酬服务'),
          HrCard(
            onTap: () => controller.open(HrRoute.payslips),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: HrColors.warningBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: HrColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('工资单', style: HrText.cardTitle),
                      SizedBox(height: 3),
                      Text('查看每月工资明细与发放状态', style: HrText.meta),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: HrColors.ink4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int _pendingCount(List<HrRequestItem> items) =>
      items.where((item) => item.status == HrRequestStatus.pending).length;

  static HrRoute _routeFor(HrRequestKind kind) => switch (kind) {
    HrRequestKind.shift => HrRoute.requestShift,
    HrRequestKind.workType => HrRoute.requestWorkType,
    HrRequestKind.expense => HrRoute.requestReimburse,
    HrRequestKind.asset => HrRoute.requestAsset,
  };

  static (IconData, Color, Color) _styleFor(HrRequestKind kind) {
    return switch (kind) {
      HrRequestKind.shift => (
        Icons.swap_horiz_rounded,
        HrColors.info,
        HrColors.infoBg,
      ),
      HrRequestKind.workType => (
        Icons.home_work_outlined,
        HrColors.success,
        HrColors.successBg,
      ),
      HrRequestKind.expense => (
        Icons.payments_outlined,
        HrColors.brand,
        HrColors.brandTint,
      ),
      HrRequestKind.asset => (
        Icons.devices_other_outlined,
        HrColors.warning,
        HrColors.warningBg,
      ),
    };
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item});

  final HrRequestItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, color, background) = HrRequestsPage._styleFor(item.kind);
    final (statusBackground, statusForeground) = switch (item.status) {
      HrRequestStatus.pending => (HrColors.warningBg, HrColors.warning),
      HrRequestStatus.approved => (HrColors.successBg, HrColors.success),
      HrRequestStatus.rejected => (HrColors.dangerBg, HrColors.danger),
    };
    return HrCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HrText.cardTitle.copyWith(fontSize: 13.5),
                      ),
                    ),
                    HrStatusChip(
                      label: item.status.label,
                      background: statusBackground,
                      foreground: statusForeground,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HrText.meta,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kind.shortLabel} · ${hrDate(item.date)}',
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
    );
  }
}
