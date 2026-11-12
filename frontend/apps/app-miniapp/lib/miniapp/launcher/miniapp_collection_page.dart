import '../common/miniapp_localizations.dart';

import 'package:flutter/material.dart';

import 'launcher_widgets.dart';
import 'miniapp_launcher_item.dart';

/// “最近使用 / 我的小程序”集合页。
class MiniProgramCollectionPage extends StatelessWidget {
  const MiniProgramCollectionPage({
    super.key,
    required this.title,
    required this.items,
    required this.onBack,
    required this.onOpen,
    required this.onSearch,
  });

  final String title;
  final List<MiniProgramLauncherItem> items;
  final VoidCallback onBack;
  final ValueChanged<MiniProgramLauncherItem> onOpen;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const Key('mini-program-collection-back'),
                  tooltip: localizeMiniProgramLabel(context, '返回'),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Text(
                localizeMiniProgramLabel(context, title),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MiniProgramLauncherSearchBar(onTap: onSearch),
        ),
        const SizedBox(height: 34),
        Expanded(
          child: ListView(
            key: const Key('mini-program-collection-list'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              MiniProgramLauncherGrid(
                items: items,
                onOpen: onOpen,
                mainAxisExtent: 94,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
