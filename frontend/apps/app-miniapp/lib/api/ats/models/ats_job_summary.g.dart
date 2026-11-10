// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ats_job_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtsJobSummary _$AtsJobSummaryFromJson(Map<String, dynamic> json) =>
    AtsJobSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String,
      city: json['city'] as String,
      salary: json['salary'] as String,
    );

Map<String, dynamic> _$AtsJobSummaryToJson(AtsJobSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'companyName': instance.companyName,
      'city': instance.city,
      'salary': instance.salary,
    };
