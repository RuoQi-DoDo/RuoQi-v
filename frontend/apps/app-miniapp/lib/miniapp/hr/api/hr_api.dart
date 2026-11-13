import 'package:network/network.dart';

/// Horilla HR API boundary.
///
/// The mini-program defaults to mock data, but every endpoint used by the
/// reference app is kept here so switching to a real server does not change
/// the page layer.
class HrApi {
  const HrApi(this._client);

  final RuoQiNetworkClient _client;

  Future<dynamic> fetchHome() => _client.get('/mobile/home/');

  Future<dynamic> fetchAttendance({
    required int employeeId,
    required DateTime month,
  }) {
    return _client.get(
      '/attendance/my-attendance/',
      queryParameters: {
        'employee_id': employeeId,
        'month': month.month,
        'year': month.year,
        'page_size': 31,
      },
    );
  }

  Future<dynamic> fetchAttendanceHourAccount({
    required int employeeId,
    required DateTime month,
  }) {
    return _client.get(
      '/attendance/attendance-hour-account/',
      queryParameters: {
        'employee_id': employeeId,
        'month': month.month,
        'year': month.year,
      },
    );
  }

  Future<dynamic> fetchLeave() =>
      _client.get('/leave/available-leave/').then((value) => value);

  Future<dynamic> fetchLeaveBalances() =>
      _client.get('/leave/available-leave/');

  Future<dynamic> fetchLeaveRequests() => _client.get('/leave/user-request/');

  Future<dynamic> fetchHolidays() => _client.get('/leave/holiday/');

  Future<dynamic> fetchApprovals() => Future.wait([
    _client.get('/leave/request/', queryParameters: {'status': 'requested'}),
    _client.get(
      '/attendance/attendance-request/',
      queryParameters: {'status': 'requested'},
    ),
    _client.get(
      '/base/shift-requests/',
      queryParameters: {'status': 'requested'},
    ),
    _client.get(
      '/base/worktype-requests/',
      queryParameters: {'approved': false, 'canceled': false},
    ),
    _client.get(
      '/payroll/reimbusement/',
      queryParameters: {'status': 'requested'},
    ),
  ]);

  Future<dynamic> fetchAnnouncements() => _client.get(
    '/base/announcement-view',
    queryParameters: {'page_size': 50},
  );

  Future<dynamic> fetchAnnouncement(int id) =>
      _client.get('/base/announcement-view/$id');

  Future<dynamic> markAnnouncementRead(int id) =>
      _client.post('/base/announcement-view/$id/');

  Future<dynamic> fetchNotifications() => _client.get(
    '/notifications/notifications/list/all',
    queryParameters: {'page_size': 50},
  );

  Future<dynamic> markNotificationRead(int id) =>
      _client.post('/notifications/notifications/$id/');

  Future<dynamic> markAllNotificationsRead() =>
      _client.post('/notifications/notifications/bulk-read/');

  Future<dynamic> fetchTeam() => Future.wait([
    _client.get('/employee/employee-work-information/'),
    _client.get('/attendance/attendance/'),
    _client.get('/leave/request/', queryParameters: {'overall_leave': 'week'}),
  ]);

  Future<dynamic> fetchDirectory({String? search}) => _client.get(
    '/employee/list/employees/',
    queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'page_size': 50,
    },
  );

  Future<dynamic> fetchPayslips() => _client.get('/payroll/payslip/');

  Future<dynamic> fetchPayslip(int id) => _client.get('/payroll/payslip/$id');

  Future<dynamic> fetchRequests() => Future.wait([
    _client.get('/base/shift-requests/'),
    _client.get('/base/worktype-requests/'),
    _client.get('/asset/asset-requests/'),
    _client.get('/payroll/reimbusement/'),
  ]);

  Future<dynamic> clockIn({double? latitude, double? longitude}) {
    return _client.post(
      '/attendance/clock-in/',
      data: {'latitude': ?latitude, 'longitude': ?longitude},
    );
  }

  Future<dynamic> clockOut({double? latitude, double? longitude}) {
    return _client.post(
      '/attendance/clock-out/',
      data: {'latitude': ?latitude, 'longitude': ?longitude},
    );
  }

  Future<dynamic> applyLeave({
    required int employeeId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool halfDay = false,
  }) {
    return _client.post(
      '/leave/user-request/',
      data: {
        'employee_id': employeeId,
        'leave_type_id': leaveTypeId,
        'start_date': _date(startDate),
        'end_date': _date(endDate),
        'requested_days': halfDay ? 0.5 : _workingDays(startDate, endDate),
        'description': reason,
        'create_leave_request': true,
      },
    );
  }

  Future<dynamic> requestLeaveAllocation({
    required int employeeId,
    required int leaveTypeId,
    required double requestedDays,
    required String reason,
  }) {
    return _client.post(
      '/leave/user-allocation-request/',
      data: {
        'employee_id': employeeId,
        'leave_type_id': leaveTypeId,
        'requested_days': requestedDays,
        'description': reason,
      },
    );
  }

  Future<dynamic> requestCorrection({
    required int attendanceId,
    required String clockIn,
    required String clockOut,
    required String reason,
  }) {
    return _client.post(
      '/attendance/attendance-request/$attendanceId',
      data: {
        'attendance_clock_in': clockIn,
        'attendance_clock_out': clockOut,
        'description': reason,
      },
    );
  }

  Future<dynamic> submitShiftRequest({
    required int employeeId,
    required int shiftId,
    required DateTime date,
    required String reason,
  }) {
    return _client.post(
      '/base/shift-requests/',
      data: {
        'employee_id': employeeId,
        'requested_shift_id': shiftId,
        'requested_date': _date(date),
        'description': reason,
      },
    );
  }

  Future<dynamic> submitWorkTypeRequest({
    required int employeeId,
    required int workTypeId,
    required DateTime date,
    required String reason,
  }) {
    return _client.post(
      '/base/worktype-requests/',
      data: {
        'employee_id': employeeId,
        'work_type_id': workTypeId,
        'requested_date': _date(date),
        'description': reason,
      },
    );
  }

  Future<dynamic> submitAssetRequest({
    required int employeeId,
    required int assetCategoryId,
    required String reason,
  }) {
    return _client.post(
      '/asset/asset-requests/',
      data: {
        'employee_id': employeeId,
        'asset_category_id': assetCategoryId,
        'description': reason,
      },
    );
  }

  Future<dynamic> submitReimbursement({
    required int employeeId,
    required double amount,
    required String title,
    required String reason,
  }) {
    return _client.post(
      '/payroll/reimbusement/',
      data: {
        'employee_id': employeeId,
        'amount': amount,
        'title': title,
        'description': reason,
      },
    );
  }

  Future<dynamic> submitHelpdeskTicket({
    required String category,
    required String subject,
    required String description,
  }) {
    return _client.post(
      '/helpdesk/tickets/',
      data: {
        'category': category,
        'subject': subject,
        'description': description,
      },
    );
  }

  Future<dynamic> uploadFaceReference({
    required int employeeId,
    required String fileName,
  }) {
    return _client.post(
      '/facedetection/reference/',
      data: {'employee_id': employeeId, 'file': fileName},
    );
  }

  Future<dynamic> decideApproval({
    required int id,
    required String kind,
    required bool approve,
  }) {
    final action = approve ? 'approve' : 'reject';
    return switch (kind) {
      'leave' => _client.put('/leave/$action/$id/'),
      'attendance' => _client.put('/attendance/attendance-request-approve/$id'),
      'shift' =>
        approve
            ? _client.put('/base/shift-request-approve/$id')
            : _client.post('/base/shift-request-cancel/$id'),
      'workType' =>
        approve
            ? _client.put('/base/worktype-requests-approve/$id/')
            : _client.put('/base/worktype-requests-cancel/$id/'),
      'expense' => _client.post(
        '/payroll/reimbusement-approve-reject/$id',
        data: {'status': approve ? 'approved' : 'rejected'},
      ),
      _ => throw ArgumentError.value(kind, 'kind', 'Unknown approval kind'),
    };
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static int _workingDays(DateTime start, DateTime end) {
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    var days = 0;
    while (!cursor.isAfter(last)) {
      if (cursor.weekday <= DateTime.friday) {
        days++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return days.clamp(1, 366);
  }
}
