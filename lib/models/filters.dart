class Filters {
  int id;
  String name;
  String? parent;
  List<dynamic> children;
  Filters(this.id, this.name, this.parent, this.children);
  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      json['id'],
      json['name'],
      json['parent'],
      json['children']
    );
  }
}
class Manufacturer{
  int id;
  String name;
  int? cnt;
  Manufacturer(this.id, this.name, this.cnt);
  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      json['id'],
      json['name'],
      json['cnt']
    );
  }
}

