import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/api/ats/models/ats_job_summary.dart';

void main() {
  test('AtsJobSummary roundtrip', () {
    const job = AtsJobSummary(
      id: 'job-1',
      title: 'Flutter 工程师',
      companyName: 'RuoQi',
      city: '深圳',
      salary: '20-35K',
    );

    final parsed = AtsJobSummary.fromJson(job.toJson());
    expect(parsed.title, 'Flutter 工程师');
    expect(parsed.city, '深圳');
  });
}
