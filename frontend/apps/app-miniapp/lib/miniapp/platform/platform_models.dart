import 'package:flutter/material.dart';

enum PlatformCredentialMode { bind, change }

enum PlatformProfileField { avatar, nickname, gender, age }

enum PlatformPasswordVerification { password, sms, email }

class PlatformLinkedAccount {
  const PlatformLinkedAccount({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bound,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool bound;

  PlatformLinkedAccount copyWith({bool? bound}) {
    return PlatformLinkedAccount(
      id: id,
      name: name,
      icon: icon,
      color: color,
      bound: bound ?? this.bound,
    );
  }
}

class PlatformDevice {
  const PlatformDevice({
    required this.id,
    required this.name,
    required this.location,
    required this.lastActive,
    required this.icon,
    this.current = false,
  });

  final String id;
  final String name;
  final String location;
  final String lastActive;
  final IconData icon;
  final bool current;
}

class PlatformLogEntry {
  const PlatformLogEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.time,
    required this.device,
    required this.location,
    required this.icon,
    this.risk = false,
  });

  final String id;
  final String action;
  final String description;
  final String time;
  final String device;
  final String location;
  final IconData icon;
  final bool risk;
}

class PlatformAccountController extends ChangeNotifier {
  String nickname = '戴维斯';
  final String accountId = '110119114';
  String gender = '男';
  int age = 18;
  int avatarStyle = 0;
  String? phone = '+86 147******973';
  String? email = 'a****7@163.com';
  bool passwordSet = true;

  final List<PlatformLinkedAccount> _linkedAccounts = <PlatformLinkedAccount>[
    const PlatformLinkedAccount(
      id: 'apple',
      name: 'Apple',
      icon: Icons.apple,
      color: Color(0xFF111111),
      bound: true,
    ),
    const PlatformLinkedAccount(
      id: 'facebook',
      name: 'Facebook',
      icon: Icons.facebook,
      color: Color(0xFF1877F2),
      bound: true,
    ),
    const PlatformLinkedAccount(
      id: 'google',
      name: 'Google',
      icon: Icons.g_mobiledata_rounded,
      color: Color(0xFF4285F4),
      bound: true,
    ),
  ];

  final List<PlatformDevice> _devices = <PlatformDevice>[
    const PlatformDevice(
      id: 'current-phone',
      name: 'nova 5 Pro',
      location: '深圳 · 当前设备',
      lastActive: '刚刚活跃',
      icon: Icons.phone_iphone_rounded,
      current: true,
    ),
    const PlatformDevice(
      id: 'tablet',
      name: 'MatePad Pro',
      location: '上海',
      lastActive: '昨天 18:09',
      icon: Icons.tablet_mac_rounded,
    ),
    const PlatformDevice(
      id: 'desktop',
      name: 'Chrome · Web',
      location: '深圳',
      lastActive: '2026-11-08 16:09',
      icon: Icons.language_rounded,
    ),
  ];

  final List<PlatformLogEntry> _logs = <PlatformLogEntry>[
    const PlatformLogEntry(
      id: 'log-1',
      action: '账号密码登录',
      description: '在当前设备完成账号密码登录',
      time: '今天 09:42',
      device: 'nova 5 Pro',
      location: '广东省深圳市',
      icon: Icons.login_rounded,
    ),
    const PlatformLogEntry(
      id: 'log-2',
      action: '修改昵称',
      description: '个人资料中的昵称已更新',
      time: '昨天 20:16',
      device: 'nova 5 Pro',
      location: '广东省深圳市',
      icon: Icons.edit_outlined,
    ),
    const PlatformLogEntry(
      id: 'log-3',
      action: '网页登录',
      description: '账号在网页端完成登录',
      time: '昨天 16:09',
      device: 'Chrome · Web',
      location: '广东省深圳市',
      icon: Icons.language_rounded,
    ),
    const PlatformLogEntry(
      id: 'log-4',
      action: '设备下线',
      description: 'OPPO R11s 已从在线设备中移除',
      time: '11月08日 18:22',
      device: 'OPPO R11s',
      location: '山东省威海市',
      icon: Icons.phonelink_erase_rounded,
      risk: true,
    ),
    const PlatformLogEntry(
      id: 'log-5',
      action: '绑定邮箱',
      description: '安全邮箱已绑定到当前账号',
      time: '11月05日 14:10',
      device: 'MatePad Pro',
      location: '上海市',
      icon: Icons.mark_email_read_outlined,
    ),
  ];

  List<PlatformLinkedAccount> get linkedAccounts =>
      List<PlatformLinkedAccount>.unmodifiable(_linkedAccounts);

  List<PlatformDevice> get devices =>
      List<PlatformDevice>.unmodifiable(_devices);

  List<PlatformLogEntry> get logs => List<PlatformLogEntry>.unmodifiable(_logs);

  int get linkedAccountCount =>
      _linkedAccounts.where((account) => account.bound).length;

  int get securityScore {
    var score = 58;
    if (passwordSet) {
      score += 12;
    }
    if (phone != null) {
      score += 12;
    }
    if (email != null) {
      score += 10;
    }
    score += linkedAccountCount * 2;
    return score.clamp(0, 100);
  }

  void updateNickname(String value) {
    final next = value.trim();
    if (next.isEmpty || next == nickname) {
      return;
    }
    nickname = next;
    _record(
      action: '修改昵称',
      description: '个人资料中的昵称已更新',
      icon: Icons.edit_outlined,
    );
  }

  void updateGender(String value) {
    if (value == gender) {
      return;
    }
    gender = value;
    _record(
      action: '修改性别',
      description: '个人资料中的性别已更新',
      icon: Icons.people_alt_outlined,
    );
  }

  void updateAge(int value) {
    if (value == age) {
      return;
    }
    age = value;
    _record(
      action: '修改年龄',
      description: '个人资料中的年龄已更新',
      icon: Icons.cake_outlined,
    );
  }

  void updateAvatarStyle(int value) {
    if (value == avatarStyle) {
      return;
    }
    avatarStyle = value;
    _record(
      action: '修改头像',
      description: '个人头像样式已更新',
      icon: Icons.photo_camera_outlined,
    );
  }

  void bindPhone(String value) {
    final masked = _maskPhone(value);
    final action = phone == null ? '绑定手机号' : '修改手机号';
    phone = masked;
    _record(
      action: action,
      description: '$masked 已完成身份验证',
      icon: Icons.phone_iphone_rounded,
    );
  }

  void bindEmail(String value) {
    final masked = _maskEmail(value);
    final action = email == null ? '绑定邮箱' : '修改邮箱';
    email = masked;
    _record(
      action: action,
      description: '$masked 已完成身份验证',
      icon: Icons.mark_email_read_outlined,
    );
  }

  void updatePassword() {
    passwordSet = true;
    _record(
      action: '修改登录密码',
      description: '登录密码已通过身份验证并更新',
      icon: Icons.password_rounded,
      risk: true,
    );
  }

  void setLinkedAccountBound(String id, bool bound) {
    final index = _linkedAccounts.indexWhere((account) => account.id == id);
    if (index == -1 || _linkedAccounts[index].bound == bound) {
      return;
    }
    final account = _linkedAccounts[index];
    _linkedAccounts[index] = account.copyWith(bound: bound);
    _record(
      action: bound ? '绑定${account.name}' : '解绑${account.name}',
      description: bound
          ? '${account.name} 已关联到当前平台账号'
          : '${account.name} 已从当前平台账号解除关联',
      icon: bound ? Icons.link_rounded : Icons.link_off_rounded,
      risk: !bound,
    );
  }

  void removeDevice(String id) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1 || _devices[index].current) {
      return;
    }
    final device = _devices.removeAt(index);
    _record(
      action: '设备下线',
      description: '${device.name} 已从在线设备中移除',
      icon: Icons.phonelink_erase_rounded,
      risk: true,
    );
  }

  void _record({
    required String action,
    required String description,
    required IconData icon,
    bool risk = false,
  }) {
    _logs.insert(
      0,
      PlatformLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        action: action,
        description: description,
        time: '刚刚',
        device: _devices.first.name,
        location: '广东省深圳市',
        icon: icon,
        risk: risk,
      ),
    );
    notifyListeners();
  }

  String _maskPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      return value.trim();
    }
    return '+86 ${digits.substring(0, 3)}******${digits.substring(digits.length - 4)}';
  }

  String _maskEmail(String value) {
    final parts = value.trim().split('@');
    if (parts.length != 2 || parts.first.isEmpty) {
      return value.trim();
    }
    final local = parts.first;
    if (local.length == 1) {
      return '*@${parts.last}';
    }
    return '${local[0]}****${local[local.length - 1]}@${parts.last}';
  }
}
