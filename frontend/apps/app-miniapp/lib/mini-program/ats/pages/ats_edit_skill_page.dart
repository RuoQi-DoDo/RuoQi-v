part of 'profile_pages.dart';

class AtsEditSkillPage extends StatefulWidget {
  const AtsEditSkillPage({super.key});

  @override
  State<AtsEditSkillPage> createState() => _AtsEditSkillPageState();
}

class _AtsEditSkillPageState extends State<AtsEditSkillPage> {
  final _controller = TextEditingController(text: atsResumes.first.skill);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _EditPageLayout(
      onSave: () => atsToast(context, '个人优势已保存'),
      children: [
        const _EditIntro(title: '我的优势', subtitle: '一句话介绍自己，突出与目标岗位匹配的核心优势'),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          maxLines: 7,
          maxLength: 300,
          decoration: const InputDecoration(
            hintText: '例如：4年移动端研发经验，擅长 Flutter 性能优化……',
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 13, height: 1.7),
        ),
      ],
    );
  }
}
