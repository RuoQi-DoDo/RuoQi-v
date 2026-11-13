import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoAboutPage extends StatelessWidget {
  const TospinoAboutPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-about-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 34, 18, 28),
        children: [
          const Center(child: TospinoBrandMark(size: 78)),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Tospino',
              style: TextStyle(
                color: TospinoColors.brandDeep,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              '${localizeMiniProgramLabel(context, '版本')} 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 33),
          Material(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop smarter with Tospino',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tospino brings trusted products, local delivery and everyday '
                    'value to customers across Ghana.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: const Text('www.tospino.com.gh'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => showTospinoToast(context, '客服功能即将开放'),
                ),
                Divider(
                  height: 1,
                  indent: 54,
                  color: TospinoColors.resolve(context, TospinoColors.line),
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded),
                  title: const Text('support@tospino.com'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showTospinoToast(context, '客服功能即将开放'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '© 2026 Tospino. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
