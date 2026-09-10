import 'package:json_annotation/json_annotation.dart';

part 'analysis.g.dart';

@JsonSerializable(checked: true)
class Analysis {
  String description;
  String generateTime;
  List<Map<String, dynamic>> resultList;
  List<Map<String, dynamic>> items;

  Analysis({
    this.description = '',
    this.generateTime = '',
    this.resultList = const [],
    this.items = const [],
  });

  factory Analysis.fromJson(Map<String, dynamic> json) =>
      _$AnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AnalysisToJson(this);
}
