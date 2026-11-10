part of 'customer_home_page.dart';

class _MePage extends StatelessWidget {
  const _MePage({required this.onTap, required this.onOpenSettings});

  final ValueChanged<String> onTap;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
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
                      '微信号：wzgxove',
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
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.shield_outlined,
              color: const Color(0xFF07C160),
              title: '服务',
              onTap: () => onTap('服务为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFFE0A52D),
              title: '收藏',
              onTap: () => onTap('收藏为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.photo_outlined,
              color: const Color(0xFF2F88FF),
              title: '朋友圈',
              onTap: () => onTap('朋友圈为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.collections_outlined,
              color: const Color(0xFF2F88FF),
              title: '作品',
              onTap: () => onTap('作品为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.storefront_outlined,
              color: const Color(0xFFF05656),
              title: '小店与卡包',
              trailingText: '[热卖1万+]毛绒治愈垂耳兔公仔',
              showRedDot: true,
              onTap: () => onTap('小店与卡包为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.emoji_emotions_outlined,
              color: const Color(0xFFE8B72E),
              title: '表情',
              onTap: () => onTap('表情为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            KeyedSubtree(
              key: const Key('open-settings'),
              child: _WeChatListRow(
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
                label!,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
              ),
      ),
    );
  }
}

class _WeChatListGroup extends StatelessWidget {
  const _WeChatListGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 58),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: scheme.outlineVariant,
                  ),
                ),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}

class _WeChatListRow extends StatelessWidget {
  const _WeChatListRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.badge,
    this.trailingText,
    this.compactTrailing,
    this.showRedDot = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final String? trailingText;
  final Widget? compactTrailing;
  final bool showRedDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            const SizedBox(width: 18),
            SizedBox(width: 30, child: Icon(icon, color: color, size: 25)),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF05656),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
            const Spacer(),
            if (trailingText != null)
              Flexible(
                child: Text(
                  trailingText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ?compactTrailing,
            if (showRedDot)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF05656),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 10),
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

class _SquareBadge extends StatelessWidget {
  const _SquareBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              colors: [Color(0xFF5AB7D8), Color(0xFFF2D18B)],
            ),
          ),
        ),
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFF05656),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeChatTabBar extends StatelessWidget {
  const _WeChatTabBar({required this.selected, required this.onSelected});

  final _HostTab selected;
  final ValueChanged<_HostTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    const items = [
      (
        _HostTab.chats,
        Icons.chat_bubble_outline_rounded,
        Icons.chat_bubble_rounded,
        'RuoQi',
        false,
      ),
      (
        _HostTab.contacts,
        Icons.contacts_outlined,
        Icons.contacts_rounded,
        '通讯录',
        false,
      ),
      (
        _HostTab.discover,
        Icons.explore_outlined,
        Icons.explore_rounded,
        '发现',
        true,
      ),
      (
        _HostTab.me,
        Icons.person_outline_rounded,
        Icons.person_rounded,
        '我',
        false,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (final (tab, icon, activeIcon, label, showDot) in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelected(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              selected == tab ? activeIcon : icon,
                              size: 25,
                              color: selected == tab
                                  ? const Color(0xFF07C160)
                                  : muted,
                            ),
                            if (showDot)
                              Positioned(
                                right: -2,
                                top: -1,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF05656),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected == tab
                                ? const Color(0xFF07C160)
                                : muted,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSearchBar extends StatelessWidget {
  const _PickerSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                '搜索小程序',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSectionHeader extends StatelessWidget {
  const _PickerSectionHeader({required this.title, this.trailing, this.onTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailing!, style: const TextStyle(fontSize: 11)),
                const Icon(Icons.chevron_right_rounded, size: 13),
              ],
            ),
          ),
      ],
    );
  }
}
