import 'group.dart';
import 'group_config_stub.dart'
    if (dart.library.js_interop) 'group_config_web.dart'
    as platform;

BusinessGroup resolveConfiguredBusinessGroup({String? override}) {
  return BusinessGroup.parse(override ?? platform.readWebBusinessGroupId());
}
