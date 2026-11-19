import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/ai/chat_history_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('聊天历史可持久化、重命名、置顶和删除', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesChatHistoryStore();
    final now = DateTime.now();
    final first = ChatConversation(
      id: 'conversation-1',
      title: '第一条对话',
      createdAt: now,
      updatedAt: now,
      messages: const [
        ChatHistoryMessage(role: 'user', content: '你好'),
        ChatHistoryMessage(
          role: 'assistant',
          content: '你好，有什么可以帮你？',
          webSearch: true,
        ),
      ],
    );
    final second = ChatConversation(
      id: 'conversation-2',
      title: '第二条对话',
      createdAt: now.subtract(const Duration(minutes: 1)),
      updatedAt: now.subtract(const Duration(minutes: 1)),
      messages: const [ChatHistoryMessage(role: 'user', content: '第二条')],
    );

    await store.saveConversation(first);
    await store.saveConversation(second);
    var conversations = await store.loadConversations();
    expect(conversations.map((item) => item.id), [
      'conversation-1',
      'conversation-2',
    ]);

    await store.renameConversation('conversation-2', '重命名后的对话');
    await store.setPinned('conversation-2', true);
    conversations = await store.loadConversations();
    expect(conversations.first.id, 'conversation-2');
    expect(conversations.first.title, '重命名后的对话');
    expect(conversations.first.pinned, isTrue);

    final restored = await store.getConversation('conversation-1');
    expect(restored?.messages, hasLength(2));
    expect(restored?.messages.last.webSearch, isTrue);

    await store.deleteConversation('conversation-1');
    conversations = await store.loadConversations();
    expect(conversations.map((item) => item.id), ['conversation-2']);
  });
}
