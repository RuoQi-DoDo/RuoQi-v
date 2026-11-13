import 'package:flutter/material.dart';

import 'page_localizations.dart';
import 'page_theme.dart';

/// 公共页可独立打开，也可将内容嵌入应用宿主。
class SharedPageFrame extends StatelessWidget {
  const SharedPageFrame({
    super.key,
    required this.builder,
    this.title,
    this.embedded = false,
    this.actions,
  });

  final WidgetBuilder builder;
  final String? title;
  final bool embedded;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (embedded) return builder(context);
    return Theme(
      data: sharedPageTheme(context),
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: title == null
                ? null
                : AppBar(
                    toolbarHeight: 50,
                    centerTitle: true,
                    backgroundColor: HostChromeStyle.appBarBackground(context),
                    surfaceTintColor: Colors.transparent,
                    title: Text(pageLabel(context, title!)),
                    actions: actions,
                    shape: Border(
                      bottom: HostChromeStyle.appBarDivider(context),
                    ),
                  ),
            body: SafeArea(top: title == null, child: builder(context)),
          );
        },
      ),
    );
  }
}

void showPageMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class PageListGroup extends StatelessWidget {
  const PageListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hairline = HostChromeStyle.hairline(context);
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
                    height: hairline,
                    thickness: hairline,
                    color: HostChromeStyle.dividerColor(context),
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

class PageListRow extends StatelessWidget {
  const PageListRow({
    super.key,
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
        height: 50,
        child: Row(
          children: [
            const SizedBox(width: 18),
            SizedBox(width: 30, child: Icon(icon, color: color, size: 25)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pageLabel(context, title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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

class SquareBadge extends StatelessWidget {
  const SquareBadge({super.key});

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
