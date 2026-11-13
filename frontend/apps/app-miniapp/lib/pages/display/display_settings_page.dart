import 'package:flutter/material.dart';

import '../../appearance.dart';
import '../../localization.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final fontSizeLabel = _fontSizeLabel(l10n, settings.fontScale);
    return Scaffold(
      key: const Key('display-settings-page'),
      appBar: AppBar(title: Text(l10n.text('界面与显示', 'Appearance & display'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.text('深色模式', 'Dark mode'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final choice in [
            (
              ThemeMode.system,
              l10n.text('跟随系统', 'Follow system'),
              Icons.brightness_auto_outlined,
            ),
            (
              ThemeMode.light,
              l10n.text('浅色', 'Light'),
              Icons.light_mode_outlined,
            ),
            (ThemeMode.dark, l10n.text('深色', 'Dark'), Icons.dark_mode_outlined),
          ])
            ListTile(
              key: Key('display-theme-${choice.$1.name}'),
              leading: Icon(choice.$3),
              title: Text(choice.$2),
              trailing: settings.mode == choice.$1
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              onTap: () => settings.setMode(choice.$1),
            ),
          const Divider(height: 32),
          Text(
            l10n.text('字体大小', 'Font size'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            key: const Key('display-font-size'),
            min: minFontScale,
            max: maxFontScale,
            divisions: 10,
            label: fontSizeLabel,
            value: settings.fontScale,
            onChanged: settings.setFontScale,
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            children: [
              Text(fontSizeLabel, key: const Key('display-font-size-label')),
              TextButton(
                onPressed: () => settings.setFontScale(defaultFontScale),
                child: Text(l10n.text('恢复默认', 'Reset')),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.text('字体预览：让阅读更舒适', 'Preview: make reading comfortable'),
              ),
            ),
          ),
          const Divider(height: 32),
          Text(
            l10n.text('多语言', 'Language'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              onTap: () => settings.setLocale(choice.$1),
            ),
          const Divider(height: 32),
          Text(
            l10n.text('横屏模式', 'Screen orientation'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final choice in [
            (AppOrientation.system, l10n.text('跟随系统旋转', 'Auto rotate')),
            (AppOrientation.portrait, l10n.text('竖屏', 'Portrait')),
            (AppOrientation.landscape, l10n.text('横屏', 'Landscape')),
          ])
            ListTile(
              key: Key('display-orientation-${choice.$1.name}'),
              title: Text(choice.$2),
              trailing: settings.orientation == choice.$1
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              onTap: () async {
                try {
                  await settings.setOrientation(choice.$1);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.text(
                          '暂时无法切换屏幕方向，请重试',
                          'Unable to change orientation. Please retry.',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 16),
          Text(
            l10n.text(
              '显示设置同时应用于宿主和小程序。',
              'Display settings apply to the host and mini programs.',
            ),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
