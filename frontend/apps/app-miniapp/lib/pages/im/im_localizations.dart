import 'package:flutter/widgets.dart';

import '../../localization.dart';

String imText(BuildContext context, String chinese, String english) {
  return AppLocalizations.of(context).text(chinese, english);
}

String imLanguageName(Locale locale) {
  return locale.languageCode == 'en' ? 'English' : '简体中文';
}

String imLanguageTranslation(BuildContext context, Locale locale) {
  final current = Localizations.localeOf(context);
  if (current.languageCode == 'en') {
    return locale.languageCode == 'en' ? 'English' : 'Simplified Chinese';
  }
  return locale.languageCode == 'en' ? '英语' : '简体中文';
}
