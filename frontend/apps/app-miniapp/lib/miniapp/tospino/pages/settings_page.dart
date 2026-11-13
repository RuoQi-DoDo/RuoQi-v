import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoSettingsPage extends StatefulWidget {
  const TospinoSettingsPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoSettingsPage> createState() => _TospinoSettingsPageState();
}

class _TospinoSettingsPageState extends State<TospinoSettingsPage> {
  bool _orderUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-settings-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        children: [
          _SettingsCard(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Order updates'),
                subtitle: Text(localizeMiniProgramLabel(context, '订单提交成功')),
                value: _orderUpdates,
                activeThumbColor: TospinoColors.solidBrand(context),
                onChanged: (value) => setState(() => _orderUpdates = value),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Promotions'),
                subtitle: Text(localizeMiniProgramLabel(context, '优惠券')),
                value: _promotions,
                activeThumbColor: TospinoColors.solidBrand(context),
                onChanged: (value) => setState(() => _promotions = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(localizeMiniProgramLabel(context, '隐私政策')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showTospinoToast(context, '隐私政策'),
              ),
              Divider(
                height: 1,
                indent: 52,
                color: TospinoColors.resolve(context, TospinoColors.line),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(localizeMiniProgramLabel(context, '用户协议')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showTospinoToast(context, '用户协议'),
              ),
              Divider(
                height: 1,
                indent: 52,
                color: TospinoColors.resolve(context, TospinoColors.line),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(localizeMiniProgramLabel(context, '关于 Tospino')),
                subtitle: Text(
                  '${localizeMiniProgramLabel(context, '版本')} 1.0.0',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => widget.controller.open(TospinoRoute.about),
              ),
              if (widget.controller.isLoggedIn) ...[
                Divider(
                  height: 1,
                  indent: 52,
                  color: TospinoColors.resolve(context, TospinoColors.line),
                ),
                ListTile(
                  key: const Key('tospino-logout'),
                  leading: const Icon(Icons.logout_rounded),
                  title: Text(localizeMiniProgramLabel(context, '退出登录')),
                  onTap: () async {
                    await widget.controller.logout();
                    if (!context.mounted) return;
                    widget.controller
                      ..back()
                      ..switchTab(3);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
