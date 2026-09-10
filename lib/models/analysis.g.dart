// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analysis _$AnalysisFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Analysis',
  json,
  ($checkedConvert) {
    final val = Analysis(
      description: $checkedConvert('description', (v) => v as String? ?? ''),
      generateTime: $checkedConvert('generateTime', (v) => v as String? ?? ''),
      resultList: $checkedConvert(
        'resultList',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            const [],
      ),
      items: $checkedConvert(
        'items',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            const [],
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$AnalysisToJson(Analysis instance) => <String, dynamic>{
  'description': instance.description,
  'generateTime': instance.generateTime,
  'resultList': instance.resultList,
  'items': instance.items,
};
