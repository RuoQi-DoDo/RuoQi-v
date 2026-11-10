part of 'profile_pages.dart';

class AtsEditProjectContentPage extends StatefulWidget {
  const AtsEditProjectContentPage({super.key});

  @override
  State<AtsEditProjectContentPage> createState() =>
      _AtsEditProjectContentPageState();
}

class _AtsEditProjectContentPageState extends State<AtsEditProjectContentPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '项目内容已保存'),
      children: [
        const _EditIntro(title: '项目内容', subtitle: '介绍项目背景、你的职责和取得的成果'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 8,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '请输入项目内容',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}
