part of 'customer_home_page.dart';

class _SettingsPage extends StatefulWidget {
  const _SettingsPage();

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (context) => const _SettingsPage());
  }

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool _messageNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeController = BusinessThemeScope.of(context);
    final hostTheme = _weChatHostTheme(context);
    final isDarkMode = hostTheme.brightness == Brightness.dark;
    return Theme(
      data: hostTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return Scaffold(
            key: const Key('settings-page'),
            backgroundColor: scheme.surface,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: scheme.surfaceContainerLowest,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                key: const Key('settings-back'),
                tooltip: '返回',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
              ),
              title: Text(
                '设置',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            body: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 36),
              children: [
                _SettingsProfileRow(
                  onTap: () => _showSettingsMessage(context, '个人信息为演示入口'),
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsSwitchRow(
                      key: const Key('settings-dark-mode'),
                      title: '深色模式',
                      value: isDarkMode,
                      onChanged: themeController.setDarkMode,
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '账号与安全',
                      onTap: () => _showSettingsMessage(context, '账号与安全为演示入口'),
                    ),
                    _SettingsRow(
                      title: '青少年模式',
                      trailingText: '未开启',
                      onTap: () => _showSettingsMessage(context, '青少年模式为演示入口'),
                    ),
                    _SettingsRow(
                      title: '关怀模式',
                      trailingText: '已关闭',
                      onTap: () => _showSettingsMessage(context, '关怀模式为演示入口'),
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsSwitchRow(
                      key: const Key('settings-message-notifications'),
                      title: '消息通知',
                      value: _messageNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _messageNotificationsEnabled = value);
                      },
                    ),
                    _SettingsRow(
                      title: '聊天',
                      onTap: () => _showSettingsMessage(context, '聊天设置为演示入口'),
                    ),
                    _SettingsRow(
                      title: '通用',
                      onTap: () => _showSettingsMessage(context, '通用设置为演示入口'),
                    ),
                    _SettingsRow(
                      title: '朋友权限',
                      onTap: () => _showSettingsMessage(context, '朋友权限为演示入口'),
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '个人信息与权限',
                      onTap: () =>
                          _showSettingsMessage(context, '个人信息与权限为演示入口'),
                    ),
                    _SettingsRow(
                      title: '个人信息收集清单',
                      onTap: () =>
                          _showSettingsMessage(context, '个人信息收集清单为演示入口'),
                    ),
                    _SettingsRow(
                      title: '第三方信息共享清单',
                      onTap: () =>
                          _showSettingsMessage(context, '第三方信息共享清单为演示入口'),
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '关于微信',
                      trailingText: 'v8.0.58',
                      onTap: () =>
                          _showSettingsMessage(context, 'RuoQi 业务端 1.0.0'),
                    ),
                    _SettingsRow(
                      title: '帮助与反馈',
                      onTap: () => _showSettingsMessage(context, '帮助与反馈为演示入口'),
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '切换账号',
                      onTap: () => _showSettingsMessage(context, '切换账号为演示入口'),
                    ),
                    _SettingsActionRow(
                      key: const Key('settings-logout'),
                      title: '退出登录',
                      color: const Color(0xFFFF5B5B),
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('退出后将返回登录页面，是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                '退出',
                style: TextStyle(color: Color(0xFFFF5B5B)),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted || shouldLogout != true) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showSettingsMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsProfileRow extends StatelessWidget {
  const _SettingsProfileRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0D6B8), Color(0xFFCEA985)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jengro Woo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '微信号：wzgxove',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.qr_code_2_rounded,
                size: 23,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF07C160),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
