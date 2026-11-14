import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../appearance.dart';
import '../../localization.dart';

String _languageText(BuildContext context, String chinese, String english) {
  return AppLocalizations.of(context).text(chinese, english);
}

abstract final class _LanguageColors {
  static const background = Color(0xFF0B1110);
  static const surfaceRaised = Color(0xFF192421);
  static const divider = Color(0xFF26322F);
  static const primaryText = Color(0xFFF4F7F5);
  static const secondaryText = Color(0xFF9AA6A2);
  static const brand = Color(0xFF25D366);
}

/// Full language catalog. Only Simplified Chinese and English are wired to the
/// application locale; every other row remains visible for product parity.
class AppLanguagePage extends StatelessWidget {
  const AppLanguagePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const AppLanguagePage(),
    );
  }

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(route());
  }

  @override
  Widget build(BuildContext context) {
    final settings = BusinessThemeScope.of(context);
    final deviceLocale = View.of(context).platformDispatcher.locale;
    final deviceLanguage = _languageForLocale(deviceLocale);
    final supported = _languages.where((language) => language.supported);
    final unsupported = _languages.where((language) => !language.supported);
    return Scaffold(
      key: const Key('app-language-page'),
      backgroundColor: _LanguageColors.background,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: _LanguageColors.background,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        leadingWidth: 58,
        leading: IconButton(
          key: const Key('app-language-close'),
          tooltip: _languageText(context, '关闭', 'Close'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.close_rounded,
            color: _LanguageColors.primaryText,
          ),
        ),
        titleSpacing: 2,
        title: Text(
          _languageText(context, '应用语言', 'App language'),
          style: const TextStyle(
            color: _LanguageColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _LanguageColors.divider),
        ),
      ),
      body: ListView(
        key: const Key('app-language-list'),
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          _LanguageSectionHeader(
            title: _languageText(context, '可用语言', 'Available languages'),
          ),
          _LanguageOption(
            key: const Key('app-language-device'),
            title: deviceLanguage?.nativeName ?? deviceLocale.toLanguageTag(),
            subtitle: deviceLanguage?.supported == true
                ? _languageText(context, '（设备语言）', '(Device language)')
                : _languageText(
                    context,
                    '（设备语言，不支持时使用简体中文）',
                    '(Device language; falls back to Simplified Chinese)',
                  ),
            selected: settings.locale == null,
            enabled: true,
            onTap: () => _selectDevice(context, settings),
          ),
          for (final language in supported)
            _LanguageOption(
              key: Key('app-language-${language.key}'),
              title: language.nativeName,
              subtitle: language.localizedName(context),
              selected:
                  settings.locale?.languageCode == language.locale.languageCode,
              enabled: true,
              onTap: () => _select(context, settings, language.locale),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 14, 22, 10),
            child: Divider(height: 1, color: _LanguageColors.divider),
          ),
          _LanguageSectionHeader(
            title: _languageText(context, '其他语言', 'More languages'),
            description: _languageText(
              context,
              '以下语言暂未开放，当前仅简体中文和 English 可用于界面切换。',
              'These languages are not available yet. Only Simplified Chinese and English can change the interface.',
            ),
          ),
          for (final language in unsupported)
            _LanguageOption(
              key: Key('app-language-${language.key}'),
              title: language.nativeName,
              subtitle: language.localizedName(context),
              selected: false,
              enabled: false,
              onTap: () => _showUnsupported(context, language),
            ),
        ],
      ),
    );
  }

  void _select(
    BuildContext context,
    BusinessThemeController settings,
    Locale locale,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    settings.setLocale(locale);
    Navigator.of(context).pop();
  }

  void _selectDevice(BuildContext context, BusinessThemeController settings) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    settings.setLocale(null);
    Navigator.of(context).pop();
  }

  void _showUnsupported(BuildContext context, _ImLanguage language) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _LanguageColors.surfaceRaised,
          content: Text(
            _languageText(
              context,
              '${language.nameZh}暂未开放，当前仅支持简体中文和 English。',
              '${language.nameEn} is not available yet. Only Simplified Chinese and English are supported.',
            ),
            style: const TextStyle(color: _LanguageColors.primaryText),
          ),
        ),
      );
  }
}

class _LanguageSectionHeader extends StatelessWidget {
  const _LanguageSectionHeader({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _LanguageColors.brand,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 7),
            Text(
              description!,
              style: const TextStyle(
                color: _LanguageColors.secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      child: InkWell(
        onTap: onTap,
        splashColor: _LanguageColors.brand.withValues(
          alpha: enabled ? 0.12 : 0.04,
        ),
        highlightColor: _LanguageColors.brand.withValues(
          alpha: enabled ? 0.08 : 0.03,
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.46,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? _LanguageColors.brand
                            : _LanguageColors.secondaryText,
                        width: selected ? 2 : 1.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: _LanguageColors.brand,
                            size: 18,
                          )
                        : enabled
                        ? null
                        : const Icon(
                            Icons.remove_rounded,
                            color: _LanguageColors.secondaryText,
                            size: 14,
                          ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _LanguageColors.primaryText,
                          fontSize: 17,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _LanguageColors.secondaryText,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!enabled)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: _LanguageColors.secondaryText,
                      size: 17,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImLanguage {
  const _ImLanguage({
    required this.key,
    required this.locale,
    required this.nativeName,
    required this.nameZh,
    required this.nameEn,
    this.supported = false,
  });

  final String key;
  final Locale locale;
  final String nativeName;
  final String nameZh;
  final String nameEn;
  final bool supported;

  String localizedName(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'en'
        ? nameEn
        : nameZh;
  }
}

_ImLanguage? _languageForLocale(Locale locale) {
  for (final language in _languages) {
    if (language.locale.languageCode == locale.languageCode &&
        (language.locale.countryCode == null ||
            language.locale.countryCode == locale.countryCode)) {
      return language;
    }
  }
  for (final language in _languages) {
    if (language.locale.languageCode == locale.languageCode) {
      return language;
    }
  }
  return null;
}

const _languages = <_ImLanguage>[
  _ImLanguage(
    key: 'zh',
    locale: Locale('zh'),
    nativeName: '简体中文',
    nameZh: '简体中文',
    nameEn: 'Simplified Chinese',
    supported: true,
  ),
  _ImLanguage(
    key: 'en',
    locale: Locale('en'),
    nativeName: 'English',
    nameZh: '英语',
    nameEn: 'English',
    supported: true,
  ),
  _ImLanguage(
    key: 'af',
    locale: Locale('af'),
    nativeName: 'Afrikaans',
    nameZh: '南非荷兰语',
    nameEn: 'Afrikaans',
  ),
  _ImLanguage(
    key: 'sq',
    locale: Locale('sq'),
    nativeName: 'Shqip',
    nameZh: '阿尔巴尼亚语',
    nameEn: 'Albanian',
  ),
  _ImLanguage(
    key: 'am',
    locale: Locale('am'),
    nativeName: 'አማርኛ',
    nameZh: '阿姆哈拉语',
    nameEn: 'Amharic',
  ),
  _ImLanguage(
    key: 'ar',
    locale: Locale('ar'),
    nativeName: 'العربية',
    nameZh: '阿拉伯语',
    nameEn: 'Arabic',
  ),
  _ImLanguage(
    key: 'az',
    locale: Locale('az'),
    nativeName: 'Azərbaycan dili',
    nameZh: '阿塞拜疆语',
    nameEn: 'Azerbaijani',
  ),
  _ImLanguage(
    key: 'bn',
    locale: Locale('bn'),
    nativeName: 'বাংলা',
    nameZh: '孟加拉语',
    nameEn: 'Bengali',
  ),
  _ImLanguage(
    key: 'bg',
    locale: Locale('bg'),
    nativeName: 'Български',
    nameZh: '保加利亚语',
    nameEn: 'Bulgarian',
  ),
  _ImLanguage(
    key: 'ca',
    locale: Locale('ca'),
    nativeName: 'Català',
    nameZh: '加泰罗尼亚语',
    nameEn: 'Catalan',
  ),
  _ImLanguage(
    key: 'zh-Hant',
    locale: Locale('zh', 'Hant'),
    nativeName: '繁體中文（台灣）',
    nameZh: '繁体中文（台湾）',
    nameEn: 'Traditional Chinese (Taiwan)',
  ),
  _ImLanguage(
    key: 'hr',
    locale: Locale('hr'),
    nativeName: 'Hrvatski',
    nameZh: '克罗地亚语',
    nameEn: 'Croatian',
  ),
  _ImLanguage(
    key: 'cs',
    locale: Locale('cs'),
    nativeName: 'Čeština',
    nameZh: '捷克语',
    nameEn: 'Czech',
  ),
  _ImLanguage(
    key: 'da',
    locale: Locale('da'),
    nativeName: 'Dansk',
    nameZh: '丹麦语',
    nameEn: 'Danish',
  ),
  _ImLanguage(
    key: 'nl',
    locale: Locale('nl'),
    nativeName: 'Nederlands',
    nameZh: '荷兰语',
    nameEn: 'Dutch',
  ),
  _ImLanguage(
    key: 'et',
    locale: Locale('et'),
    nativeName: 'Eesti',
    nameZh: '爱沙尼亚语',
    nameEn: 'Estonian',
  ),
  _ImLanguage(
    key: 'fil',
    locale: Locale('fil'),
    nativeName: 'Filipino',
    nameZh: '菲律宾语',
    nameEn: 'Filipino',
  ),
  _ImLanguage(
    key: 'fi',
    locale: Locale('fi'),
    nativeName: 'Suomi',
    nameZh: '芬兰语',
    nameEn: 'Finnish',
  ),
  _ImLanguage(
    key: 'fr',
    locale: Locale('fr'),
    nativeName: 'Français',
    nameZh: '法语',
    nameEn: 'French',
  ),
  _ImLanguage(
    key: 'de',
    locale: Locale('de'),
    nativeName: 'Deutsch',
    nameZh: '德语',
    nameEn: 'German',
  ),
  _ImLanguage(
    key: 'el',
    locale: Locale('el'),
    nativeName: 'Ελληνικά',
    nameZh: '希腊语',
    nameEn: 'Greek',
  ),
  _ImLanguage(
    key: 'gu',
    locale: Locale('gu'),
    nativeName: 'ગુજરાતી',
    nameZh: '古吉拉特语',
    nameEn: 'Gujarati',
  ),
  _ImLanguage(
    key: 'ha',
    locale: Locale('ha'),
    nativeName: 'Hausa',
    nameZh: '豪萨语',
    nameEn: 'Hausa',
  ),
  _ImLanguage(
    key: 'he',
    locale: Locale('he'),
    nativeName: 'עברית',
    nameZh: '希伯来语',
    nameEn: 'Hebrew',
  ),
  _ImLanguage(
    key: 'hi',
    locale: Locale('hi'),
    nativeName: 'हिन्दी',
    nameZh: '印地语',
    nameEn: 'Hindi',
  ),
  _ImLanguage(
    key: 'hu',
    locale: Locale('hu'),
    nativeName: 'Magyar',
    nameZh: '匈牙利语',
    nameEn: 'Hungarian',
  ),
  _ImLanguage(
    key: 'is',
    locale: Locale('is'),
    nativeName: 'Íslenska',
    nameZh: '冰岛语',
    nameEn: 'Icelandic',
  ),
  _ImLanguage(
    key: 'id',
    locale: Locale('id'),
    nativeName: 'Bahasa Indonesia',
    nameZh: '印度尼西亚语',
    nameEn: 'Indonesian',
  ),
  _ImLanguage(
    key: 'ga',
    locale: Locale('ga'),
    nativeName: 'Gaeilge',
    nameZh: '爱尔兰语',
    nameEn: 'Irish',
  ),
  _ImLanguage(
    key: 'it',
    locale: Locale('it'),
    nativeName: 'Italiano',
    nameZh: '意大利语',
    nameEn: 'Italian',
  ),
  _ImLanguage(
    key: 'ja',
    locale: Locale('ja'),
    nativeName: '日本語',
    nameZh: '日语',
    nameEn: 'Japanese',
  ),
  _ImLanguage(
    key: 'kn',
    locale: Locale('kn'),
    nativeName: 'ಕನ್ನಡ',
    nameZh: '卡纳达语',
    nameEn: 'Kannada',
  ),
  _ImLanguage(
    key: 'ka',
    locale: Locale('ka'),
    nativeName: 'ქართული',
    nameZh: '格鲁吉亚语',
    nameEn: 'Georgian',
  ),
  _ImLanguage(
    key: 'kk',
    locale: Locale('kk'),
    nativeName: 'Қазақ тілі',
    nameZh: '哈萨克语',
    nameEn: 'Kazakh',
  ),
  _ImLanguage(
    key: 'km',
    locale: Locale('km'),
    nativeName: 'ខ្មែរ',
    nameZh: '高棉语',
    nameEn: 'Khmer',
  ),
  _ImLanguage(
    key: 'ko',
    locale: Locale('ko'),
    nativeName: '한국어',
    nameZh: '韩语',
    nameEn: 'Korean',
  ),
  _ImLanguage(
    key: 'lo',
    locale: Locale('lo'),
    nativeName: 'ລາວ',
    nameZh: '老挝语',
    nameEn: 'Lao',
  ),
  _ImLanguage(
    key: 'lv',
    locale: Locale('lv'),
    nativeName: 'Latviešu',
    nameZh: '拉脱维亚语',
    nameEn: 'Latvian',
  ),
  _ImLanguage(
    key: 'lt',
    locale: Locale('lt'),
    nativeName: 'Lietuvių',
    nameZh: '立陶宛语',
    nameEn: 'Lithuanian',
  ),
  _ImLanguage(
    key: 'mk',
    locale: Locale('mk'),
    nativeName: 'Македонски',
    nameZh: '马其顿语',
    nameEn: 'Macedonian',
  ),
  _ImLanguage(
    key: 'ms',
    locale: Locale('ms'),
    nativeName: 'Bahasa Melayu',
    nameZh: '马来语',
    nameEn: 'Malay',
  ),
  _ImLanguage(
    key: 'ml',
    locale: Locale('ml'),
    nativeName: 'മലയാളം',
    nameZh: '马拉雅拉姆语',
    nameEn: 'Malayalam',
  ),
  _ImLanguage(
    key: 'mr',
    locale: Locale('mr'),
    nativeName: 'मराठी',
    nameZh: '马拉地语',
    nameEn: 'Marathi',
  ),
  _ImLanguage(
    key: 'my',
    locale: Locale('my'),
    nativeName: 'မြန်မာ',
    nameZh: '缅甸语',
    nameEn: 'Burmese',
  ),
  _ImLanguage(
    key: 'ne',
    locale: Locale('ne'),
    nativeName: 'नेपाली',
    nameZh: '尼泊尔语',
    nameEn: 'Nepali',
  ),
  _ImLanguage(
    key: 'nb',
    locale: Locale('nb'),
    nativeName: 'Norsk bokmål',
    nameZh: '书面挪威语',
    nameEn: 'Norwegian Bokmål',
  ),
  _ImLanguage(
    key: 'om',
    locale: Locale('om'),
    nativeName: 'Oromoo',
    nameZh: '奥罗莫语',
    nameEn: 'Oromo',
  ),
  _ImLanguage(
    key: 'ps',
    locale: Locale('ps'),
    nativeName: 'پښتو',
    nameZh: '普什图语',
    nameEn: 'Pashto',
  ),
  _ImLanguage(
    key: 'fa',
    locale: Locale('fa'),
    nativeName: 'فارسی',
    nameZh: '波斯语',
    nameEn: 'Persian',
  ),
  _ImLanguage(
    key: 'pl',
    locale: Locale('pl'),
    nativeName: 'Polski',
    nameZh: '波兰语',
    nameEn: 'Polish',
  ),
  _ImLanguage(
    key: 'pt-BR',
    locale: Locale('pt', 'BR'),
    nativeName: 'Português (Brasil)',
    nameZh: '葡萄牙语（巴西）',
    nameEn: 'Portuguese (Brazil)',
  ),
  _ImLanguage(
    key: 'pt-PT',
    locale: Locale('pt', 'PT'),
    nativeName: 'Português (Portugal)',
    nameZh: '葡萄牙语（葡萄牙）',
    nameEn: 'Portuguese (Portugal)',
  ),
  _ImLanguage(
    key: 'pa',
    locale: Locale('pa'),
    nativeName: 'ਪੰਜਾਬੀ',
    nameZh: '旁遮普语',
    nameEn: 'Punjabi',
  ),
  _ImLanguage(
    key: 'ro',
    locale: Locale('ro'),
    nativeName: 'Română',
    nameZh: '罗马尼亚语',
    nameEn: 'Romanian',
  ),
  _ImLanguage(
    key: 'ru',
    locale: Locale('ru'),
    nativeName: 'Русский',
    nameZh: '俄语',
    nameEn: 'Russian',
  ),
  _ImLanguage(
    key: 'sr',
    locale: Locale('sr'),
    nativeName: 'Српски',
    nameZh: '塞尔维亚语',
    nameEn: 'Serbian',
  ),
  _ImLanguage(
    key: 'sk',
    locale: Locale('sk'),
    nativeName: 'Slovenčina',
    nameZh: '斯洛伐克语',
    nameEn: 'Slovak',
  ),
  _ImLanguage(
    key: 'sl',
    locale: Locale('sl'),
    nativeName: 'Slovenščina',
    nameZh: '斯洛文尼亚语',
    nameEn: 'Slovenian',
  ),
  _ImLanguage(
    key: 'so',
    locale: Locale('so'),
    nativeName: 'Soomaali',
    nameZh: '索马里语',
    nameEn: 'Somali',
  ),
  _ImLanguage(
    key: 'es',
    locale: Locale('es'),
    nativeName: 'Español',
    nameZh: '西班牙语',
    nameEn: 'Spanish',
  ),
  _ImLanguage(
    key: 'sw',
    locale: Locale('sw'),
    nativeName: 'Kiswahili',
    nameZh: '斯瓦希里语',
    nameEn: 'Swahili',
  ),
  _ImLanguage(
    key: 'sv',
    locale: Locale('sv'),
    nativeName: 'Svenska',
    nameZh: '瑞典语',
    nameEn: 'Swedish',
  ),
  _ImLanguage(
    key: 'ta',
    locale: Locale('ta'),
    nativeName: 'தமிழ்',
    nameZh: '泰米尔语',
    nameEn: 'Tamil',
  ),
  _ImLanguage(
    key: 'te',
    locale: Locale('te'),
    nativeName: 'తెలుగు',
    nameZh: '泰卢固语',
    nameEn: 'Telugu',
  ),
  _ImLanguage(
    key: 'th',
    locale: Locale('th'),
    nativeName: 'ไทย',
    nameZh: '泰语',
    nameEn: 'Thai',
  ),
  _ImLanguage(
    key: 'tr',
    locale: Locale('tr'),
    nativeName: 'Türkçe',
    nameZh: '土耳其语',
    nameEn: 'Turkish',
  ),
  _ImLanguage(
    key: 'uk',
    locale: Locale('uk'),
    nativeName: 'Українська',
    nameZh: '乌克兰语',
    nameEn: 'Ukrainian',
  ),
  _ImLanguage(
    key: 'ur',
    locale: Locale('ur'),
    nativeName: 'اردو',
    nameZh: '乌尔都语',
    nameEn: 'Urdu',
  ),
  _ImLanguage(
    key: 'uz',
    locale: Locale('uz'),
    nativeName: 'O‘zbek',
    nameZh: '乌兹别克语',
    nameEn: 'Uzbek',
  ),
  _ImLanguage(
    key: 'vi',
    locale: Locale('vi'),
    nativeName: 'Tiếng Việt',
    nameZh: '越南语',
    nameEn: 'Vietnamese',
  ),
  _ImLanguage(
    key: 'cy',
    locale: Locale('cy'),
    nativeName: 'Cymraeg',
    nameZh: '威尔士语',
    nameEn: 'Welsh',
  ),
  _ImLanguage(
    key: 'eu',
    locale: Locale('eu'),
    nativeName: 'Euskara',
    nameZh: '巴斯克语',
    nameEn: 'Basque',
  ),
  _ImLanguage(
    key: 'gl',
    locale: Locale('gl'),
    nativeName: 'Galego',
    nameZh: '加利西亚语',
    nameEn: 'Galician',
  ),
  _ImLanguage(
    key: 'ig',
    locale: Locale('ig'),
    nativeName: 'Igbo',
    nameZh: '伊博语',
    nameEn: 'Igbo',
  ),
  _ImLanguage(
    key: 'xh',
    locale: Locale('xh'),
    nativeName: 'isiXhosa',
    nameZh: '科萨语',
    nameEn: 'Xhosa',
  ),
  _ImLanguage(
    key: 'yo',
    locale: Locale('yo'),
    nativeName: 'Yorùbá',
    nameZh: '约鲁巴语',
    nameEn: 'Yoruba',
  ),
  _ImLanguage(
    key: 'zu',
    locale: Locale('zu'),
    nativeName: 'isiZulu',
    nameZh: '祖鲁语',
    nameEn: 'Zulu',
  ),
];
