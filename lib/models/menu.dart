import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable(checked: true)
class Menu {
  String id;
  String groupName;
  String name;
  String router;
  String url;
  String html;
  String image;
  String description;
  int version;
  int order;
  int group;

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
