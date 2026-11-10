part of 'profile_pages.dart';

class AtsEditWorkContentPage extends StatefulWidget {
  const AtsEditWorkContentPage({super.key});

  @override
  State<AtsEditWorkContentPage> createState() => _AtsEditWorkContentPageState();
}

class _AtsEditWorkContentPageState extends State<AtsEditWorkContentPage> {
  final _controller = TextEditingController(
    text:
        '负责核心业务 App 架构升级和性能优化，搭建组件库与自动化发布流程，'
        '关键页面渲染性能提升 35%。',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '工作内容已保存'),
      children: [
        const _EditIntro(title: '工作内容', subtitle: '用简洁的语言描述职责、成果和关键数据'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 8,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: '请输入工作内容',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}
