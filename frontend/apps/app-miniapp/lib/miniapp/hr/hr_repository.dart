import 'package:network/network.dart';

import '../../api/hr/hr_api.dart';
import 'hr_mock_data.dart';
import 'hr_models.dart';

/// Page-safe data boundary. The controller talks only to this interface.
abstract interface class HrRepository {
  Future<HrSeedData> loadSnapshot();

  Future<void> punch({required bool clockIn});

  Future<void> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required bool halfDay,
  });

  Future<void> requestLeaveAllocation({
    required String type,
    required double days,
    required String reason,
  });

  Future<void> requestCorrection({
    required DateTime date,
    required String clockIn,
    required String clockOut,
    required String reason,
  });

  Future<void> submitRequest({
    required HrRequestKind kind,
    required String title,
    required String detail,
  });

  Future<void> submitHelpdeskTicket({
    required String category,
    required String subject,
    required String description,
  });

  Future<void> enrollFace();

  Future<void> decideApproval(HrApprovalItem item, {required bool approve});

  Future<void> markNotificationRead(int id);

  Future<void> markAllNotificationsRead();

  Future<void> markAnnouncementRead(int id);
}

class HrMockRepository implements HrRepository {
  const HrMockRepository({this.latency = const Duration(milliseconds: 220)});

  final Duration latency;

  @override
  Future<HrSeedData> loadSnapshot() async {
    await Future<void>.delayed(latency);
    return HrMockData.seed();
  }

  @override
  Future<void> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required bool halfDay,
  }) => _done();

  @override
  Future<void> requestLeaveAllocation({
    required String type,
    required double days,
    required String reason,
  }) => _done();

  @override
  Future<void> decideApproval(HrApprovalItem item, {required bool approve}) =>
      _done();

  @override
  Future<void> markAllNotificationsRead() => _done();

  @override
  Future<void> markAnnouncementRead(int id) => _done();

  @override
  Future<void> markNotificationRead(int id) => _done();

  @override
  Future<void> punch({required bool clockIn}) => _done();

  @override
  Future<void> requestCorrection({
    required DateTime date,
    required String clockIn,
    required String clockOut,
    required String reason,
  }) => _done();

  @override
  Future<void> submitRequest({
    required HrRequestKind kind,
    required String title,
    required String detail,
  }) => _done();

  @override
  Future<void> submitHelpdeskTicket({
    required String category,
    required String subject,
    required String description,
  }) => _done();

  @override
  Future<void> enrollFace() => _done();

  Future<void> _done() => Future<void>.delayed(latency);
}

/// Real Horilla adapter.
///
/// The remote implementation deliberately starts from the same sample shape:
/// older Horilla servers do not expose every endpoint, and a missing optional
/// response should not blank an otherwise usable screen.
class HrRemoteRepository implements HrRepository {
  HrRemoteRepository(this._api);

  final HrApi _api;

  @override
  Future<HrSeedData> loadSnapshot() async {
    final seed = HrMockData.seed();
    final home = await _safeMap(_api.fetchHome);
    if (home == null) {
      return seed;
    }
    final userMap = _map(home['user']);
    final punchMap = _map(home['punch']);
    final name = _text(userMap['full_name']) ?? seed.home.user.name;
    return seed.copyWith(
      home: HrHomeSnapshot(
        user: seed.home.user.copyWith(
          name: name,
          department: _text(userMap['department']) ?? seed.home.user.department,
          position: _text(userMap['job_position']) ?? seed.home.user.position,
        ),
        punch: HrPunchState(
          isClockedIn:
              _bool(punchMap['is_clocked_in']) ?? seed.home.punch.isClockedIn,
          clockInTime:
              _text(punchMap['clock_in']) ?? seed.home.punch.clockInTime,
          clockOutTime:
              _text(punchMap['clock_out']) ?? seed.home.punch.clockOutTime,
          workedSeconds:
              _seconds(
                punchMap['worked_seconds'] ?? home['today']?['worked'],
              ) ??
              seed.home.punch.workedSeconds,
          breakSeconds:
              _seconds(home['today']?['break_time']) ??
              seed.home.punch.breakSeconds,
          overtimeSeconds:
              _seconds(home['today']?['overtime']) ??
              seed.home.punch.overtimeSeconds,
          location: seed.home.punch.location,
          inGeofence: seed.home.punch.inGeofence,
        ),
        pendingApprovals:
            _int(home['pending_approvals']) ?? seed.home.pendingApprovals,
        unreadNotifications:
            _int(home['unread_notifications']) ?? seed.home.unreadNotifications,
        featuredAnnouncementId: seed.home.featuredAnnouncementId,
        onLeaveToday: seed.home.onLeaveToday,
        serverConnected: true,
      ),
    );
  }

  @override
  Future<void> punch({required bool clockIn}) async {
    if (clockIn) {
      await _api.clockIn();
    } else {
      await _api.clockOut();
    }
  }

  @override
  Future<void> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required bool halfDay,
  }) {
    return _api.applyLeave(
      employeeId: 1,
      leaveTypeId: switch (type) {
        '病假' => 2,
        '调休' => 3,
        _ => 1,
      },
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      halfDay: halfDay,
    );
  }

  @override
  Future<void> requestLeaveAllocation({
    required String type,
    required double days,
    required String reason,
  }) {
    return _api.requestLeaveAllocation(
      employeeId: 1,
      leaveTypeId: switch (type) {
        '病假' => 2,
        '调休' => 3,
        _ => 1,
      },
      requestedDays: days,
      reason: reason,
    );
  }

  @override
  Future<void> requestCorrection({
    required DateTime date,
    required String clockIn,
    required String clockOut,
    required String reason,
  }) {
    return _api.requestCorrection(
      attendanceId: _dateNumber(date),
      clockIn: clockIn,
      clockOut: clockOut,
      reason: reason,
    );
  }

  @override
  Future<void> submitRequest({
    required HrRequestKind kind,
    required String title,
    required String detail,
  }) async {
    final now = DateTime.now();
    switch (kind) {
      case HrRequestKind.shift:
        await _api.submitShiftRequest(
          employeeId: 1,
          shiftId: 1,
          date: now,
          reason: '$title · $detail',
        );
      case HrRequestKind.workType:
        await _api.submitWorkTypeRequest(
          employeeId: 1,
          workTypeId: 2,
          date: now,
          reason: '$title · $detail',
        );
      case HrRequestKind.expense:
        await _api.submitReimbursement(
          employeeId: 1,
          amount: 0,
          title: title,
          reason: detail,
        );
      case HrRequestKind.asset:
        await _api.submitAssetRequest(
          employeeId: 1,
          assetCategoryId: 1,
          reason: '$title · $detail',
        );
    }
  }

  @override
  Future<void> submitHelpdeskTicket({
    required String category,
    required String subject,
    required String description,
  }) {
    return _api.submitHelpdeskTicket(
      category: category,
      subject: subject,
      description: description,
    );
  }

  @override
  Future<void> enrollFace() {
    return _api.uploadFaceReference(
      employeeId: 1,
      fileName: 'ruoqi-face-reference.jpg',
    );
  }

  @override
  Future<void> decideApproval(HrApprovalItem item, {required bool approve}) {
    return _api.decideApproval(
      id: item.id,
      kind: item.kind.name,
      approve: approve,
    );
  }

  @override
  Future<void> markAnnouncementRead(int id) => _api.markAnnouncementRead(id);

  @override
  Future<void> markAllNotificationsRead() => _api.markAllNotificationsRead();

  @override
  Future<void> markNotificationRead(int id) => _api.markNotificationRead(id);

  Future<Map<String, dynamic>?> _safeMap(
    Future<dynamic> Function() load,
  ) async {
    try {
      return _map(await load());
    } on RuoQiApiException {
      return null;
    }
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) {
      final data = value['data'];
      return data is Map<String, dynamic> ? data : value;
    }
    if (value is Map) {
      final result = value.map((key, value) => MapEntry('$key', value));
      final data = result['data'];
      return data is Map
          ? data.map((key, value) => MapEntry('$key', value))
          : result;
    }
    return const {};
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty || text == 'null' ? null : text;
  }

  static int? _int(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };

  static bool? _bool(Object? value) => switch (value) {
    bool result => result,
    'true' => true,
    'false' => false,
    _ => null,
  };

  static int? _seconds(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is! String) {
      return null;
    }
    final parts = value.split(':').map(int.tryParse).toList();
    if (parts.any((part) => part == null)) {
      return null;
    }
    return switch (parts.length) {
      2 => parts[0]! * 3600 + parts[1]! * 60,
      3 => parts[0]! * 3600 + parts[1]! * 60 + parts[2]!,
      _ => null,
    };
  }

  static int _dateNumber(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;
}

class HrConfig {
  const HrConfig._();

  /// Defaults to the static preview. A real build can opt in with:
  /// `--dart-define=HR_USE_MOCK_DATA=false`.
  static const useMockData = bool.fromEnvironment(
    'HR_USE_MOCK_DATA',
    defaultValue: true,
  );

  static const apiBaseUrl = String.fromEnvironment(
    'HR_API_BASE_URL',
    defaultValue: 'https://hr.example.com/api/v1',
  );

  static HrRepository repository({bool? mock}) {
    if (mock ?? useMockData) {
      return const HrMockRepository();
    }
    return HrRemoteRepository(HrApi(RuoQiNetworkClient(baseUrl: apiBaseUrl)));
  }
}
