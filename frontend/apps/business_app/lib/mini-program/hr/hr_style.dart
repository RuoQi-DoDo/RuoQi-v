import 'package:flutter/material.dart';

import 'hr_models.dart';

class HrColors {
  const HrColors._();

  static const primary = Color(0xFF12AE85);
  static const primaryDark = Color(0xFF078666);
  static const mint = Color(0xFFE8F8F3);
  static const mintStrong = Color(0xFFCCEFE4);
  static const orange = Color(0xFFFF822B);
  static const red = Color(0xFFFF4D4F);
  static const background = Color(0xFFF5F6F7);
  static const surface = Colors.white;
  static const text = Color(0xFF1F2329);
  static const textSecondary = Color(0xFF646A73);
  static const textMuted = Color(0xFF8F959E);
  static const divider = Color(0xFFEDEFF2);
  static const blue = Color(0xFF3B82F6);
}

class HrTheme {
  const HrTheme._();

  static ThemeData data() {
    final scheme = ColorScheme.fromSeed(
      seedColor: HrColors.primary,
      brightness: Brightness.light,
      primary: HrColors.primary,
      surface: HrColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HrColors.background,
      fontFamilyFallback: const [
        'PingFang SC',
        'Microsoft YaHei',
        'Noto Sans CJK SC',
      ],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: HrColors.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: HrColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          color: HrColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(color: HrColors.text, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(
          color: HrColors.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: HrColors.textMuted,
          fontSize: 12,
          height: 1.45,
        ),
        labelLarge: TextStyle(
          color: HrColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: HrColors.divider,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HrColors.text,
        contentTextStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HrColors.background,
        hintStyle: const TextStyle(color: HrColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: HrColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class HrCard extends StatelessWidget {
  const HrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color = HrColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Padding(
      padding: margin,
      child: Material(
        color: color,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class HrSectionHeader extends StatelessWidget {
  const HrSectionHeader({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: HrColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: HrColors.textMuted,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action!, style: const TextStyle(fontSize: 12)),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class HrTag extends StatelessWidget {
  const HrTag(
    this.label, {
    super.key,
    this.foreground = HrColors.textSecondary,
    this.background = HrColors.background,
    this.borderColor,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class HrPrimaryButton extends StatelessWidget {
  const HrPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor = HrColors.primary,
    this.foregroundColor = Colors.white,
    this.height = 46,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: HrColors.divider,
          disabledForegroundColor: HrColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class HrOutlineButton extends StatelessWidget {
  const HrOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.foreground = HrColors.text,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: HrColors.divider),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class HrAvatar extends StatelessWidget {
  const HrAvatar({
    super.key,
    required this.label,
    this.size = 48,
    this.color = HrColors.primary,
  });

  final String label;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.8), color],
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        label.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class HrJobCard extends StatelessWidget {
  const HrJobCard({
    super.key,
    required this.job,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.showBorder = true,
  });

  final HrJob job;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: HrColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: showBorder ? Border.all(color: HrColors.divider) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (job.partTime)
                          const HrTag(
                            '兼职',
                            foreground: HrColors.orange,
                            background: Color(0xFFFFF4EB),
                            borderColor: Color(0xFFFFD8B8),
                          ),
                        Text(
                          job.title,
                          style: const TextStyle(
                            color: HrColors.text,
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    job.salary,
                    style: const TextStyle(
                      color: HrColors.primary,
                      fontSize: 15,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HrColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const _Dot(),
                  Text(
                    job.staffSize,
                    style: const TextStyle(
                      color: HrColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const _Dot(),
                  Text(
                    job.industry,
                    style: const TextStyle(
                      color: HrColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  HrTag(job.experience),
                  HrTag(job.education),
                  for (final tag in job.tags.take(2)) HrTag(tag),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const HrAvatar(label: '李', size: 24),
                  const SizedBox(width: 7),
                  Text(
                    job.publisher,
                    style: const TextStyle(
                      color: HrColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: HrColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    job.location,
                    style: const TextStyle(
                      color: HrColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HrResumeCard extends StatelessWidget {
  const HrResumeCard({
    super.key,
    required this.resume,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final HrResume resume;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: HrColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HrColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrAvatar(
                    label: resume.name,
                    size: 42,
                    color: resume.gender == '女'
                        ? const Color(0xFFEC6A88)
                        : HrColors.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resume.name,
                          style: const TextStyle(
                            color: HrColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${resume.gender} · ${resume.age}岁 · '
                          '${resume.education} · ${resume.experience}',
                          style: const TextStyle(
                            color: HrColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HrTag(
                    resume.jobStatus,
                    foreground: HrColors.primary,
                    background: HrColors.mint,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 7,
                children: [
                  _IconLine(icon: Icons.work_outline, label: resume.intent),
                  _IconLine(
                    icon: Icons.payments_outlined,
                    label: resume.salary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                resume.skill,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HrColors.textSecondary,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HrCompanyCard extends StatelessWidget {
  const HrCompanyCard({
    super.key,
    required this.company,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final HrCompany company;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      margin: margin,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HrColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              company.name.characters.first,
              style: const TextStyle(
                color: HrColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HrColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${company.industry} · ${company.staffSize}',
                  style: const TextStyle(
                    color: HrColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    for (final welfare in company.welfare.take(3))
                      HrTag(
                        welfare,
                        foreground: HrColors.primary,
                        background: HrColors.mint,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: HrColors.textMuted),
        ],
      ),
    );
  }
}

class HrListRow extends StatelessWidget {
  const HrListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = HrColors.primary,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: HrColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: HrColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      size: 19,
                      color: HrColors.textMuted,
                    ),
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1, indent: 57, endIndent: 14),
        ],
      ),
    );
  }
}

class HrFormRow extends StatelessWidget {
  const HrFormRow({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
  });

  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 82,
            child: Text.rich(
              TextSpan(
                children: [
                  if (required)
                    const TextSpan(
                      text: '* ',
                      style: TextStyle(color: HrColors.red),
                    ),
                  TextSpan(text: label),
                ],
              ),
              style: const TextStyle(
                color: HrColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class HrFormTextField extends StatelessWidget {
  const HrFormTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        fillColor: HrColors.background,
      ),
      style: const TextStyle(color: HrColors.text, fontSize: 14),
    );
  }
}

class HrEmptyState extends StatelessWidget {
  const HrEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = '暂无数据',
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: HrColors.mint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: HrColors.primary),
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10,
      color: HrColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 7),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: HrColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

void hrToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1600),
      ),
    );
}
