part of 'misc_pages.dart';

class AtsContactPage extends StatefulWidget {
  const AtsContactPage({super.key});

  @override
  State<AtsContactPage> createState() => _AtsContactPageState();
}

class _AtsContactPageState extends State<AtsContactPage> {
  final _content = TextEditingController();

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: AtsColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: AtsColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '企业直聘客服',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                '工作日 09:00 - 18:00',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              _ContactLine(
                icon: Icons.phone_outlined,
                label: '客服电话',
                value: '400-800-6688',
                onTap: () => atsToast(context, '正在拨号 400-800-6688'),
              ),
              const Divider(height: 1),
              _ContactLine(
                icon: Icons.mail_outline,
                label: '客服邮箱',
                value: 'support@wuyoujobs.com',
                onTap: () => atsToast(context, '邮箱地址已复制'),
              ),
              const Divider(height: 1),
              _ContactLine(
                icon: Icons.location_on_outlined,
                label: '公司地址',
                value: '上海市浦东新区张江路 88 号',
                onTap: () => atsToast(context, '正在打开地图导航'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '意见反馈',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              const Text(
                '你的建议会帮助我们做得更好',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                maxLines: 5,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: '请描述你遇到的问题或建议',
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              AtsPrimaryButton(
                label: '提交反馈',
                onPressed: () {
                  if (_content.text.trim().isEmpty) {
                    atsToast(context, '请输入反馈内容');
                    return;
                  }
                  _content.clear();
                  FocusScope.of(context).unfocus();
                  atsToast(context, '感谢反馈，我们会尽快处理');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: AtsColors.primary, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 68,
              child: Text(
                label,
                style: const TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AtsColors.text, fontSize: 12),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AtsColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
