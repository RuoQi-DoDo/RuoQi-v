import 'package:flutter/widgets.dart';

import '../../../localization.dart';
import '../../ats/l10n/ats_labels.dart';
import '../../hr/l10n/hr_labels.dart';
import '../../launcher/l10n/launcher_labels.dart';
import '../../merchant/l10n/merchant_labels.dart';
import '../../partner/l10n/partner_labels.dart';
import '../../tospino/l10n/tospino_labels.dart';
import 'common_labels.dart';

/// Shared navigation labels are translated at render time so open mini-programs
/// react to the host language without changing their route or business data.
///
/// Translation data lives beside each mini-program. This lookup only combines
/// those local tables for widgets in the shared shell.
String localizeMiniProgramLabel(BuildContext context, String label) {
  final english = _navigationLabels[label];
  return english == null
      ? label
      : AppLocalizations.of(context).text(label, english);
}

const _navigationLabels = <String, String>{
  ...commonMiniProgramLabels,
  ...atsMiniProgramLabels,
  ...hrMiniProgramLabels,
  ...merchantMiniProgramLabels,
  ...partnerMiniProgramLabels,
  ...tospinoMiniProgramLabels,
  ...launcherMiniProgramLabels,
};
