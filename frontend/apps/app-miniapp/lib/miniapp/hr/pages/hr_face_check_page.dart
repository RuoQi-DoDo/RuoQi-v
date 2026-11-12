part of 'punch_pages.dart';

class HrFaceCheckPage extends StatefulWidget {
  const HrFaceCheckPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrFaceCheckPage> createState() => _HrFaceCheckPageState();
}

class _HrFaceCheckPageState extends State<HrFaceCheckPage> {
  bool _scanning = false;
  bool _verified = false;
  bool _punching = false;

  @override
  Widget build(BuildContext context) {
    final clockIn = !widget.controller.punch.isClockedIn;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      children: [
        Text(
          '人脸核验',
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 5),
        Text(
          '请正对屏幕并保持光线充足，核验通过后完成本次打卡。',
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 28),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 230,
            height: 260,
            decoration: BoxDecoration(
              color: _verified
                  ? HrColors.resolve(context, HrColors.successBg)
                  : HrColors.ink,
              borderRadius: BorderRadius.circular(80),
              border: Border.all(
                color: _verified
                    ? HrColors.resolve(context, HrColors.success)
                    : HrColors.resolve(context, HrColors.brandLight),
                width: 3,
              ),
              boxShadow: HrShadows.hero,
            ),
            child: Center(
              child: Icon(
                _verified
                    ? Icons.verified_user_rounded
                    : Icons.face_retouching_natural,
                size: 82,
                color: _verified
                    ? HrColors.resolve(context, HrColors.success)
                    : Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 23),
        Text(
          _verified
              ? '身份核验成功'
              : _scanning
              ? '正在识别人脸…'
              : '等待开始核验',
          textAlign: TextAlign.center,
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 19),
        ),
        const SizedBox(height: 6),
        Text(
          _verified ? '已匹配员工 ${widget.controller.user.name}' : '照片仅用于当前打卡核验',
          textAlign: TextAlign.center,
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 26),
        if (_verified)
          HrPrimaryButton(
            label: _punching ? '正在打卡…' : (clockIn ? '完成上班打卡' : '完成下班打卡'),
            icon: Icons.fingerprint_rounded,
            onPressed: _punching ? null : _completePunch,
          )
        else
          HrPrimaryButton(
            label: _scanning ? '识别中…' : '开始人脸核验',
            icon: Icons.face_retouching_natural,
            onPressed: _scanning ? null : _scan,
          ),
        const SizedBox(height: 12),
        HrCard(
          padding: const EdgeInsets.all(14),
          background: HrColors.resolve(context, HrColors.infoBg),
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: HrColors.resolve(context, HrColors.info),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '当前为静态演示，不会调用相机或上传生物识别数据。',
                  style: HrText.resolve(
                    context,
                    HrText.meta,
                  ).copyWith(color: HrColors.resolve(context, HrColors.info)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _scanning = false;
        _verified = true;
      });
    }
  }

  Future<void> _completePunch() async {
    final clockIn = !widget.controller.punch.isClockedIn;
    setState(() => _punching = true);
    try {
      await widget.controller.punchNow();
      if (!mounted) {
        return;
      }
      widget.controller.resetToHome();
      hrToast(context, clockIn ? '人脸核验成功，已上班打卡' : '人脸核验成功，已下班打卡');
    } finally {
      if (mounted) {
        setState(() => _punching = false);
      }
    }
  }
}
