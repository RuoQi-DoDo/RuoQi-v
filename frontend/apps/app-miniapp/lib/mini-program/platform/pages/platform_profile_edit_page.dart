import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';

class PlatformProfileEditPage extends StatefulWidget {
  const PlatformProfileEditPage({
    super.key,
    required this.controller,
    required this.field,
  });

  final PlatformAccountController controller;
  final PlatformProfileField field;

  @override
  State<PlatformProfileEditPage> createState() =>
      _PlatformProfileEditPageState();
}

class _PlatformProfileEditPageState extends State<PlatformProfileEditPage> {
  late final TextEditingController _nicknameController;
  late String _gender;
  late int _age;
  late int _avatarStyle;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.controller.nickname,
    );
    _gender = widget.controller.gender;
    _age = widget.controller.age;
    _avatarStyle = widget.controller.avatarStyle;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (title, subtitle) = switch (widget.field) {
      PlatformProfileField.avatar => ('修改头像', '选择一组当前小程序可用的头像样式'),
      PlatformProfileField.nickname => ('修改昵称', '昵称会显示在平台账号与操作记录中'),
      PlatformProfileField.gender => ('修改性别', '选择适合你的个人资料展示方式'),
      PlatformProfileField.age => ('修改年龄', '年龄仅用于完善个人资料'),
    };
    return Scaffold(
      backgroundColor: PlatformStyle.pageBackground(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('platform-profile-edit-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(title: title, subtitle: subtitle),
            PlatformCard(
              padding: const EdgeInsets.all(18),
              child: switch (widget.field) {
                PlatformProfileField.avatar => _buildAvatarPicker(context),
                PlatformProfileField.nickname => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlatformTextField(
                      controller: _nicknameController,
                      label: '昵称',
                      hint: '请输入昵称',
                      inputFormatters: [LengthLimitingTextInputFormatter(16)],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '最多 16 个字符',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                PlatformProfileField.gender => SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: '男',
                        icon: Icon(Icons.male_rounded),
                        label: Text('男'),
                      ),
                      ButtonSegment(
                        value: '女',
                        icon: Icon(Icons.female_rounded),
                        label: Text('女'),
                      ),
                      ButtonSegment(
                        value: '保密',
                        icon: Icon(Icons.lock_outline_rounded),
                        label: Text('保密'),
                      ),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (selection) {
                      setState(() => _gender = selection.first);
                    },
                  ),
                ),
                PlatformProfileField.age => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '当前年龄',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_age 岁',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _age.toDouble(),
                      min: 18,
                      max: 80,
                      divisions: 62,
                      label: '$_age',
                      onChanged: (value) {
                        setState(() => _age = value.round());
                      },
                    ),
                    Text(
                      '拖动滑块选择年龄',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              },
            ),
            const SizedBox(height: 24),
            PlatformPrimaryButton(
              key: const Key('platform-profile-save'),
              label: '保存修改',
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        for (var index = 0; index < 4; index++)
          InkWell(
            onTap: () => setState(() => _avatarStyle = index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: index == _avatarStyle
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : PlatformStyle.cardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: index == _avatarStyle
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Center(child: PlatformAvatar(size: 58, styleIndex: index)),
            ),
          ),
      ],
    );
  }

  void _save() {
    switch (widget.field) {
      case PlatformProfileField.avatar:
        widget.controller.updateAvatarStyle(_avatarStyle);
      case PlatformProfileField.nickname:
        final value = _nicknameController.text.trim();
        if (value.isEmpty) {
          showPlatformToast(context, '昵称不能为空');
          return;
        }
        widget.controller.updateNickname(value);
      case PlatformProfileField.gender:
        widget.controller.updateGender(_gender);
      case PlatformProfileField.age:
        widget.controller.updateAge(_age);
    }
    showPlatformToast(context, '个人资料已更新');
    Navigator.of(context).pop();
  }
}
