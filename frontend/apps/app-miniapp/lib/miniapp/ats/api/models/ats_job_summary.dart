import 'package:json_annotation/json_annotation.dart';

part 'ats_job_summary.g.dart';

@JsonSerializable()
class AtsJobSummary {
  const AtsJobSummary({
    required this.id,
    required this.title,
    required this.companyName,
    required this.city,
    required this.salary,
  });

  final String id;
  final String title;
  final String companyName;
  final String city;
  final String salary;

  factory AtsJobSummary.fromJson(Map<String, dynamic> json) =>
      _$AtsJobSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AtsJobSummaryToJson(this);
}
