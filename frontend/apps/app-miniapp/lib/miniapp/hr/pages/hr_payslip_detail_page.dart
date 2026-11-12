part of 'request_pages.dart';

class HrPayslipDetailPage extends StatelessWidget {
  const HrPayslipDetailPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final payslip = controller.selectedPayslip;
    if (payslip == null) {
      return const Center(child: Text('工资单不存在'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text(
          '工资明细',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '${hrDate(payslip.periodStart)} - ${hrDate(payslip.periodEnd)}',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 17),
        HrCard(
          background: HrColors.ink,
          borderColor: HrColors.resolve(context, HrColors.ink),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('实发工资', style: HrText.resolve(context, HrText.eyebrow)),
              const SizedBox(height: 8),
              Text(
                hrMoney(payslip.netPay),
                style: HrText.resolve(context, HrText.mono).copyWith(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _PayMetric(
                      label: '应发',
                      value: hrMoney(payslip.grossPay),
                    ),
                  ),
                  Expanded(
                    child: _PayMetric(
                      label: '扣款',
                      value: hrMoney(payslip.deductions),
                    ),
                  ),
                  _PayMetric(label: '状态', value: payslip.status),
                ],
              ),
            ],
          ),
        ),
        const HrSectionHeader(title: '收入明细'),
        _PayComponents(
          items: payslip.earnings,
          accent: HrColors.resolve(context, HrColors.success),
        ),
        const HrSectionHeader(title: '扣款明细'),
        _PayComponents(
          items: payslip.deductionItems,
          accent: HrColors.resolve(context, HrColors.brand),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: HrOutlineButton(
                label: '导出 PDF',
                icon: Icons.download_outlined,
                onPressed: () => hrToast(context, '导出接口已保留，当前为模拟环境'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HrOutlineButton(
                label: '薪酬咨询',
                icon: Icons.support_agent_outlined,
                onPressed: () => hrToast(context, '已通知薪酬服务同事'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PayMetric extends StatelessWidget {
  const _PayMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HrText.resolve(context, HrText.meta).copyWith(
            color: HrColors.resolve(context, HrColors.onDark2),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: HrText.resolve(context, HrText.mono).copyWith(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PayComponents extends StatelessWidget {
  const _PayComponents({required this.items, required this.accent});

  final List<HrPayComponent> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.resolve(context, HrColors.line2),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[i].title,
                      style: HrText.resolve(context, HrText.body),
                    ),
                  ),
                  Text(
                    hrMoney(items[i].amount),
                    style: HrText.resolve(
                      context,
                      HrText.mono,
                    ).copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
