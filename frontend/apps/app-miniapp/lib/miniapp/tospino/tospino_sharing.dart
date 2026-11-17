import 'package:share_plus/share_plus.dart';

abstract interface class TospinoShareGateway {
  Future<void> shareText(String text, {String? subject});
}

class TospinoSystemShareGateway implements TospinoShareGateway {
  const TospinoSystemShareGateway();

  @override
  Future<void> shareText(String text, {String? subject}) async {
    if (text.trim().isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}
