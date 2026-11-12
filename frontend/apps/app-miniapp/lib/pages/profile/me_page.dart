import 'package:flutter/material.dart';

import '../common/page_localizations.dart';
import '../common/page_widgets.dart';

import '../settings/settings_page.dart';

class MePage extends StatelessWidget {
  const MePage({
    super.key,
    this.onTap,
    this.onOpenSettings,
    this.embedded = false,
  });

  final ValueChanged<String>? onTap;
  final bool embedded;
  final VoidCallback? onOpenSettings;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MePage());

  @override
  Widget build(BuildContext context) =>
      SharedPageFrame(embedded: embedded, builder: _buildContent);

  Widget _buildContent(BuildContext context) {
    final onTap = this.onTap ?? (message) => showPageMessage(context, message);
    final onOpenSettings =
        this.onOpenSettings ??
        () => Navigator.of(context).push<void>(SettingsPage.route());

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      key: const Key('me-page'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0D6B8), Color(0xFFCEA985)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Jengro Woo',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.qr_code_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pageLabel(context, '账号：wzgxove'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ProfileChip(
                          label: '＋ 状态',
                          onTap: () => onTap('状态为模拟入口'),
                        ),
                        const SizedBox(width: 10),
                        _ProfileChip(
                          icon: Icons.refresh_rounded,
                          onTap: () => onTap('更新状态为模拟入口'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.shield_outlined,
              color: const Color(0xFF07C160),
              title: '服务',
              onTap: () => onTap('服务为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFFE0A52D),
              title: '收藏',
              onTap: () => onTap('收藏为模拟入口'),
            ),
            PageListRow(
              icon: Icons.photo_outlined,
              color: const Color(0xFF2F88FF),
              title: '朋友圈',
              onTap: () => onTap('朋友圈为模拟入口'),
            ),
            PageListRow(
              icon: Icons.collections_outlined,
              color: const Color(0xFF2F88FF),
              title: '作品',
              onTap: () => onTap('作品为模拟入口'),
            ),
            PageListRow(
              icon: Icons.storefront_outlined,
              color: const Color(0xFFF05656),
              title: '小店与卡包',
              trailingText: '[热卖1万+]毛绒治愈垂耳兔公仔',
              showRedDot: true,
              onTap: () => onTap('小店与卡包为模拟入口'),
            ),
            PageListRow(
              icon: Icons.emoji_emotions_outlined,
              color: const Color(0xFFE8B72E),
              title: '表情',
              onTap: () => onTap('表情为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            KeyedSubtree(
              key: const Key('open-settings'),
              child: PageListRow(
                icon: Icons.settings_outlined,
                color: const Color(0xFF2F88FF),
                title: '设置',
                onTap: onOpenSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 18, color: scheme.onSurfaceVariant)
            : Text(
                pageLabel(context, label!),
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
              ),
      ),
    );
  }
}
