import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('ruoQiBusinessConfig')
external JSObject? get _businessConfig;

String readWebBusinessGroupId() {
  const fallback = String.fromEnvironment('BUSINESS_GROUP', defaultValue: 'im');
  final config = _businessConfig;
  if (config == null) {
    return fallback;
  }
  final value = config.getProperty<JSString?>('group'.toJS)?.toDart.trim();
  return value == null || value.isEmpty ? fallback : value;
}
