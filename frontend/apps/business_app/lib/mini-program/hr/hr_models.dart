import 'package:flutter/foundation.dart';

class HrUser {
  const HrUser({
    required this.id,
    required this.name,
    required this.employeeNo,
    required this.department,
    required this.position,
    required this.manager,
    required this.email,
    required this.phone,
    required this.joinDate,
    this.isManager = true,
  });

  final int id;
  final String name;
  final String employeeNo;
  final String department;
  final String position;
  final String manager;
  final String email;
  final String phone;
  final DateTime joinDate;
  final bool isManager;

  HrUser copyWith({
    String? name,
    String? department,
    String? position,
    String? manager,
    String? email,
    String? phone,
  }) {
    return HrUser(
      id: id,
      name: name ?? this.name,
      employeeNo: employeeNo,
      department: department ?? this.department,
      position: position ?? this.position,
      manager: manager ?? this.manager,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joinDate: joinDate,
      isManager: isManager,
    );
  }
}

class HrPunchState {
  const HrPunchState({
    required this.isClockedIn,
    required this.clockInTime,
    required this.clockOutTime,
    required this.workedSeconds,
    required this.breakSeconds,
    required this.overtimeSeconds,
    required this.location,
    this.inGeofence = true,
  });

  final bool isClockedIn;
  final String? clockInTime;
  final String? clockOutTime;
  final int workedSeconds;
  final int breakSeconds;
  final int overtimeSeconds;
  final String location;
  final bool inGeofence;

  HrPunchState copyWith({
    bool? isClockedIn,
    String? clockInTime,
    String? clockOutTime,
    int? workedSeconds,
    int? breakSeconds,
    int? overtimeSeconds,
    String? location,
    bool? inGeofence,
  }) {
    return HrPunchState(
      isClockedIn: isClockedIn ?? this.isClockedIn,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      workedSeconds: workedSeconds ?? this.workedSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      overtimeSeconds: overtimeSeconds ?? this.overtimeSeconds,
      location: location ?? this.location,
      inGeofence: inGeofence ?? this.inGeofence,
    );
  }
}

class HrOnLeave {
  const HrOnLeave({required this.name, required this.leaveType});

  final String name;
  final String leaveType;
}

class HrHomeSnapshot {
  const HrHomeSnapshot({
    required this.user,
    required this.punch,
    required this.pendingApprovals,
    required this.unreadNotifications,
    required this.featuredAnnouncementId,
    required this.onLeaveToday,
    required this.serverConnected,
  });

  final HrUser user;
  final HrPunchState punch;
  final int pendingApprovals;
  final int unreadNotifications;
  final int featuredAnnouncementId;
  final List<HrOnLeave> onLeaveToday;
  final bool serverConnected;
}

class HrAttendanceDay {
  const HrAttendanceDay({
    required this.id,
    required this.date,
    required this.clockIn,
    required this.clockOut,
    required this.workedMinutes,
    required this.shift,
    this.late = false,
    this.earlyOut = false,
  });

  final int id;
  final DateTime date;
  final String? clockIn;
  final String? clockOut;
  final int workedMinutes;
  final String shift;
  final bool late;
  final bool earlyOut;
}

class HrAttendanceSnapshot {
  const HrAttendanceSnapshot({
    required this.month,
    required this.workedMinutes,
    required this.expectedHours,
    required this.presentDays,
    required this.lateIns,
    required this.earlyOuts,
    required this.days,
  });

  final DateTime month;
  final int workedMinutes;
  final int expectedHours;
  final int presentDays;
  final int lateIns;
  final int earlyOuts;
  final List<HrAttendanceDay> days;
}

enum HrLeaveStatus { pending, approved, rejected, cancelled }

extension HrLeaveStatusLabel on HrLeaveStatus {
  String get label => switch (this) {
    HrLeaveStatus.pending => '审批中',
    HrLeaveStatus.approved => '已通过',
    HrLeaveStatus.rejected => '已驳回',
    HrLeaveStatus.cancelled => '已撤销',
  };
}

class HrLeaveBalance {
  const HrLeaveBalance({
    required this.id,
    required this.type,
    required this.availableDays,
    required this.usedDays,
    required this.colorIndex,
  });

  final int id;
  final String type;
  final double availableDays;
  final double usedDays;
  final int colorIndex;
}

class HrLeaveRequest {
  const HrLeaveRequest({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.halfDay = false,
  });

  final int id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final String reason;
  final HrLeaveStatus status;
  final DateTime submittedAt;
  final bool halfDay;
}

class HrHoliday {
  const HrHoliday({
    required this.name,
    required this.date,
    required this.description,
  });

  final String name;
  final DateTime date;
  final String description;
}

enum HrApprovalKind { leave, shift, workType, expense, attendance }

extension HrApprovalKindLabel on HrApprovalKind {
  String get label => switch (this) {
    HrApprovalKind.leave => '请假',
    HrApprovalKind.shift => '调班',
    HrApprovalKind.workType => '办公方式',
    HrApprovalKind.expense => '报销',
    HrApprovalKind.attendance => '补卡',
  };
}

class HrApprovalItem {
  const HrApprovalItem({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.kind,
    required this.ask,
    required this.reason,
    required this.submittedAt,
    this.warning,
    this.canReject = true,
  });

  final int id;
  final int employeeId;
  final String name;
  final HrApprovalKind kind;
  final String ask;
  final String reason;
  final DateTime submittedAt;
  final String? warning;
  final bool canReject;
}

class HrAnnouncement {
  const HrAnnouncement({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.author,
    required this.createdAt,
    required this.content,
    required this.unread,
  });

  final int id;
  final String title;
  final String summary;
  final String category;
  final String author;
  final DateTime createdAt;
  final List<String> content;
  final bool unread;

  HrAnnouncement copyWith({bool? unread}) => HrAnnouncement(
    id: id,
    title: title,
    summary: summary,
    category: category,
    author: author,
    createdAt: createdAt,
    content: content,
    unread: unread ?? this.unread,
  );
}

class HrNotification {
  const HrNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.unread,
    required this.icon,
  });

  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool unread;
  final String icon;

  HrNotification copyWith({bool? unread}) => HrNotification(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    unread: unread ?? this.unread,
    icon: icon,
  );
}

enum HrTeamState { checkedIn, onLeave, notIn }

extension HrTeamStateLabel on HrTeamState {
  String get label => switch (this) {
    HrTeamState.checkedIn => '已到岗',
    HrTeamState.onLeave => '请假中',
    HrTeamState.notIn => '未打卡',
  };
}

class HrTeamMember {
  const HrTeamMember({
    required this.id,
    required this.name,
    required this.position,
    required this.state,
    required this.clockIn,
    required this.leaveType,
  });

  final int id;
  final String name;
  final String position;
  final HrTeamState state;
  final String? clockIn;
  final String? leaveType;
}

class HrDirectoryEntry {
  const HrDirectoryEntry({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    this.extension,
  });

  final int id;
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String? extension;
}

class HrPayComponent {
  const HrPayComponent({required this.title, required this.amount});

  final String title;
  final double amount;
}

class HrPayslip {
  const HrPayslip({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.netPay,
    required this.grossPay,
    required this.deductions,
    required this.status,
    required this.earnings,
    required this.deductionItems,
  });

  final int id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double netPay;
  final double grossPay;
  final double deductions;
  final String status;
  final List<HrPayComponent> earnings;
  final List<HrPayComponent> deductionItems;
}

enum HrRequestStatus { pending, approved, rejected }

extension HrRequestStatusLabel on HrRequestStatus {
  String get label => switch (this) {
    HrRequestStatus.pending => '审批中',
    HrRequestStatus.approved => '已通过',
    HrRequestStatus.rejected => '已驳回',
  };
}

enum HrRequestKind { shift, workType, expense, asset }

extension HrRequestKindLabel on HrRequestKind {
  String get label => switch (this) {
    HrRequestKind.shift => '调班申请',
    HrRequestKind.workType => '办公方式',
    HrRequestKind.expense => '费用报销',
    HrRequestKind.asset => '资产申请',
  };

  String get shortLabel => switch (this) {
    HrRequestKind.shift => '调班',
    HrRequestKind.workType => '远程',
    HrRequestKind.expense => '报销',
    HrRequestKind.asset => '资产',
  };

  String get description => switch (this) {
    HrRequestKind.shift => '更换班次或工作时间',
    HrRequestKind.workType => '远程、办公室或混合办公',
    HrRequestKind.expense => '差旅、交通及业务费用',
    HrRequestKind.asset => '电脑、显示器等办公设备',
  };
}

class HrRequestItem {
  const HrRequestItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.date,
    required this.status,
  });

  final int id;
  final HrRequestKind kind;
  final String title;
  final String detail;
  final DateTime date;
  final HrRequestStatus status;
}

@immutable
class HrSeedData {
  const HrSeedData({
    required this.home,
    required this.attendance,
    required this.leaveBalances,
    required this.leaveRequests,
    required this.holidays,
    required this.approvals,
    required this.announcements,
    required this.notifications,
    required this.team,
    required this.directory,
    required this.payslips,
    required this.requests,
  });

  final HrHomeSnapshot home;
  final HrAttendanceSnapshot attendance;
  final List<HrLeaveBalance> leaveBalances;
  final List<HrLeaveRequest> leaveRequests;
  final List<HrHoliday> holidays;
  final List<HrApprovalItem> approvals;
  final List<HrAnnouncement> announcements;
  final List<HrNotification> notifications;
  final List<HrTeamMember> team;
  final List<HrDirectoryEntry> directory;
  final List<HrPayslip> payslips;
  final List<HrRequestItem> requests;

  HrSeedData copyWith({
    HrHomeSnapshot? home,
    HrAttendanceSnapshot? attendance,
    List<HrLeaveBalance>? leaveBalances,
    List<HrLeaveRequest>? leaveRequests,
    List<HrHoliday>? holidays,
    List<HrApprovalItem>? approvals,
    List<HrAnnouncement>? announcements,
    List<HrNotification>? notifications,
    List<HrTeamMember>? team,
    List<HrDirectoryEntry>? directory,
    List<HrPayslip>? payslips,
    List<HrRequestItem>? requests,
  }) {
    return HrSeedData(
      home: home ?? this.home,
      attendance: attendance ?? this.attendance,
      leaveBalances: leaveBalances ?? this.leaveBalances,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      holidays: holidays ?? this.holidays,
      approvals: approvals ?? this.approvals,
      announcements: announcements ?? this.announcements,
      notifications: notifications ?? this.notifications,
      team: team ?? this.team,
      directory: directory ?? this.directory,
      payslips: payslips ?? this.payslips,
      requests: requests ?? this.requests,
    );
  }
}
