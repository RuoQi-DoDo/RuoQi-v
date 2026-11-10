import 'package:flutter/foundation.dart';

import 'hr_mock_data.dart';
import 'hr_models.dart';
import 'hr_repository.dart';
import 'hr_routes.dart';

class HrAppController extends ChangeNotifier {
  HrAppController({
    HrRepository? repository,
    HrSeedData? initialData,
    this.useMockData = true,
  }) : repository = repository ?? const HrMockRepository(),
       _data = initialData ?? HrMockData.seed(),
       _history = [HrRoute.home] {
    _selectedAttendanceDate = DateTime.now();
  }

  final HrRepository repository;
  final bool useMockData;

  late HrSeedData _data;
  final List<HrRoute> _history;
  HrRoute _route = HrRoute.home;
  bool _forward = true;
  bool _busy = false;
  int _selectedAnnouncementId = 1;
  int _selectedPayslipId = 1;
  HrRequestKind _requestKind = HrRequestKind.workType;
  late DateTime _selectedAttendanceDate;
  HrApprovalItem? _lastDecision;
  int _lastDecisionIndex = -1;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  HrSeedData get data => _data;
  HrUser get user => _data.home.user;
  HrHomeSnapshot get home => _data.home;
  HrPunchState get punch => _data.home.punch;
  HrAttendanceSnapshot get attendance => _data.attendance;
  List<HrLeaveBalance> get leaveBalances => _data.leaveBalances;
  List<HrLeaveRequest> get leaveRequests => _data.leaveRequests;
  List<HrHoliday> get holidays => _data.holidays;
  List<HrApprovalItem> get approvals => _data.approvals;
  List<HrAnnouncement> get announcements => _data.announcements;
  List<HrNotification> get notifications => _data.notifications;
  List<HrTeamMember> get team => _data.team;
  List<HrDirectoryEntry> get directory => _data.directory;
  List<HrPayslip> get payslips => _data.payslips;
  List<HrRequestItem> get requests => _data.requests;
  HrRoute get route => _route;
  bool get forward => _forward;
  bool get busy => _busy;
  bool get canGoBack => _history.length > 1;
  int get tabIndex => _route.tabIndex;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;
  HrRequestKind get requestKind => _requestKind;
  DateTime get selectedAttendanceDate => _selectedAttendanceDate;
  int get selectedAnnouncementId => _selectedAnnouncementId;
  int get selectedPayslipId => _selectedPayslipId;
  HrAnnouncement? get selectedAnnouncement =>
      _announcementsOrNull(_selectedAnnouncementId);
  HrPayslip? get selectedPayslip => _payslipOrNull(_selectedPayslipId);
  int get unreadNotificationCount =>
      notifications.where((item) => item.unread).length;
  int get unreadAnnouncementCount =>
      announcements.where((item) => item.unread).length;

  Future<void> refresh() async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      final remote = await repository.loadSnapshot();
      _data = remote.copyWith(
        home: HrHomeSnapshot(
          user: remote.home.user,
          punch: remote.home.punch,
          pendingApprovals: approvals.length,
          unreadNotifications: remote.home.unreadNotifications,
          featuredAnnouncementId: remote.home.featuredAnnouncementId,
          onLeaveToday: remote.home.onLeaveToday,
          serverConnected: true,
        ),
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void switchTab(int index) {
    final route = switch (index) {
      0 => HrRoute.home,
      1 => HrRoute.attendance,
      2 => HrRoute.requests,
      3 => HrRoute.team,
      _ => HrRoute.me,
    };
    _forward = index >= tabIndex;
    _route = route;
    _history
      ..clear()
      ..add(route);
    notifyListeners();
  }

  void open(HrRoute route) {
    if (_route == route) {
      return;
    }
    _forward = true;
    _route = route;
    _history.add(route);
    notifyListeners();
  }

  void back() {
    if (!canGoBack) {
      return;
    }
    _forward = false;
    _history.removeLast();
    _route = _history.last;
    notifyListeners();
  }

  void resetToHome() {
    _forward = false;
    _history
      ..clear()
      ..add(HrRoute.home);
    _route = HrRoute.home;
    notifyListeners();
  }

  void selectAttendanceDate(DateTime date) {
    _selectedAttendanceDate = date;
    open(HrRoute.correction);
  }

  void openAnnouncement(int id) {
    _selectedAnnouncementId = id;
    _markAnnouncementRead(id);
    open(HrRoute.announcementDetail);
  }

  void openPayslip(int id) {
    _selectedPayslipId = id;
    open(HrRoute.payslipDetail);
  }

  void composeRequest([HrRequestKind? kind]) {
    _requestKind = kind ?? HrRequestKind.workType;
    open(HrRoute.requestCompose);
  }

  void openRequest(HrRequestKind kind, HrRoute route) {
    _requestKind = kind;
    open(route);
  }

  void completeSignIn() {
    resetToHome();
  }

  Future<bool> punchNow() async {
    if (_busy) {
      return false;
    }
    final clockIn = !punch.isClockedIn;
    _busy = true;
    notifyListeners();
    try {
      await repository.punch(clockIn: clockIn);
      final now = DateTime.now();
      final time = _timeOf(now);
      _data = _data.copyWith(
        home: HrHomeSnapshot(
          user: user,
          punch: punch.copyWith(
            isClockedIn: clockIn,
            clockInTime: clockIn ? time : punch.clockInTime,
            clockOutTime: clockIn ? null : time,
            workedSeconds: clockIn ? 0 : punch.workedSeconds,
          ),
          pendingApprovals: approvals.length,
          unreadNotifications: unreadNotificationCount,
          featuredAnnouncementId: home.featuredAnnouncementId,
          onLeaveToday: home.onLeaveToday,
          serverConnected: home.serverConnected,
        ),
      );
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> submitLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required bool halfDay,
  }) async {
    final days = halfDay ? 0.5 : _workingDays(startDate, endDate);
    await repository.applyLeave(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      halfDay: halfDay,
    );
    final request = HrLeaveRequest(
      id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
      type: type,
      startDate: startDate,
      endDate: endDate,
      days: days,
      reason: reason.trim().isEmpty ? '未填写事由' : reason.trim(),
      status: HrLeaveStatus.pending,
      submittedAt: DateTime.now(),
      halfDay: halfDay,
    );
    _data = _data.copyWith(leaveRequests: [request, ...leaveRequests]);
    notifyListeners();
  }

  Future<void> submitCorrection({
    required String clockIn,
    required String clockOut,
    required String reason,
  }) async {
    await repository.requestCorrection(
      date: selectedAttendanceDate,
      clockIn: clockIn,
      clockOut: clockOut,
      reason: reason,
    );
    final request = HrRequestItem(
      id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
      kind: HrRequestKind.shift,
      title: '补卡申请',
      detail:
          '${selectedAttendanceDate.month}月${selectedAttendanceDate.day}日 · '
          '$clockIn - $clockOut',
      date: DateTime.now(),
      status: HrRequestStatus.pending,
    );
    _data = _data.copyWith(requests: [request, ...requests]);
    notifyListeners();
  }

  Future<void> submitLeaveAllocation({
    required String type,
    required double days,
    required String reason,
  }) async {
    await repository.requestLeaveAllocation(
      type: type,
      days: days,
      reason: reason,
    );
  }

  Future<void> submitHelpdeskTicket({
    required String category,
    required String subject,
    required String description,
  }) {
    return repository.submitHelpdeskTicket(
      category: category,
      subject: subject,
      description: description,
    );
  }

  Future<void> enrollFace() => repository.enrollFace();

  Future<void> submitRequest({
    required String title,
    required String detail,
  }) async {
    await repository.submitRequest(
      kind: requestKind,
      title: title.trim(),
      detail: detail.trim(),
    );
    final request = HrRequestItem(
      id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
      kind: requestKind,
      title: title.trim(),
      detail: detail.trim(),
      date: DateTime.now(),
      status: HrRequestStatus.pending,
    );
    _data = _data.copyWith(requests: [request, ...requests]);
    notifyListeners();
  }

  Future<void> decideApproval(
    HrApprovalItem item, {
    required bool approve,
  }) async {
    final index = approvals.indexWhere((entry) => entry.id == item.id);
    await repository.decideApproval(item, approve: approve);
    _lastDecision = item;
    _lastDecisionIndex = index;
    _data = _data.copyWith(
      approvals: [
        for (final entry in approvals)
          if (entry.id != item.id) entry,
      ],
      home: HrHomeSnapshot(
        user: user,
        punch: punch,
        pendingApprovals: approvals.length - 1,
        unreadNotifications: unreadNotificationCount,
        featuredAnnouncementId: home.featuredAnnouncementId,
        onLeaveToday: home.onLeaveToday,
        serverConnected: home.serverConnected,
      ),
    );
    notifyListeners();
  }

  Future<void> undoLastDecision() async {
    final item = _lastDecision;
    if (item == null) {
      return;
    }
    final restored = [...approvals];
    restored.insert(_lastDecisionIndex.clamp(0, restored.length), item);
    _data = _data.copyWith(
      approvals: restored,
      home: HrHomeSnapshot(
        user: user,
        punch: punch,
        pendingApprovals: restored.length,
        unreadNotifications: unreadNotificationCount,
        featuredAnnouncementId: home.featuredAnnouncementId,
        onLeaveToday: home.onLeaveToday,
        serverConnected: home.serverConnected,
      ),
    );
    _lastDecision = null;
    _lastDecisionIndex = -1;
    notifyListeners();
  }

  Future<void> markNotificationRead(int id) async {
    await repository.markNotificationRead(id);
    _data = _data.copyWith(
      notifications: [
        for (final item in notifications)
          if (item.id == id) item.copyWith(unread: false) else item,
      ],
    );
    _syncUnread();
  }

  Future<void> markAllNotificationsRead() async {
    await repository.markAllNotificationsRead();
    _data = _data.copyWith(
      notifications: [
        for (final item in notifications) item.copyWith(unread: false),
      ],
    );
    _syncUnread();
  }

  Future<void> _markAnnouncementRead(int id) async {
    await repository.markAnnouncementRead(id);
    _data = _data.copyWith(
      announcements: [
        for (final item in announcements)
          if (item.id == id) item.copyWith(unread: false) else item,
      ],
    );
    _syncUnread();
  }

  void updateProfile({
    required String name,
    required String department,
    required String position,
    required String manager,
    required String email,
    required String phone,
  }) {
    _data = _data.copyWith(
      home: HrHomeSnapshot(
        user: user.copyWith(
          name: name.trim(),
          department: department.trim(),
          position: position.trim(),
          manager: manager.trim(),
          email: email.trim(),
          phone: phone.trim(),
        ),
        punch: punch,
        pendingApprovals: approvals.length,
        unreadNotifications: unreadNotificationCount,
        featuredAnnouncementId: home.featuredAnnouncementId,
        onLeaveToday: home.onLeaveToday,
        serverConnected: home.serverConnected,
      ),
    );
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    notifyListeners();
  }

  void _syncUnread() {
    _data = _data.copyWith(
      home: HrHomeSnapshot(
        user: user,
        punch: punch,
        pendingApprovals: approvals.length,
        unreadNotifications: unreadNotificationCount,
        featuredAnnouncementId: home.featuredAnnouncementId,
        onLeaveToday: home.onLeaveToday,
        serverConnected: home.serverConnected,
      ),
    );
    notifyListeners();
  }

  HrAnnouncement? _announcementsOrNull(int id) {
    for (final item in announcements) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  HrPayslip? _payslipOrNull(int id) {
    for (final item in payslips) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  static String _timeOf(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  static double _workingDays(DateTime start, DateTime end) {
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    var days = 0;
    while (!cursor.isAfter(last)) {
      if (cursor.weekday <= DateTime.friday) {
        days++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return days.clamp(1, 366).toDouble();
  }
}
