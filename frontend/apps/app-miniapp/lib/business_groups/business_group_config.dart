import 'business_group.dart';
import 'business_group_config_stub.dart'
    if (dart.library.js_interop) 'business_group_config_web.dart'
    as platform;

BusinessGroup resolveConfiguredBusinessGroup({String? override}) {
  return BusinessGroup.parse(override ?? platform.readWebBusinessGroupId());
}
