import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.instance.platformDispatcher
    ..localeTestValue = const Locale('zh')
    ..localesTestValue = const [Locale('zh')];
  await testMain();
}
