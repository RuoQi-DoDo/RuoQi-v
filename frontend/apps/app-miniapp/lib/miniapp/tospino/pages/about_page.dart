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
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 28),
        children: [
          const Center(child: TospinoBrandMark(size: 64)),
          const SizedBox(height: 13),
          const Center(
            child: Text(
              'Tospino',
              style: TextStyle(
                color: TospinoColors.brandDeep,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              '${localizeMiniProgramLabel(context, '版本')} 1.0.0',
              style: TospinoText.meta(context),
            ),
          ),
          const SizedBox(height: 28),
          TospinoSurface(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop smarter with Tospino',
                    style: TospinoText.section(context),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tospino brings trusted products, local delivery and everyday '
                    'value to customers across Ghana.',
                    style: TospinoText.body(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TospinoSurface(
            padding: EdgeInsets.zero,
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
              style: TospinoText.meta(context),
            ),
          ),
        ],
      ),
    );
  }
}
