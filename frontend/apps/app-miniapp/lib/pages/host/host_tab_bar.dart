import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/page_localizations.dart';
import '../common/page_theme.dart';
import '../common/whatsapp_colors.dart';

enum HostTab { home, calls, discover, me }

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
    final inactiveColor = scheme.onSurface;
    final backgroundColor = HostChromeStyle.bottomBarBackground(context);
    final dividerColor = HostChromeStyle.dividerColor(context);
    final hairline = HostChromeStyle.hairline(context);
    final items = [
      (HostTab.home, homeIcon, homeActiveIcon, homeLabel, false),
      (HostTab.calls, Icons.call_outlined, Icons.call_rounded, '通话', false),
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
                        Container(
                          width: 46,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                selected == tab ? activeIcon : icon,
                                size: 24,
                                color: selected == tab
                                    ? WhatsAppColors.brandStrong
                                    : inactiveColor,
                              ),
                              if (showDot)
                                const Positioned(
                                  right: 5,
                                  top: 2,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF05656),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(width: 7, height: 7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pageLabel(context, label),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected == tab
                                ? WhatsAppColors.brandStrong
                                : inactiveColor,
                            fontSize: 10,
                            fontWeight: selected == tab
                                ? FontWeight.w600
                                : FontWeight.w400,
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
