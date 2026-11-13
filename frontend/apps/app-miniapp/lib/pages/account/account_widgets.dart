import 'account_localizations.dart';
import '../common/page_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_style.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    this.size = 54,
    this.styleIndex = 0,
    this.showBadge = false,
  });

  final double size;
  final int styleIndex;
  final bool showBadge;

  static const _gradients = <List<Color>>[
    [Color(0xFFFFD7B5), Color(0xFFD99B73)],
    [Color(0xFFB7E8DF), Color(0xFF42A89C)],
    [Color(0xFFC9D8FF), Color(0xFF5F7EDC)],
    [Color(0xFFF1D2FF), Color(0xFF9A62C7)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[styleIndex % _gradients.length];
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              size: size * 0.52,
              color: Colors.white,
            ),
          ),
          if (showBadge)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: size * 0.16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AccountPageHeader extends StatelessWidget {
  const AccountPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeAccountLabel(context, title),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    localizeAccountLabel(context, subtitle!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class AccountSectionTitle extends StatelessWidget {
  const AccountSectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 9),
      child: Row(
        children: [
          Text(
            localizeAccountLabel(context, title),
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                localizeAccountLabel(context, action!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? AccountStyle.cardBackground(context),
          borderRadius: BorderRadius.circular(AccountStyle.cardRadius),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class AccountListRow extends StatelessWidget {
  const AccountListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = destructive ? scheme.error : scheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AccountStyle.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: destructive
                      ? scheme.errorContainer.withValues(alpha: 0.55)
                      : scheme.primaryContainer.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: destructive ? scheme.error : scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeAccountLabel(context, title),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        localizeAccountLabel(context, subtitle!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 10),
                Text(
                  localizeAccountLabel(context, value!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AccountRowDivider extends StatelessWidget {
  const AccountRowDivider({super.key, this.indent = 64});

  final double indent;

  @override
  Widget build(BuildContext context) {
    final hairline = HostChromeStyle.hairline(context);
    return Divider(
      height: hairline,
      thickness: hairline,
      indent: indent,
      endIndent: 14,
      color: HostChromeStyle.dividerColor(context),
    );
  }
}

class AccountStatusTag extends StatelessWidget {
  const AccountStatusTag({
    super.key,
    required this.label,
    this.tone = AccountTagTone.neutral,
  });

  final String label;
  final AccountTagTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (foreground, background) = switch (tone) {
      AccountTagTone.brand => (
        scheme.primary,
        scheme.primaryContainer.withValues(alpha: 0.55),
      ),
      AccountTagTone.warning => (
        const Color(0xFFA15C00),
        const Color(0xFFFFF1DC),
      ),
      AccountTagTone.danger => (
        scheme.error,
        scheme.errorContainer.withValues(alpha: 0.55),
      ),
      AccountTagTone.neutral => (
        scheme.onSurfaceVariant,
        scheme.surfaceContainerHigh,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        localizeAccountLabel(context, label),
        style: TextStyle(
          color: foreground,
          fontSize: 10.5,
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum AccountTagTone { neutral, brand, warning, danger }

class AccountInfoBanner extends StatelessWidget {
  const AccountInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(AccountStyle.controlRadius),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              localizeAccountLabel(context, message),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 11.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountPrimaryButton extends StatelessWidget {
  const AccountPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? null : Icon(icon, size: 19),
        label: Text(localizeAccountLabel(context, label)),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AccountStyle.controlRadius),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class AccountTextField extends StatelessWidget {
  const AccountTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizeAccountLabel(context, label),
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: localizeAccountLabel(context, hint),
            suffixIcon: suffix,
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AccountStyle.controlRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AccountStyle.controlRadius),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AccountStyle.controlRadius),
              borderSide: BorderSide(color: scheme.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
