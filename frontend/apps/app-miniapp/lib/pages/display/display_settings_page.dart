import 'package:flutter/material.dart';

import '../../appearance.dart';
import '../../localization.dart';
import '../common/page_theme.dart';

String _fontSizeLabel(AppLocalizations l10n, double scale) {
  if ((scale - defaultFontScale).abs() < 0.001) {
    return l10n.text('标准', 'Standard');
  }
  return '${(scale * 100).round()}%';
}

/// 宿主和所有业务系统共用的显示设置。
class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const DisplaySettingsPage());

  @override
  Widget build(BuildContext context) {
    final settings = BusinessThemeScope.of(context);
    final l10n = AppLocalizations.of(context);
    final themeLabel = switch (settings.mode) {
      ThemeMode.system => l10n.text('跟随系统', 'Follow system'),
      ThemeMode.light => l10n.text('普通模式', 'Normal mode'),
      ThemeMode.dark => l10n.text('深色模式', 'Dark mode'),
    };
    final languageLabel = switch (settings.locale?.languageCode) {
      'zh' => '简体中文',
      'en' => 'English',
      _ => l10n.text('跟随系统', 'Follow system'),
    };
    return Scaffold(
      key: const Key('display-settings-page'),
      backgroundColor: HostChromeStyle.appBarBackground(context),
      appBar: AppBar(
        toolbarHeight: 42,
        centerTitle: true,
        backgroundColor: HostChromeStyle.appBarBackground(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          key: const Key('display-back'),
          tooltip: l10n.text('返回', 'Back'),
          constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
        ),
        title: Text(l10n.text('界面与显示', 'Appearance & display')),
        shape: const Border(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          _DisplayGroup(
            children: [
              _DisplayValueRow(
                key: const Key('display-theme-row'),
                title: l10n.text('深色模式', 'Dark mode'),
                value: themeLabel,
                onTap: () => _openThemePage(context, settings, l10n),
              ),
              _DisplaySwitchRow(
                title: l10n.text('支持横屏模式', 'Landscape mode'),
                value: settings.orientation != AppOrientation.portrait,
                onChanged: (enabled) => settings.setOrientation(
                  enabled ? AppOrientation.system : AppOrientation.portrait,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DisplayGroup(
            children: [
              _DisplayValueRow(
                key: const Key('display-font-size-row'),
                title: l10n.text('字体大小', 'Font size'),
                value: _fontSizeLabel(l10n, settings.fontScale),
                onTap: () => _openFontSizePage(context, settings, l10n),
              ),
              _DisplayValueRow(
                key: const Key('display-language-row'),
                title: l10n.text('多语言', 'Language'),
                value: languageLabel,
                onTap: () => _openLanguagePage(context, settings, l10n),
              ),
              _DisplayValueRow(
                title: l10n.text('翻译', 'Translation'),
                onTap: () => _showMessage(
                  context,
                  l10n.text(
                    '翻译设置为演示入口',
                    'Translation settings are a demo entry',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openThemePage(
    BuildContext context,
    BusinessThemeController settings,
    AppLocalizations l10n,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          final scheme = Theme.of(pageContext).colorScheme;
          return _DisplaySubpage(
            title: l10n.text('深色模式', 'Dark mode'),
            body: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _DisplayGroup(
                  children: [
                    for (final choice in [
                      (
                        ThemeMode.light,
                        l10n.text('普通模式', 'Normal mode'),
                        Icons.light_mode_outlined,
                      ),
                      (
                        ThemeMode.dark,
                        l10n.text('深色模式', 'Dark mode'),
                        Icons.dark_mode_outlined,
                      ),
                      (
                        ThemeMode.system,
                        l10n.text('跟随系统', 'Follow system'),
                        Icons.brightness_auto_outlined,
                      ),
                    ])
                      ListTile(
                        key: Key('display-theme-${choice.$1.name}'),
                        leading: Icon(choice.$3),
                        title: Text(choice.$2),
                        trailing: settings.mode == choice.$1
                            ? Icon(Icons.check_rounded, color: scheme.primary)
                            : null,
                        onTap: () {
                          settings.setMode(choice.$1);
                          Navigator.of(pageContext).pop();
                        },
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

  Future<void> _openFontSizePage(
    BuildContext context,
    BusinessThemeController settings,
    AppLocalizations l10n,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          return _DisplaySubpage(
            key: const Key('display-font-size-page'),
            title: l10n.text('字体大小', 'Font size'),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      pageContext,
                    ).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                  child: Column(
                    children: [
                      Slider(
                        key: const Key('display-font-size'),
                        min: minFontScale,
                        max: maxFontScale,
                        divisions: 9,
                        label: _fontSizeLabel(l10n, settings.fontScale),
                        value: settings.fontScale,
                        onChanged: settings.setFontScale,
                      ),
                      Row(
                        children: [
                          Text(
                            _fontSizeLabel(l10n, settings.fontScale),
                            key: const Key('display-font-size-label'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                settings.setFontScale(defaultFontScale),
                            child: Text(l10n.text('恢复默认', 'Reset')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.text(
                        '字体预览：让阅读更舒适',
                        'Preview: make reading comfortable',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLanguagePage(
    BuildContext context,
    BusinessThemeController settings,
    AppLocalizations l10n,
  ) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (pageContext) {
          final scheme = Theme.of(pageContext).colorScheme;
          return _DisplaySubpage(
            title: l10n.text('多语言', 'Language'),
            body: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _DisplayGroup(
                  children: [
                    for (final choice in <(Locale?, String)>[
                      (null, l10n.text('跟随系统', 'Follow system')),
                      (const Locale('zh'), '简体中文'),
                      (const Locale('en'), 'English'),
                    ])
                      ListTile(
                        key: Key(
                          'display-language-${choice.$1?.languageCode ?? 'system'}',
                        ),
                        title: Text(choice.$2),
                        trailing: settings.locale == choice.$1
                            ? Icon(Icons.check_rounded, color: scheme.primary)
                            : null,
                        onTap: () {
                          settings.setLocale(choice.$1);
                          Navigator.of(pageContext).pop();
                        },
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DisplayGroup extends StatelessWidget {
  const _DisplayGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hairline = HostChromeStyle.hairline(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Divider(
                  height: hairline,
                  thickness: hairline,
                  color: HostChromeStyle.dividerColor(context),
                ),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _DisplayValueRow extends StatelessWidget {
  const _DisplayValueRow({
    super.key,
    required this.title,
    required this.onTap,
    this.value,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: HostTypography.regular,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            const SizedBox(width: 7),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _DisplaySwitchRow extends StatelessWidget {
  const _DisplaySwitchRow({
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
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: HostTypography.regular,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF07C160),
            onChanged: onChanged,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _DisplaySubpage extends StatelessWidget {
  const _DisplaySubpage({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HostChromeStyle.appBarBackground(context),
      appBar: AppBar(
        toolbarHeight: 42,
        centerTitle: true,
        backgroundColor: HostChromeStyle.appBarBackground(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          key: const Key('display-subpage-back'),
          constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
        ),
        title: Text(title),
        shape: const Border(),
      ),
      body: body,
    );
  }
}
