import 'package:network/network.dart';

import 'models/ats_job_summary.dart';

/// 企业直聘 ATS API 客户端。
class AtsApi {
  const AtsApi(this._client);

  final RuoQiNetworkClient _client;

  Future<List<AtsJobSummary>> fetchJobs() async {
    final data = await _client.get('/ats/jobs');
    return (data as List<dynamic>)
        .map((item) => AtsJobSummary.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
