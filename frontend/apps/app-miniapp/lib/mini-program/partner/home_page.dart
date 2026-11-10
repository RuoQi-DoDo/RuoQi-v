import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// 伙伴小程序首页：伙伴移动端。
class PartnerHomePage extends StatelessWidget {
  const PartnerHomePage({super.key, this.embedded = false});

  /// 嵌入通用小程序壳时去掉自带 AppBar。
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('伙伴移动端', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const AppBadge(appName: 'partner_app', version: '1.0.0'),
        ],
      ),
    );

    if (embedded) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('RuoQi 伙伴 App')),
      body: body,
    );
  }
}
