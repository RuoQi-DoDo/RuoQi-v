part of 'request_pages.dart';

class HrPayslipsPage extends StatelessWidget {
  const HrPayslipsPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.payslips.isEmpty) {
      return const Center(
        child: HrEmptyState(
          icon: Icons.receipt_long_outlined,
          title: '暂无工资单',
          message: '工资单生成后会在这里显示。',
        ),
      );
    }
    final latest = controller.payslips.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          '工资单',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '工资条由薪酬团队统一发布，仅本人可见。',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 17),
        HrCard(
          onTap: () => controller.openPayslip(latest.id),
          background: HrColors.ink,
          borderColor: HrColors.resolve(context, HrColors.ink),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '最近一期实发',
                      style: HrText.resolve(context, HrText.eyebrow),
                    ),
                  ),
                  HrStatusChip(
                    label: '已发放',
                    background: HrColors.resolve(context, HrColors.onDarkTile),
                    foreground: Color(0xFF72D2A6),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hrMoney(latest.netPay),
                style: HrText.resolve(context, HrText.mono).copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.3,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${latest.periodStart.year} 年 ${latest.periodStart.month} 月 · '
                '应发 ${hrMoney(latest.grossPay)}',
                style: HrText.resolve(
                  context,
                  HrText.meta,
                ).copyWith(color: HrColors.resolve(context, HrColors.onDark2)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '查看完整工资明细',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 19,
                  ),
                ],
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '历史工资单'),
        for (final payslip in controller.payslips) ...[
          HrCard(
            onTap: () => controller.openPayslip(payslip.id),
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HrColors.resolve(context, HrColors.warningBg),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${payslip.periodStart.month}月',
                    style: TextStyle(
                      color: HrColors.resolve(context, HrColors.warning),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payslip.periodStart.year} 年 ${payslip.periodStart.month} 月工资',
                        style: HrText.resolve(
                          context,
                          HrText.cardTitle,
                        ).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '实发 ${hrMoney(payslip.netPay)}',
                        style: HrText.resolve(context, HrText.meta),
                      ),
                    ],
                  ),
                ),
                HrStatusChip(label: payslip.status),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HrColors.resolve(context, HrColors.ink4),
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
