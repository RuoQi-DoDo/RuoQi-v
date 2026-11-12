// Compatibility exports; shared account pages live in lib/pages/account/.
import '../../pages/account/account_dialogs.dart';
export '../../pages/account/account_dialogs.dart';

final showPlatformToast = showAccountToast;
final showPlatformConfirmDialog = showAccountConfirmDialog;
final showPlatformSuccessDialog = showAccountSuccessDialog;
