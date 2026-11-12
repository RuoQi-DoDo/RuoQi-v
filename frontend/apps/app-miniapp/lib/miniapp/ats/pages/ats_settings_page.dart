part of 'misc_pages.dart';

class AtsSettingsPage extends StatefulWidget {
  const AtsSettingsPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsSettingsPage> createState() => _AtsSettingsPageState();
}

class _AtsSettingsPageState extends State<AtsSettingsPage> {
  bool _notifications = true;
  bool _recommendations = true;
  bool _wifiOnly = false;

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
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '消息通知',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '接收面试、投递和聊天消息提醒',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _recommendations,
                onChanged: (value) => setState(() => _recommendations = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '个性化推荐',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  '根据简历和浏览记录推荐职位',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                value: _wifiOnly,
                onChanged: (value) => setState(() => _wifiOnly = value),
                activeTrackColor: AtsColors.primary,
                title: const Text(
                  '仅 Wi-Fi 下载',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '账号与偏好'),
        AtsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AtsListRow(
                icon: Icons.person_outline,
                title: '账号与安全',
                onTap: () => widget.controller.open(AtsRoute.userInfo),
              ),
              AtsListRow(
                icon: Icons.delete_outline,
                title: '清除缓存',
                trailing: const Text(
                  '28.6 MB',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
                ),
                onTap: () => _showClearCache(context),
              ),
              AtsListRow(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: () => widget.controller.open(AtsRoute.terms),
              ),
              AtsListRow(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () => widget.controller.open(AtsRoute.privacy),
              ),
              AtsListRow(
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: () => widget.controller.open(AtsRoute.aboutUs),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AtsPrimaryButton(
          label: '退出登录',
          backgroundColor: const Color(0xFFFFF0F0),
          foregroundColor: AtsColors.red,
          onPressed: () => _showLogout(context),
        ),
        const SizedBox(height: 22),
        const Text(
          '企业直聘 v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  void _showClearCache(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定清除图片和临时文件缓存吗？不会删除你的简历和投递记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              atsToast(context, '缓存已清除');
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('退出后仍可浏览职位，投递和聊天需要重新登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.logout();
            },
            style: TextButton.styleFrom(foregroundColor: AtsColors.red),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}
