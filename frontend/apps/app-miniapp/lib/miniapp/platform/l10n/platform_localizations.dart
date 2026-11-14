import 'package:flutter/widgets.dart';

import '../../../localization.dart';

/// Translates platform mini-program UI without keeping translation data in the
/// shared host or another mini-program.
String platformText(BuildContext context, String label) {
  final english = _platformLabels[label];
  return english == null
      ? label
      : AppLocalizations.of(context).text(label, english);
}

String platformAccountLabel(BuildContext context, String accountId) =>
    AppLocalizations.of(context).text('账号 $accountId', 'Account $accountId');

const _platformLabels = <String, String>{
  '账号中心': 'Account center',
  '平台账号、安全设置与登录记录': 'Account, security and sign-in activity',
  '运营账号': 'Operations',
  '编辑个人资料': 'Edit profile',
  '安全分': 'Security score',
  '已关联': 'Linked',
  '在线设备': 'Devices',
  '个人资料': 'Profile',
  '账号安全': 'Account security',
  '账号关联': 'Linked accounts',
  '设备管理': 'Devices',
  '安全概览': 'Security overview',
  '账号保护': 'Account protection',
  '关键安全信息已完善': 'Essential security information complete',
  '建议继续完善安全信息': 'Complete your security information',
  '状态良好': 'Protected',
  '待完善': 'Incomplete',
  '安全手机': 'Security phone',
  '未绑定': 'Not linked',
  '安全邮箱': 'Security email',
  '最近动态': 'Recent activity',
  '全部记录': 'View all',
  '退出平台账号？': 'Sign out of the platform account?',
  '当前为模拟账号，退出后仍可再次进入账号中心。':
      'This is a demo account. You can return to the account center after signing out.',
  '退出登录': 'Sign out',
  '模拟账号已退出': 'Demo account signed out',
};
