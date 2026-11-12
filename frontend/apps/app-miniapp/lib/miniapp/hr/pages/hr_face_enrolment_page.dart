part of 'service_pages.dart';

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
        Text(
          '人脸录入',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '录入一张清晰的正面照片，用于 HR 复核与人脸打卡参考。',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 220,
            height: 250,
            decoration: BoxDecoration(
              color: _captured
                  ? HrColors.resolve(context, HrColors.successBg)
                  : HrColors.ink,
              borderRadius: BorderRadius.circular(78),
              border: Border.all(
                color: _captured
                    ? HrColors.resolve(context, HrColors.success)
                    : HrColors.resolve(context, HrColors.brandLight),
                width: 3,
              ),
              boxShadow: HrShadows.hero,
            ),
            child: Icon(
              _captured
                  ? Icons.check_circle_outline_rounded
                  : Icons.add_a_photo_outlined,
              size: 76,
              color: _captured
                  ? HrColors.resolve(context, HrColors.success)
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          _captured ? '照片已拍摄，可确认保存' : '将面部置于框内',
          textAlign: TextAlign.center,
          style: HrText.resolve(
            context,
            HrText.cardTitle,
          ).copyWith(fontSize: 17),
        ),
        const SizedBox(height: 6),
        Text(
          _captured ? '请确认光线均匀、无遮挡' : '静态预览不会请求相机权限',
          textAlign: TextAlign.center,
          style: HrText.resolve(context, HrText.meta),
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
          background: HrColors.resolve(context, HrColors.warningBg),
          borderColor: HrColors.resolve(context, HrColors.warningBorder),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: HrColors.resolve(context, HrColors.warningInk),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '人脸照片属于敏感个人信息，仅用于公司考勤身份核验，不会用于其他用途。',
                  style: HrText.resolve(context, HrText.meta).copyWith(
                    color: HrColors.resolve(context, HrColors.warningInk),
                  ),
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
