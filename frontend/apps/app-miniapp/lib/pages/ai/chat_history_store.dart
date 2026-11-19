import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryMessage {
  const ChatHistoryMessage({
    required this.role,
    required this.content,
    this.deepThinking = false,
    this.webSearch = false,
    this.feedback = 0,
  });

  final String role;
  final String content;
  final bool deepThinking;
  final bool webSearch;
  final int feedback;

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'deepThinking': deepThinking,
    'webSearch': webSearch,
    'feedback': feedback,
  };

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatHistoryMessage(
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      deepThinking: json['deepThinking'] as bool? ?? false,
      webSearch: json['webSearch'] as bool? ?? false,
      feedback: json['feedback'] as int? ?? 0,
    );
  }
}

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.pinned = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatHistoryMessage> messages;
  final bool pinned;

  ChatConversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatHistoryMessage>? messages,
    bool? pinned,
  }) {
    return ChatConversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((message) => message.toJson()).toList(),
    'pinned': pinned,
  };

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'];
    return ChatConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      messages: messages is List
          ? messages
                .whereType<Map>()
                .map(
                  (item) =>
                      ChatHistoryMessage.fromJson(item.cast<String, dynamic>()),
                )
                .toList(growable: false)
          : const [],
      pinned: json['pinned'] as bool? ?? false,
    );
  }
}

abstract interface class ChatHistoryStore {
  Future<List<ChatConversation>> loadConversations();

  Future<ChatConversation?> getConversation(String id);

  Future<void> saveConversation(ChatConversation conversation);

  Future<void> renameConversation(String id, String title);

  Future<void> setPinned(String id, bool pinned);

  Future<void> deleteConversation(String id);
}

class SharedPreferencesChatHistoryStore implements ChatHistoryStore {
  const SharedPreferencesChatHistoryStore();

  static const _storageKey = 'deepseek_chat_history_v1';

  @override
  Future<List<ChatConversation>> loadConversations() async {
    final conversations = await _readAll();
    conversations.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return conversations;
  }

  @override
  Future<ChatConversation?> getConversation(String id) async {
    final conversations = await _readAll();
    for (final conversation in conversations) {
      if (conversation.id == id) {
        return conversation;
      }
    }
    return null;
  }

  @override
  Future<void> saveConversation(ChatConversation conversation) async {
    final conversations = await _readAll();
    final index = conversations.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }
    await _writeAll(conversations);
  }

  @override
  Future<void> renameConversation(String id, String title) async {
    final conversations = await _readAll();
    final index = conversations.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    conversations[index] = conversations[index].copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
    await _writeAll(conversations);
  }

  @override
  Future<void> setPinned(String id, bool pinned) async {
    final conversations = await _readAll();
    final index = conversations.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    conversations[index] = conversations[index].copyWith(pinned: pinned);
    await _writeAll(conversations);
  }

  @override
  Future<void> deleteConversation(String id) async {
    final conversations = await _readAll();
    conversations.removeWhere((item) => item.id == id);
    await _writeAll(conversations);
  }

  Future<List<ChatConversation>> _readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map>()
          .map(
            (item) => ChatConversation.fromJson(item.cast<String, dynamic>()),
          )
          .where((conversation) => conversation.id.isNotEmpty)
          .toList(growable: true);
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<ChatConversation> conversations) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(
        conversations.map((conversation) => conversation.toJson()).toList(),
      ),
    );
  }
}
