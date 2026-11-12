part of 'profile_pages.dart';

class AtsHideSettingPage extends StatefulWidget {
  const AtsHideSettingPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsHideSettingPage> createState() => _AtsHideSettingPageState();
}

class _AtsHideSettingPageState extends State<AtsHideSettingPage> {
  bool _hideResume = false;
  bool _hideCompany = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                value: _hideResume,
                onChanged: (value) => setState(() => _hideResume = value),
                activeTrackColor: AtsColors.resolve(context, AtsColors.primary),
                title: const Text(
                  '对招聘方隐藏简历',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '开启后招聘方将无法主动查看你的完整简历',
                  style: TextStyle(
                    fontSize: 10,
                    color: AtsColors.resolve(context, AtsColors.textMuted),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _hideCompany,
                onChanged: (value) => setState(() => _hideCompany = value),
                activeTrackColor: AtsColors.resolve(context, AtsColors.primary),
                title: const Text(
                  '隐藏求职活跃状态',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '隐藏最近活跃时间，减少被打扰',
                  style: TextStyle(
                    fontSize: 10,
                    color: AtsColors.resolve(context, AtsColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '屏蔽的企业'),
        AtsCard(
          child: Column(
            children: [
              for (final company in widget.controller.hiddenCompanies)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.business_outlined,
                    color: AtsColors.resolve(context, AtsColors.textMuted),
                  ),
                  title: Text(company, style: const TextStyle(fontSize: 13)),
                  trailing: TextButton(
                    onPressed: () {
                      widget.controller.removeHiddenCompany(company);
                      setState(() {});
                    },
                    child: const Text('取消屏蔽'),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => atsToast(context, '请输入要屏蔽的企业名称'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('添加屏蔽企业'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AtsPrimaryButton(
          label: '保存隐私设置',
          onPressed: () => atsToast(context, '隐私设置已保存'),
        ),
      ],
    );
  }
}
