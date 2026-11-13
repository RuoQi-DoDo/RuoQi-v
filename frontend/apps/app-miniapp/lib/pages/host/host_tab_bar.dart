import 'dart:math' as math;
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import '../common/page_localizations.dart';
import '../common/page_theme.dart';

enum HostTab { home, contacts, discover, me }

class HostTabBar extends StatelessWidget {
  const HostTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.homeLabel,
    required this.homeIcon,
    required this.homeActiveIcon,
  });

  final String homeLabel;
  final IconData homeIcon;
  final IconData homeActiveIcon;
  final HostTab selected;
  final ValueChanged<HostTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    final backgroundColor = HostChromeStyle.bottomBarBackground(context);
    final dividerColor = HostChromeStyle.dividerColor(context);
    final hairline = HostChromeStyle.hairline(context);
    final items = [
      (HostTab.home, homeIcon, homeActiveIcon, homeLabel, false),
      (
        HostTab.contacts,
        Icons.contacts_outlined,
        Icons.contacts_rounded,
        '通讯录',
        false,
      ),
      (
        HostTab.discover,
        Icons.explore_outlined,
        Icons.explore_rounded,
        '发现',
        true,
      ),
      (
        HostTab.me,
        Icons.person_outline_rounded,
        Icons.person_rounded,
        '我',
        false,
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: dividerColor, width: hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: math.max(
            54,
            34 + MediaQuery.textScalerOf(context).scale(10) * 1.6,
          ),
          child: Row(
            children: [
              for (final (tab, icon, activeIcon, label, showDot) in items)
                Expanded(
                  child: InkWell(
                    key: Key('host-tab-${tab.name}'),
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
                          pageLabel(context, label),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
