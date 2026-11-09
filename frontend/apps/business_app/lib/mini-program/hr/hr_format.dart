import 'package:flutter/material.dart';

const _weekdays = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const _weekdaysShort = <String>['一', '二', '三', '四', '五', '六', '日'];
const _months = <String>[
  '一月',
  '二月',
  '三月',
  '四月',
  '五月',
  '六月',
  '七月',
  '八月',
  '九月',
  '十月',
  '十一月',
  '十二月',
];

String hrWeekday(DateTime date) => _weekdays[date.weekday - 1];

String hrWeekdayShort(DateTime date) => _weekdaysShort[date.weekday - 1];

String hrMonth(DateTime date) => _months[date.month - 1];

String hrDate(DateTime date, {bool withYear = false}) {
  final base = '${date.month}月${date.day}日';
  return withYear ? '${date.year}年$base' : base;
}

String hrDateRange(DateTime start, DateTime end) {
  if (_sameDay(start, end)) {
    return hrDate(start);
  }
  if (start.year == end.year) {
    return '${start.month}月${start.day}日 - ${end.month}月${end.day}日';
  }
  return '${hrDate(start, withYear: true)} - ${hrDate(end, withYear: true)}';
}

String hrTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

String hrRelative(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes.clamp(1, 59)} 分钟前';
  }
  if (diff.inHours < 24 && _sameDay(date, now)) {
    return '${diff.inHours} 小时前';
  }
  if (diff.inDays == 1) {
    return '昨天 ${hrTime(date)}';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} 天前';
  }
  return hrDate(date);
}

String hrDuration(int totalSeconds, {bool withSeconds = false}) {
  final hours = totalSeconds ~/ 3600;
  final minutes = totalSeconds.remainder(3600) ~/ 60;
  final seconds = totalSeconds.remainder(60);
  final base =
      '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
  return withSeconds ? '$base:${seconds.toString().padLeft(2, '0')}' : base;
}

String hrMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes.remainder(60);
  if (hours == 0) {
    return '$rest 分钟';
  }
  return rest == 0 ? '$hours 小时' : '$hours 小时 $rest 分';
}

String hrMoney(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final chars = parts.first.split('').reversed.toList();
  final groups = <String>[];
  for (var i = 0; i < chars.length; i += 3) {
    groups.add(chars.skip(i).take(3).toList().reversed.join());
  }
  return '¥${groups.reversed.join(',')}.${parts.last}';
}

String hrInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  final chars = trimmed.characters;
  return chars.length > 2 ? chars.skip(chars.length - 2).toString() : trimmed;
}

Color hrAvatarColor(String name, int index) {
  const colors = <Color>[
    Color(0xFF2E6E9E),
    Color(0xFFB34A3C),
    Color(0xFF9A6B12),
    Color(0xFF1E7A54),
    Color(0xFF7153A4),
    Color(0xFF376B75),
  ];
  final seed = name.codeUnits.fold<int>(index, (sum, code) => sum + code);
  return colors[seed % colors.length];
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
