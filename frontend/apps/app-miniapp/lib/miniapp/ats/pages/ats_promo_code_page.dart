part of 'profile_pages.dart';

class AtsPromoCodePage extends StatelessWidget {
  const AtsPromoCodePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AtsColors.resolve(context, AtsColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
            decoration: BoxDecoration(
              color: AtsColors.resolve(context, AtsColors.surface),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                AtsAvatar(label: controller.userName, size: 60),
                const SizedBox(height: 10),
                Text(
                  controller.userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '邀请码：212121',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.primary),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 178,
                  height: 178,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AtsColors.resolve(context, AtsColors.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AtsColors.resolve(context, AtsColors.divider),
                    ),
                  ),
                  child: const _FakeQrCode(),
                ),
                const SizedBox(height: 16),
                Text(
                  '微信扫描上方二维码即可注册',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.textSecondary),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '截图保存二维码到手机或微信识别',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.textMuted),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 20),
                AtsPrimaryButton(
                  label: '保存推广码',
                  icon: Icons.download_outlined,
                  onPressed: () => atsToast(context, '推广码已保存'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_outlined,
                size: 18,
                color: AtsColors.resolve(context, AtsColors.primary),
              ),
              SizedBox(width: 6),
              Text(
                '企业直聘',
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.primary),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FakeQrCode extends StatelessWidget {
  const _FakeQrCode();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 21 * 21,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 21,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 21;
        final col = index % 21;
        final corner =
            (row < 7 && col < 7) ||
            (row < 7 && col > 13) ||
            (row > 13 && col < 7);
        final fill = corner
            ? (row == 0 ||
                  row == 6 ||
                  col == 0 ||
                  col == 6 ||
                  (row >= 2 && row <= 4 && col >= 2 && col <= 4) ||
                  (col >= 15 && col <= 19 && row == 0) ||
                  (row >= 15 && row <= 19 && col == 0))
            : ((index * 7 + col * 3) % 11 < 4);
        return ColoredBox(
          color: fill
              ? AtsColors.resolve(context, AtsColors.text)
              : Colors.transparent,
        );
      },
    );
  }
}
