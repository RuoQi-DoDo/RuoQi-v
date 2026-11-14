import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoSettingsPage extends StatelessWidget {
  const TospinoSettingsPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final languageLabel = Localizations.localeOf(context).languageCode == 'en'
        ? 'English'
        : '中文';
    return ColoredBox(
      key: const Key('tospino-settings-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (user != null) ...[
            Container(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.brandPale,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      user.displayName.isEmpty
                          ? 'T'
                          : user.displayName.characters.first,
                      style: TextStyle(
                        color: TospinoColors.solidBrand(context),
                        fontSize: 21,
                        fontWeight: TospinoText.emphasis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName.isEmpty ? '--' : user.displayName,
                          style: TospinoText.pageTitle(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID:${user.id}',
                          style: TospinoText.secondary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 0.5,
              color: TospinoColors.resolve(context, TospinoColors.line),
            ),
          ],
          _SettingsGroup(
            children: [
              _SettingsRow(
                label: '收货地址',
                onTap: () => controller.open(TospinoRoute.address),
              ),
              _SettingsRow(
                label: '账户与安全',
                onTap: () => showTospinoToast(context, '账户与安全'),
              ),
              _SettingsRow(
                label: '支付设置',
                onTap: () => showTospinoToast(context, '支付设置'),
              ),
              _SettingsRow(
                label: '语言设置',
                value: languageLabel,
                showDivider: false,
                onTap: () => showTospinoToast(context, '请在主体显示设置中切换语言'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: [
              _SettingsRow(
                label: '清除缓存',
                value: '立即清理',
                showDivider: false,
                onTap: () => showTospinoToast(context, '缓存已清理'),
              ),
            ],
          ),
          if (controller.isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: OutlinedButton(
                key: const Key('tospino-logout'),
                onPressed: () async {
                  await controller.logout();
                  if (context.mounted) controller.back();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: TospinoColors.resolve(
                    context,
                    TospinoColors.price,
                  ),
                  side: BorderSide(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.lineStrong,
                    ),
                  ),
                  backgroundColor: TospinoColors.resolve(
                    context,
                    TospinoColors.surface,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  localizeMiniProgramLabel(context, '退出登录'),
                  style: const TextStyle(fontWeight: TospinoText.emphasis),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.onTap,
    this.value,
    this.showDivider = true,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 53,
        margin: const EdgeInsets.only(left: 20),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, label),
                style: TospinoText.body(context),
              ),
            ),
            if (value != null)
              Text(
                localizeMiniProgramLabel(context, value!),
                style: TospinoText.hint(context),
              ),
            const SizedBox(width: 5),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
          ],
        ),
      ),
    );
  }
}
