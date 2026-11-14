import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../appearance.dart';
import '../common/app_language_page.dart';
import 'im_localizations.dart';
import 'im_style.dart';

/// Internationalized IM welcome screen, aligned with the WhatsApp onboarding
/// hierarchy while preserving RuoQi's own actions and copy.
class ImWelcomePage extends StatelessWidget {
  const ImWelcomePage({
    super.key,
    required this.scrollController,
    required this.onContinue,
  });

  final ScrollController? scrollController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final settings = BusinessThemeScope.of(context);
    final resolvedLocale = settings.locale ?? Localizations.localeOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: ImColors.background,
        body: CustomScrollView(
          key: const Key('customer-home-scroll'),
          controller: scrollController,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<_WelcomeMenuAction>(
                        key: const Key('im-welcome-menu'),
                        tooltip: imText(context, '更多', 'More'),
                        color: ImColors.surfaceRaised,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: ImColors.primaryText,
                        ),
                        onSelected: (action) {
                          switch (action) {
                            case _WelcomeMenuAction.language:
                              _openLanguage(context);
                            case _WelcomeMenuAction.help:
                              _showHelp(context);
                          }
                        },
                        itemBuilder: (menuContext) => [
                          PopupMenuItem(
                            value: _WelcomeMenuAction.language,
                            child: Text(
                              imText(menuContext, '应用语言', 'App language'),
                            ),
                          ),
                          PopupMenuItem(
                            value: _WelcomeMenuAction.help,
                            child: Text(imText(menuContext, '帮助', 'Help')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 4, right: 38),
              sliver: SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _HeaderIconButton(
                    tooltip: imText(context, '无障碍功能', 'Accessibility'),
                    icon: Icons.accessibility_new_rounded,
                    onPressed: () => _showAccessibility(context),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Semantics(
                        label: imText(
                          context,
                          '安全、开放的即时沟通',
                          'Private, connected messaging',
                        ),
                        child: const _WelcomeIllustration(),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      imText(context, '欢迎使用 RuoQi', 'Welcome to RuoQi'),
                      style: const TextStyle(
                        color: ImColors.primaryText,
                        fontSize: 31,
                        height: 1.13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _LegalCopy(
                      onOpenPolicy: () => _showPolicy(context),
                      onOpenTerms: () => _showTerms(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 86),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      key: const Key('im-welcome-language'),
                      onPressed: () => _openLanguage(context),
                      style: TextButton.styleFrom(
                        foregroundColor: ImColors.primaryText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: ImColors.primaryText,
                            size: 23,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            imLanguageName(resolvedLocale),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: ImColors.primaryText,
                            size: 23,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        key: const Key('im-welcome-continue'),
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: ImColors.brand,
                          foregroundColor: ImColors.brandDark,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(
                          imText(context, '同意并继续', 'Agree and continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLanguage(BuildContext context) {
    return AppLanguagePage.show(context);
  }

  Future<void> _showHelp(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(imText(dialogContext, '需要帮助？', 'Need help?')),
        content: Text(
          imText(
            dialogContext,
            '你可以随时在右上角菜单中更改应用语言。',
            'You can change the app language anytime from the menu.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(imText(dialogContext, '知道了', 'Got it')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAccessibility(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(imText(dialogContext, '无障碍功能', 'Accessibility')),
        content: Text(
          imText(
            dialogContext,
            'RuoQi 会跟随设备的字体大小与辅助功能设置。',
            'RuoQi follows your device font size and accessibility settings.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(imText(dialogContext, '关闭', 'Close')),
          ),
        ],
      ),
    );
  }

  Future<void> _showPolicy(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(imText(dialogContext, '隐私政策', 'Privacy Policy')),
        content: Text(
          imText(
            dialogContext,
            '这是 RuoQi 的隐私政策演示入口。',
            'This is the demo entry for the RuoQi Privacy Policy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(imText(dialogContext, '关闭', 'Close')),
          ),
        ],
      ),
    );
  }

  Future<void> _showTerms(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(imText(dialogContext, '服务条款', 'Terms of Service')),
        content: Text(
          imText(
            dialogContext,
            '这是 RuoQi 的服务条款演示入口。',
            'This is the demo entry for the RuoQi Terms of Service.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(imText(dialogContext, '关闭', 'Close')),
          ),
        ],
      ),
    );
  }
}

enum _WelcomeMenuAction { language, help }

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        side: const BorderSide(color: ImColors.divider),
        backgroundColor: ImColors.surface,
      ),
      icon: Icon(icon, color: ImColors.brand, size: 24),
    );
  }
}

class _LegalCopy extends StatelessWidget {
  const _LegalCopy({required this.onOpenPolicy, required this.onOpenTerms});

  final VoidCallback onOpenPolicy;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      color: ImColors.secondaryText,
      fontSize: 15,
      height: 1.45,
    );
    final linkStyle = baseStyle.copyWith(
      color: ImColors.brand,
      fontWeight: FontWeight.w500,
    );
    return Text.rich(
      key: const Key('im-welcome-legal-copy'),
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: imText(context, '请阅读我们的', 'Read our ')),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onOpenPolicy,
              child: Text(
                imText(context, '隐私政策', 'Privacy Policy'),
                style: linkStyle,
              ),
            ),
          ),
          TextSpan(
            text: imText(
              context,
              '。轻触“同意并继续”以接受我们的',
              '. Tap “Agree and continue” to accept our ',
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onOpenTerms,
              child: Text(
                imText(context, '服务条款。', 'Terms of Service.'),
                style: linkStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 252,
      height: 208,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 18,
            left: 8,
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                width: 176,
                height: 104,
                decoration: BoxDecoration(
                  color: ImColors.blush,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 2,
            right: -4,
            child: Icon(Icons.public_rounded, color: ImColors.lime, size: 82),
          ),
          Positioned(
            top: 49,
            left: 48,
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 186,
                height: 112,
                decoration: BoxDecoration(
                  color: ImColors.mint,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(56, 30, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IllustrationLine(width: 106),
                      SizedBox(height: 18),
                      _IllustrationLine(width: 87),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 5,
            left: 23,
            child: Icon(
              Icons.phone_in_talk_rounded,
              color: ImColors.brand,
              size: 62,
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 16,
            child: Icon(
              Icons.favorite_rounded,
              color: ImColors.brand,
              size: 48,
            ),
          ),
          Positioned(
            right: 78,
            bottom: 0,
            child: Container(
              width: 54,
              height: 58,
              decoration: BoxDecoration(
                color: ImColors.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: ImColors.brandDark,
                  size: 27,
                ),
              ),
            ),
          ),
          Positioned(
            right: 66,
            bottom: 45,
            child: Container(
              width: 9,
              height: 25,
              decoration: BoxDecoration(
                color: ImColors.brand,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationLine extends StatelessWidget {
  const _IllustrationLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: ImColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
