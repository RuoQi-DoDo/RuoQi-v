import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// `flutter_test`'s built-in tooltip finder looks for the legacy Material
/// tooltip type, while the app now uses the standalone Material UI library.
Finder findMaterialTooltip(String message) {
  return find.byWidgetPredicate(
    (widget) => widget is Tooltip && widget.message == message,
  );
}
