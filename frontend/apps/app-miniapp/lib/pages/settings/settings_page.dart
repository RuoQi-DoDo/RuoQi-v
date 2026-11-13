import 'package:flutter/material.dart';

import '../account/account.dart';
import '../auth/login_page.dart';
import '../common/page_localizations.dart';
import '../common/page_theme.dart';
import '../display/display_settings_page.dart';

/// App settings shared by business hosts and standalone routes.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onLogout, this.loginBuilder});

  /// A business may handle its own session cleanup and navigation after logout.
  final VoidCallback? onLogout;

  /// Destination used after logout when [onLogout] is not supplied.
  final WidgetBuilder? loginBuilder;

  static Route<void> route({
    VoidCallback? onLogout,
    WidgetBuilder? loginBuilder,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) =>
          SettingsPage(onLogout: onLogout, loginBuilder: loginBuilder),
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _messageNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final hostTheme = sharedPageTheme(context);
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
              toolbarHeight: 50,
              centerTitle: true,
              backgroundColor: HostChromeStyle.appBarBackground(context),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                key: const Key('settings-back'),
                tooltip: pageLabel(context, '返回'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
              ),
              title: Text(
                pageLabel(context, '设置'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: const Border(),
            ),
            body: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 36),
              children: [
                _SettingsSearchField(
                  onTap: () => _showSettingsMessage(context, '搜索设置为演示入口'),
                ),
                const _SettingsSectionHeader('账号'),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '个人资料',
                      onTap: () => _showSettingsMessage(context, '个人资料为演示入口'),
                    ),
                    _SettingsRow(
                      title: '账号安全',
                      onTap: () => Navigator.of(
                        context,
                      ).push(AccountSecurityPage.route()),
                    ),
                    _SettingsRow(
                      title: '个人信息与权限',
                      onTap: () =>
                          _showSettingsMessage(context, '个人信息与权限为演示入口'),
                    ),
                  ],
                ),
                const _SettingsSectionHeader('通用'),
                _SettingsGroup(
                  rows: [
                    _SettingsSwitchRow(
                      key: const Key('settings-message-notifications'),
                      title: '通知',
                      value: _messageNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _messageNotificationsEnabled = value);
                      },
                    ),
                    _SettingsRow(
                      title: '界面与显示',
                      onTap: () => Navigator.of(
                        context,
                      ).push(DisplaySettingsPage.route()),
                    ),
                    _SettingsRow(
                      title: '朋友权限',
                      onTap: () => _showSettingsMessage(context, '朋友权限为演示入口'),
                    ),
                    _SettingsRow(
                      title: '存储空间',
                      onTap: () => _showSettingsMessage(context, '存储空间为演示入口'),
                    ),
                    _SettingsRow(
                      title: '更多',
                      onTap: () => _showSettingsMessage(context, '更多设置为演示入口'),
                    ),
                  ],
                ),
                const _SettingsSectionHeader('功能'),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '聊天',
                      onTap: () => _showSettingsMessage(context, '聊天设置为演示入口'),
                    ),
                    _SettingsRow(
                      title: '音视频通话',
                      onTap: () =>
                          _showSettingsMessage(context, '音视频通话设置为演示入口'),
                    ),
                    _SettingsRow(
                      title: '聊天记录管理',
                      onTap: () => _showSettingsMessage(context, '聊天记录管理为演示入口'),
                    ),
                  ],
                ),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      title: '帮助与反馈',
                      onTap: () => _showSettingsMessage(context, '帮助与反馈为演示入口'),
                    ),
                    _SettingsRow(
                      title: '关于微信',
                      trailingText: 'v8.0.58',
                      onTap: () =>
                          _showSettingsMessage(context, 'RuoQi 业务端 1.0.0'),
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
          title: Text(pageLabel(context, '退出登录')),
          content: Text(pageLabel(context, '退出后将返回登录页面，是否继续？')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(pageLabel(context, '取消')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                pageLabel(context, '退出'),
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
    final onLogout = widget.onLogout;
    if (onLogout != null) {
      onLogout();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: widget.loginBuilder ?? (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void _showSettingsMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsSearchField extends StatelessWidget {
  const _SettingsSearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 36,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              pageLabel(context, '搜索'),
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 30,
      padding: const EdgeInsets.only(left: 14),
      alignment: Alignment.centerLeft,
      child: Text(
        pageLabel(context, title),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final hairline = HostChromeStyle.hairline(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Divider(
                  height: hairline,
                  thickness: hairline,
                  color: HostChromeStyle.dividerColor(context),
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
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  pageLabel(context, title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  pageLabel(context, trailingText!),
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
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              pageLabel(context, title),
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
              pageLabel(context, title),
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
