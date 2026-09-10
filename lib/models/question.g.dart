// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Question',
  json,
  ($checkedConvert) {
    final val = Question(
      key: $checkedConvert('key', (v) => v as String? ?? ''),
      link: $checkedConvert('link', (v) => v as String? ?? ''),
      zhihuLink: $checkedConvert('zhihuLink', (v) => v as String? ?? ''),
      parentLink: $checkedConvert('parentLink', (v) => v as String? ?? ''),
      tag: $checkedConvert('tag', (v) => v as String? ?? ''),
      imageRecords: $checkedConvert('imageRecords', (v) => v as String? ?? ''),
      total: $checkedConvert('total', (v) => (v as num?)?.toInt() ?? 0),
    );
    return val;
  },
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'key': instance.key,
  'link': instance.link,
  'zhihuLink': instance.zhihuLink,
  'parentLink': instance.parentLink,
  'tag': instance.tag,
  'imageRecords': instance.imageRecords,
  'total': instance.total,
};
