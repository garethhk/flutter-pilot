import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable(checked: true)
class Menu {
  final String id;
  final String groupName;
  final String name;
  final String router;
  final String url;
  final String html;
  final String image;
  final String description;
  final int version;
  final int order;
  final int group;

  Menu({
    this.id = '',
    this.groupName = '',
    this.name = '',
    this.router = '',
    this.url = '',
    this.html = '',
    this.image = '',
    this.description = '',
    this.version = 0,
    this.order = 0,
    this.group = 0,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
