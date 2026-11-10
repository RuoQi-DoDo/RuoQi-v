// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationSummary _$ConversationSummaryFromJson(Map<String, dynamic> json) =>
    ConversationSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      updatedAt: json['updatedAt'] as String,
      unread: (json['unread'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationSummaryToJson(
  ConversationSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'preview': instance.preview,
  'updatedAt': instance.updatedAt,
  'unread': instance.unread,
};
