import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../ai/deepseek_api.dart';
import '../ai/deepseek_settings_store.dart';
import '../account/account.dart';
import '../auth/login_page.dart';
import '../common/page_localizations.dart';
import '../common/page_theme.dart';
import '../display/display_settings_page.dart';
import '../../localization.dart';

part 'ai_model_settings_page.dart';

/// App settings shared by business hosts and standalone routes.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.onLogout,
    this.loginBuilder,
    this.deepSeekSettingsStore,
  });

  /// A business may handle its own session cleanup and navigation after logout.
  final VoidCallback? onLogout;

  /// Destination used after logout when [onLogout] is not supplied.
  final WidgetBuilder? loginBuilder;
  final DeepSeekSettingsStore? deepSeekSettingsStore;

  static Route<void> route({
    VoidCallback? onLogout,
    WidgetBuilder? loginBuilder,
    DeepSeekSettingsStore? deepSeekSettingsStore,
  }) {
    return MaterialPageRoute<void>(
      builder: (context) => SettingsPage(
        onLogout: onLogout,
        loginBuilder: loginBuilder,
        deepSeekSettingsStore: deepSeekSettingsStore,
      ),
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _messageNotificationsEnabled = true;
  String _selectedAiModel = '未选择';

  DeepSeekSettingsStore get _deepSeekStore =>
      widget.deepSeekSettingsStore ??
      const SharedPreferencesDeepSeekSettingsStore();

  @override
  void initState() {
    super.initState();
    unawaited(_loadAiSettings());
  }

  @override
  Widget build(BuildContext context) {
    final hostTheme = sharedPageTheme(context);
    return Theme(
      data: hostTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          const buildVersion = String.fromEnvironment(
            'FLUTTER_BUILD_NAME',
            defaultValue: 'dev',
          );
          final displayedVersion = buildVersion.startsWith('v')
              ? buildVersion
              : 'v$buildVersion';
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
                      onTap: () =>
                          Navigator.of(context)
                              .push(AccountSecurityPage.route()),
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
                      onTap: () =>
                          Navigator.of(context)
                              .push(DisplaySettingsPage.route()),
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
                const _SettingsSectionHeader('AI'),
                _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      key: const Key('settings-ai-model'),
                      title: '模型',
                      trailingText: _selectedAiModel,
                      onTap: _openAiModelSettings,
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
                      title: '关于RuoQi',
                      trailingText: displayedVersion,
                      onTap: () => _showSettingsMessage(
                        context,
                        'RuoQi $displayedVersion',
                      ),
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

  Future<void> _openAiModelSettings() async {
    await Navigator.of(context)
        .push<void>(AiModelSettingsPage.route(settingsStore: _deepSeekStore));
    if (!mounted) {
      return;
    }
    await _loadAiSettings();
  }

  Future<void> _loadAiSettings() async {
    try {
      final settings = await _deepSeekStore.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedAiModel = settings.selectedModelName.isEmpty
            ? '未选择'
            : settings.selectedModelName;
      });
    } catch (_) {
      // Keep settings usable if local storage is unavailable.
    }
  }

  void _showSettingsMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AiModelOption {
  const _AiModelOption({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String description;
  final IconData icon;
  final Color color;
}

class _DeepSeekApiKeyEditor extends StatelessWidget {
  const _DeepSeekApiKeyEditor({
    required this.controller,
    required this.obscure,
    required this.loading,
    required this.onToggleVisibility,
    required this.onConnect,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleVisibility;
  final VoidCallback onConnect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        children: [
          TextField(
            key: const Key('deepseek-api-key'),
            controller: controller,
            obscureText: obscure,
            enableSuggestions: false,
            autocorrect: false,
            style: TextStyle(color: scheme.onSurface, fontSize: 15),
            decoration: InputDecoration(
              labelText: pageLabel(context, 'DeepSeek API Key'),
              hintText: 'sk-...',
              prefixIcon: const Icon(Icons.key_rounded, size: 20),
              suffixIcon: IconButton(
                key: const Key('deepseek-api-key-visibility'),
                tooltip: pageLabel(
                  context,
                  obscure ? '显示 API Key' : '隐藏 API Key',
                ),
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                key: const Key('deepseek-api-key-clear'),
                onPressed: loading ? null : onClear,
                child: Text(pageLabel(context, '清除')),
              ),
              const Spacer(),
              FilledButton.icon(
                key: const Key('deepseek-api-key-connect'),
                onPressed: loading ? null : onConnect,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4D6BFE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                ),
                icon: loading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.link_rounded, size: 18),
                label: Text(pageLabel(context, loading ? '正在连接' : '连接并获取模型')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeepSeekErrorNotice extends StatelessWidget {
  const _DeepSeekErrorNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5B5B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD7464F),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFD7464F),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepSeekBalanceSummary extends StatelessWidget {
  const _DeepSeekBalanceSummary({required this.balance});

  final DeepSeekBalance balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                balance.isAvailable
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: balance.isAvailable
                    ? const Color(0xFF1B9A62)
                    : const Color(0xFFD7464F),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.text(
                  balance.isAvailable ? '账户可用' : '余额不足',
                  balance.isAvailable
                      ? 'Account available'
                      : 'Insufficient balance',
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          for (final info in balance.balanceInfos) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _currencyLabel(info.currency),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatBalance(info.currency, info.totalBalance),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              l10n.text(
                '赠金 ${_formatBalance(info.currency, info.grantedBalance)}'
                    ' · 充值 ${_formatBalance(info.currency, info.toppedUpBalance)}',
                'Granted ${_formatBalance(info.currency, info.grantedBalance)}'
                    ' · Topped up '
                    '${_formatBalance(info.currency, info.toppedUpBalance)}',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _currencyLabel(String currency) {
    return switch (currency) {
      'CNY' => '人民币 CNY',
      'USD' => '美元 USD',
      _ => currency,
    };
  }

  String _formatBalance(String currency, String value) {
    return switch (currency) {
      'CNY' => '¥$value',
      'USD' => '\$$value',
      _ => '$value $currency'.trim(),
    };
  }
}

String _formatTokenCount(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

class _AiCurrentModelSummary extends StatelessWidget {
  const _AiCurrentModelSummary({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4D6BFE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                pageLabel(context, '使用中'),
                style: const TextStyle(
                  color: Color(0xFF4D6BFE),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiModelOptionRow extends StatelessWidget {
  const _AiModelOptionRow({
    super.key,
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final _AiModelOption model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: model.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(model.icon, color: model.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            model.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pageLabel(context, model.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: model.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pageLabel(context, model.description),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: selected ? model.color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? model.color : scheme.outlineVariant,
                    width: 1.4,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
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
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: HostTypography.sectionTitle,
          fontWeight: HostTypography.regular,
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
    super.key,
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
                fontWeight: HostTypography.medium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
