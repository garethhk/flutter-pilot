// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Menu', json, ($checkedConvert) {
      final val = Menu(
        id: $checkedConvert('id', (v) => v as String? ?? ''),
        groupName: $checkedConvert('groupName', (v) => v as String? ?? ''),
        name: $checkedConvert('name', (v) => v as String? ?? ''),
        router: $checkedConvert('router', (v) => v as String? ?? ''),
        url: $checkedConvert('url', (v) => v as String? ?? ''),
        html: $checkedConvert('html', (v) => v as String? ?? ''),
        image: $checkedConvert('image', (v) => v as String? ?? ''),
        description: $checkedConvert('description', (v) => v as String? ?? ''),
        version: $checkedConvert('version', (v) => (v as num?)?.toInt() ?? 0),
        order: $checkedConvert('order', (v) => (v as num?)?.toInt() ?? 0),
        group: $checkedConvert('group', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
  'id': instance.id,
  'groupName': instance.groupName,
  'name': instance.name,
  'router': instance.router,
  'url': instance.url,
  'html': instance.html,
  'image': instance.image,
  'description': instance.description,
  'version': instance.version,
  'order': instance.order,
  'group': instance.group,
};
