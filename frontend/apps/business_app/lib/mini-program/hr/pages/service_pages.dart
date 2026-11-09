import 'package:flutter/material.dart';

import '../hr_controller.dart';
import '../hr_style.dart';

class HrSignInPage extends StatefulWidget {
  const HrSignInPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrSignInPage> createState() => _HrSignInPageState();
}

class _HrSignInPageState extends State<HrSignInPage> {
  final _server = TextEditingController(text: 'hr.ruoqi.example');
  final _account = TextEditingController(text: 'zhixia.lin');
  final _password = TextEditingController(text: 'ruoqi-demo');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _server.dispose();
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
      children: [
        const Center(child: HrLogoMark(size: 68)),
        const SizedBox(height: 18),
        Text(
          'RuoQi 人事',
          textAlign: TextAlign.center,
          style: HrText.appBarTitle.copyWith(fontSize: 27),
        ),
        const SizedBox(height: 6),
        Text(
          '员工自助 · 考勤 · 休假 · 薪酬',
          textAlign: TextAlign.center,
          style: HrText.meta,
        ),
        const SizedBox(height: 28),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('连接 Horilla HR', style: HrText.cardTitle),
              const SizedBox(height: 4),
              const Text(
                '演示环境已预填服务器与账号，真实接入时由 HR 管理员提供地址。',
                style: HrText.meta,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _server,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'hr.company.com',
                  prefixIcon: Icon(Icons.dns_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _account,
                decoration: const InputDecoration(
                  labelText: '账号',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? '显示密码' : '隐藏密码',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HrPrimaryButton(
                label: _loading ? '正在进入…' : '进入人事工作台',
                icon: Icons.login_rounded,
                onPressed: _loading ? null : _signIn,
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
              const Icon(Icons.info_outline, color: HrColors.info, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '当前为静态登录页，不会发送真实密码。关闭模拟数据后，请通过注入的 RuoQiNetworkClient 完成鉴权。',
                  style: HrText.meta.copyWith(color: HrColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '登录即表示同意企业隐私政策与信息安全规范',
          textAlign: TextAlign.center,
          style: HrText.meta.copyWith(color: HrColors.ink4, fontSize: 10),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (_server.text.trim().isEmpty ||
        _account.text.trim().isEmpty ||
        _password.text.isEmpty) {
      hrToast(context, '请填写服务器地址、账号和密码');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    widget.controller.completeSignIn();
    hrToast(context, '已进入 ${widget.controller.user.name} 的人事工作台');
  }
}

class HrLeaveAllocationPage extends StatefulWidget {
  const HrLeaveAllocationPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrLeaveAllocationPage> createState() => _HrLeaveAllocationPageState();
}

class _HrLeaveAllocationPageState extends State<HrLeaveAllocationPage> {
  final _reason = TextEditingController();
  String _type = '年假';
  double _days = 1;
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('额度追加申请', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('额外假期额度由 HR 审批，不进入直属主管审批流。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('假期类型', style: HrText.eyebrow),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in ['年假', '病假', '调休', '事假'])
                    ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      showCheckmark: false,
                      selectedColor: HrColors.brandTint,
                      backgroundColor: HrColors.bg2,
                      side: BorderSide(
                        color: _type == type
                            ? HrColors.brandTintBorder
                            : HrColors.line,
                      ),
                      labelStyle: TextStyle(
                        color: _type == type ? HrColors.brand : HrColors.ink3,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('申请天数', style: HrText.eyebrow),
                        const SizedBox(height: 6),
                        Text(
                          _days == _days.roundToDouble()
                              ? _days.toStringAsFixed(0)
                              : _days.toStringAsFixed(1),
                          style: HrText.mono.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onTap: _days > 0.5
                        ? () => setState(() => _days -= 0.5)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onTap: () => setState(() => _days += 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: HrColors.line2),
              const SizedBox(height: 12),
              Text(
                '当前 $_type 余额 '
                '${_currentBalance(widget.controller, _type)} 天',
                style: HrText.meta,
              ),
            ],
          ),
        ),
        const HrSectionHeader(
          title: '申请原因',
          padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
        ),
        TextField(
          controller: _reason,
          minLines: 4,
          maxLines: 6,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: '请说明需要额外额度的原因',
            counterStyle: HrText.meta,
          ),
        ),
        const SizedBox(height: 14),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交 HR 审批',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_reason.text.trim().isEmpty) {
      hrToast(context, '请填写额度追加原因');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submitLeaveAllocation(
        type: _type,
        days: _days,
        reason: _reason.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '$_type额度追加申请已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  static String _currentBalance(HrAppController controller, String type) {
    for (final balance in controller.leaveBalances) {
      if (balance.type == type) {
        return balance.availableDays == balance.availableDays.roundToDouble()
            ? '${balance.availableDays.toInt()}'
            : '${balance.availableDays}';
      }
    }
    return '--';
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HrColors.line),
        ),
        child: Icon(
          icon,
          size: 19,
          color: onTap == null ? HrColors.ink4 : HrColors.ink,
        ),
      ),
    );
  }
}

class HrHelpdeskPage extends StatefulWidget {
  const HrHelpdeskPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrHelpdeskPage> createState() => _HrHelpdeskPageState();
}

class _HrHelpdeskPageState extends State<HrHelpdeskPage> {
  final _subject = TextEditingController();
  final _description = TextEditingController();
  String _category = '人事政策';
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('员工服务台', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('找不到入口或需要人工协助，可以在这里提交服务工单。', style: HrText.meta),
        const SizedBox(height: 17),
        HrCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('问题类型', style: HrText.eyebrow),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ['人事政策', '考勤异常', '薪酬福利', '系统故障'])
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      showCheckmark: false,
                      selectedColor: HrColors.brandTint,
                      backgroundColor: HrColors.bg2,
                      side: BorderSide(
                        color: _category == category
                            ? HrColors.brandTintBorder
                            : HrColors.line,
                      ),
                      labelStyle: TextStyle(
                        color: _category == category
                            ? HrColors.brand
                            : HrColors.ink3,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subject,
                decoration: const InputDecoration(
                  labelText: '问题标题',
                  hintText: '用一句话描述你的问题',
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _description,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: '详细说明',
                  hintText: '补充发生时间、相关页面和期望处理方式',
                ),
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
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: HrColors.info,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '服务时间为工作日 09:00 - 18:00，通常会在 1 个工作日内回复。',
                  style: HrText.meta.copyWith(color: HrColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        HrPrimaryButton(
          label: _submitting ? '提交中…' : '提交服务工单',
          icon: Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_subject.text.trim().isEmpty || _description.text.trim().isEmpty) {
      hrToast(context, '请填写问题标题和详细说明');
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submitHelpdeskTicket(
        category: _category,
        subject: _subject.text.trim(),
        description: _description.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '服务工单已提交');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class HrFaceEnrolmentPage extends StatefulWidget {
  const HrFaceEnrolmentPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrFaceEnrolmentPage> createState() => _HrFaceEnrolmentPageState();
}

class _HrFaceEnrolmentPageState extends State<HrFaceEnrolmentPage> {
  bool _captured = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      children: [
        Text('人脸录入', style: HrText.appBarTitle.copyWith(fontSize: 25)),
        const SizedBox(height: 5),
        const Text('录入一张清晰的正面照片，用于 HR 复核与人脸打卡参考。', style: HrText.meta),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 220,
            height: 250,
            decoration: BoxDecoration(
              color: _captured ? HrColors.successBg : HrColors.ink,
              borderRadius: BorderRadius.circular(78),
              border: Border.all(
                color: _captured ? HrColors.success : HrColors.brandLight,
                width: 3,
              ),
              boxShadow: HrShadows.hero,
            ),
            child: Icon(
              _captured
                  ? Icons.check_circle_outline_rounded
                  : Icons.add_a_photo_outlined,
              size: 76,
              color: _captured ? HrColors.success : HrColors.surface,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          _captured ? '照片已拍摄，可确认保存' : '将面部置于框内',
          textAlign: TextAlign.center,
          style: HrText.cardTitle.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(
          _captured ? '请确认光线均匀、无遮挡' : '静态预览不会请求相机权限',
          textAlign: TextAlign.center,
          style: HrText.meta,
        ),
        const SizedBox(height: 24),
        if (_captured) ...[
          Row(
            children: [
              Expanded(
                child: HrOutlineButton(
                  label: '重新拍摄',
                  onPressed: _saving
                      ? null
                      : () => setState(() => _captured = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HrPrimaryButton(
                  label: _saving ? '保存中…' : '确认保存',
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ] else
          HrPrimaryButton(
            label: '开始拍照',
            icon: Icons.camera_alt_outlined,
            onPressed: () => setState(() => _captured = true),
          ),
        const SizedBox(height: 14),
        HrCard(
          background: HrColors.warningBg,
          borderColor: HrColors.warningBorder,
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.privacy_tip_outlined,
                color: HrColors.warningInk,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '人脸照片属于敏感个人信息，仅用于公司考勤身份核验，不会用于其他用途。',
                  style: HrText.meta.copyWith(color: HrColors.warningInk),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.controller.enrollFace();
      if (!mounted) {
        return;
      }
      widget.controller.back();
      hrToast(context, '人脸参考照片已保存');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
