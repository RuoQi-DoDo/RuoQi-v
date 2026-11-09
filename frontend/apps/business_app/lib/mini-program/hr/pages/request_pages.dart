import 'package:flutter/material.dart';

import '../hr_controller.dart';
import '../hr_format.dart';
import '../hr_models.dart';
import '../hr_routes.dart';
import '../hr_style.dart';

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

class HrRequestComposePage extends StatefulWidget {
  const HrRequestComposePage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrRequestComposePage> createState() => _HrRequestComposePageState();
}

class _HrRequestComposePageState extends State<HrRequestComposePage> {
  late HrRequestKind _kind;
  final _title = TextEditingController();
  final _detail = TextEditingController();
  final _amount = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _shift = '常规班次';
  String _workType = '远程办公';
  String _asset = '外接显示器';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.controller.requestKind;
  }

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('新建申请', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('选择申请类型，填写必要信息后提交审批。', style: HrText.meta),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in HrRequestKind.values)
              ChoiceChip(
                label: Text(kind.shortLabel),
                selected: _kind == kind,
                showCheckmark: false,
                selectedColor: HrColors.brandTint,
                backgroundColor: HrColors.surface,
                side: BorderSide(
                  color: _kind == kind
                      ? HrColors.brandTintBorder
                      : HrColors.line,
                ),
                labelStyle: TextStyle(
                  color: _kind == kind ? HrColors.brand : HrColors.ink3,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                onSelected: (_) => setState(() => _kind = kind),
              ),
          ],
        ),
        const SizedBox(height: 16),
        HrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_kind.label, style: HrText.cardTitle),
              const SizedBox(height: 4),
              Text(_kind.description, style: HrText.meta),
              const SizedBox(height: 16),
              if (_kind == HrRequestKind.shift) ...[
                _PickerRow(
                  label: '调整班次',
                  value: _shift,
                  options: const ['常规班次', '晚班', '周末班'],
                  onChanged: (value) => setState(() => _shift = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.workType) ...[
                _PickerRow(
                  label: '办公方式',
                  value: _workType,
                  options: const ['远程办公', '办公室办公', '混合办公'],
                  onChanged: (value) => setState(() => _workType = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.asset) ...[
                _PickerRow(
                  label: '申请资产',
                  value: _asset,
                  options: const ['外接显示器', '笔记本电脑', '键盘鼠标', '耳机'],
                  onChanged: (value) => setState(() => _asset = value),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind != HrRequestKind.asset) ...[
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: HrColors.bg2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text('生效日期', style: HrText.meta),
                        const Spacer(),
                        Text(
                          '${hrDate(_date)} ${hrWeekday(_date)}',
                          style: HrText.mono.copyWith(fontSize: 12),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 17,
                          color: HrColors.brand,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (_kind == HrRequestKind.expense)
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: '填写报销金额',
                    prefixText: '¥ ',
                  ),
                ),
              if (_kind == HrRequestKind.expense) const SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText: switch (_kind) {
                    HrRequestKind.shift => '调班原因标题，例如：项目值班',
                    HrRequestKind.workType => '例如：客户现场支持',
                    HrRequestKind.expense => '报销事项，例如：客户拜访交通费',
                    HrRequestKind.asset => '申请用途，例如：居家办公',
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detail,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '补充说明，便于审批人了解具体情况'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        HrCard(
          background: HrColors.infoBg,
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: HrColors.info, size: 19),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '默认使用模拟审批流。切换真实 API 后，提交内容将写入对应的 Horilla 接口。',
                  style: HrText.meta.copyWith(color: HrColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交申请',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '选择生效日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    final typedTitle = _title.text.trim();
    final typedDetail = _detail.text.trim();
    final title = typedTitle.isEmpty ? _defaultTitle : typedTitle;
    final detailParts = <String>[
      if (_kind == HrRequestKind.shift) '$_shift · ${hrDate(_date)}',
      if (_kind == HrRequestKind.workType) '$_workType · ${hrDate(_date)}',
      if (_kind == HrRequestKind.asset) _asset,
      if (_kind == HrRequestKind.expense)
        '¥${_amount.text.trim().isEmpty ? '0.00' : _amount.text.trim()}',
      if (typedDetail.isNotEmpty) typedDetail,
    ];
    setState(() => _submitting = true);
    try {
      await widget.controller.submitRequest(
        title: title,
        detail: detailParts.join(' · '),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '${_kind.label}已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String get _defaultTitle => switch (_kind) {
    HrRequestKind.shift => '临时调班',
    HrRequestKind.workType => _workType,
    HrRequestKind.expense => '费用报销',
    HrRequestKind.asset => _asset,
  };
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: HrColors.bg2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(label, style: HrText.meta),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              borderRadius: BorderRadius.circular(14),
              style: HrText.cardTitle.copyWith(fontSize: 12.5),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: HrColors.brand,
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
        Text('工资单', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('工资条由薪酬团队统一发布，仅本人可见。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          onTap: () => controller.openPayslip(latest.id),
          background: HrColors.ink,
          borderColor: HrColors.ink,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(child: Text('最近一期实发', style: HrText.eyebrow)),
                  HrStatusChip(
                    label: '已发放',
                    background: HrColors.onDarkTile,
                    foreground: Color(0xFF72D2A6),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hrMoney(latest.netPay),
                style: HrText.mono.copyWith(
                  color: HrColors.surface,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.3,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${latest.periodStart.year} 年 ${latest.periodStart.month} 月 · '
                '应发 ${hrMoney(latest.grossPay)}',
                style: HrText.meta.copyWith(color: HrColors.onDark2),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '查看完整工资明细',
                      style: TextStyle(
                        color: HrColors.surface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: HrColors.surface.withValues(alpha: 0.8),
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
                    color: HrColors.warningBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${payslip.periodStart.month}月',
                    style: const TextStyle(
                      color: HrColors.warning,
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
                        style: HrText.cardTitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text('实发 ${hrMoney(payslip.netPay)}', style: HrText.meta),
                    ],
                  ),
                ),
                HrStatusChip(label: payslip.status),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: HrColors.ink4,
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
        Text('工资明细', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        Text(
          '${hrDate(payslip.periodStart)} - ${hrDate(payslip.periodEnd)}',
          style: HrText.meta,
        ),
        const SizedBox(height: 17),
        HrCard(
          background: HrColors.ink,
          borderColor: HrColors.ink,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('实发工资', style: HrText.eyebrow),
              const SizedBox(height: 8),
              Text(
                hrMoney(payslip.netPay),
                style: HrText.mono.copyWith(
                  color: HrColors.surface,
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
        _PayComponents(items: payslip.earnings, accent: HrColors.success),
        const HrSectionHeader(title: '扣款明细'),
        _PayComponents(items: payslip.deductionItems, accent: HrColors.brand),
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
          style: HrText.meta.copyWith(color: HrColors.onDark2, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: HrText.mono.copyWith(
            color: HrColors.surface,
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
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: HrColors.line2,
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
                  Expanded(child: Text(items[i].title, style: HrText.body)),
                  Text(
                    hrMoney(items[i].amount),
                    style: HrText.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
