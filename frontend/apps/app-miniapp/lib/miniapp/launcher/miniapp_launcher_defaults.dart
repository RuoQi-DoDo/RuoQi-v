import 'package:flutter/material.dart';

import 'miniapp_launcher_item.dart';

/// Initial demo entries used until the account provides its launcher library.
const defaultRecentMiniPrograms = <MiniProgramLauncherItem>[
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.tospino,
    label: 'Tospino',
    icon: Icons.storefront_rounded,
    color: Color(0xFF42B7AE),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.ats,
    label: '企业直聘',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF0D9488),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.hr,
    label: '人事',
    icon: Icons.badge_outlined,
    color: Color(0xFFC43D28),
  ),
  MiniProgramLauncherItem(
    id: 'file-assistant',
    label: '文件助手',
    icon: Icons.folder_outlined,
    color: Color(0xFF0969DA),
  ),
  MiniProgramLauncherItem(
    id: 'enterprise-services',
    label: '企业服务',
    icon: Icons.business_center_outlined,
    color: Color(0xFFE36A2E),
  ),
  MiniProgramLauncherItem(
    id: 'meeting',
    label: '会议',
    icon: Icons.videocam_outlined,
    color: Color(0xFF4D8DFF),
  ),
  MiniProgramLauncherItem(
    id: 'resume-assistant',
    label: '简历助手',
    icon: Icons.description_outlined,
    color: Color(0xFF8B5CF6),
  ),
  MiniProgramLauncherItem(
    id: 'talent-pool',
    label: '人才库',
    icon: Icons.people_outline_rounded,
    color: Color(0xFF16A34A),
  ),
  MiniProgramLauncherItem(
    id: 'interview-calendar',
    label: '面试日历',
    icon: Icons.calendar_month_outlined,
    color: Color(0xFF0EA5E9),
  ),
];

const defaultMyMiniPrograms = <MiniProgramLauncherItem>[
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.tospino,
    label: 'Tospino',
    icon: Icons.storefront_rounded,
    color: Color(0xFF42B7AE),
    tileKey: Key('mini-program-picker-tospino'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.ats,
    label: '企业直聘',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF0D9488),
    tileKey: Key('mini-program-picker-ats'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.hr,
    label: '人事',
    icon: Icons.badge_outlined,
    color: Color(0xFFC43D28),
    tileKey: Key('mini-program-picker-hr'),
  ),
  MiniProgramLauncherItem(
    id: 'enterprise-services',
    label: '企业服务',
    icon: Icons.business_center_outlined,
    color: Color(0xFFE36A2E),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.merchant,
    label: '商户',
    icon: Icons.fingerprint,
    color: Color(0xFF3B82F6),
    tileKey: Key('mini-program-picker-merchant'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.partner,
    label: '伙伴',
    icon: Icons.handshake_outlined,
    color: Color(0xFF8B5CF6),
    tileKey: Key('mini-program-picker-partner'),
  ),
  MiniProgramLauncherItem(
    id: MiniProgramLauncherIds.platform,
    label: '平台管理',
    icon: Icons.admin_panel_settings_outlined,
    color: Color(0xFF0D9488),
    tileKey: Key('mini-program-picker-platform'),
  ),
  MiniProgramLauncherItem(
    id: 'talent-assessment',
    label: '人才测评',
    icon: Icons.psychology_outlined,
    color: Color(0xFF10B981),
  ),
  MiniProgramLauncherItem(
    id: 'video-interview',
    label: '视频面试',
    icon: Icons.video_chat_outlined,
    color: Color(0xFFF97316),
  ),
  MiniProgramLauncherItem(
    id: 'schedule',
    label: '日程',
    icon: Icons.event_note_outlined,
    color: Color(0xFF14B8A6),
  ),
];
