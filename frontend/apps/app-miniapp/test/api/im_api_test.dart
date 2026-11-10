import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/api/im/models/conversation_summary.dart';

void main() {
  test('ConversationSummary roundtrip', () {
    const summary = ConversationSummary(
      id: 'conversation-1',
      title: '招聘交流群',
      preview: '明天下午进行面试',
      updatedAt: '2026-11-10T09:30:00+08:00',
      unread: 2,
    );

    final parsed = ConversationSummary.fromJson(summary.toJson());
    expect(parsed.title, '招聘交流群');
    expect(parsed.unread, 2);
  });
}
