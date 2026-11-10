import 'package:json_annotation/json_annotation.dart';

part 'conversation_summary.g.dart';

@JsonSerializable()
class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.unread,
  });

  final String id;
  final String title;
  final String preview;
  final String updatedAt;
  final int unread;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSummaryToJson(this);
}
