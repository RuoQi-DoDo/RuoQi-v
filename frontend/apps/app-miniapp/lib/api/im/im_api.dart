import 'package:network/network.dart';

import 'models/conversation_summary.dart';

/// IM 域后端 API 客户端。
class ImApi {
  const ImApi(this._client);

  final RuoQiNetworkClient _client;

  Future<List<ConversationSummary>> fetchConversations() async {
    final data = await _client.get('/im/conversations');
    return (data as List<dynamic>)
        .map(
          (item) => ConversationSummary.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}
