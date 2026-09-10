import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable(checked: true)
class Question {
  String key;
  String link;
  String zhihuLink;
  String parentLink;
  String tag;
  String imageRecords;
  int total;

  Question({
    this.key = '',
    this.link = '',
    this.zhihuLink = '',
    this.parentLink = '',
    this.tag = '',
    this.imageRecords = '',
    this.total = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
