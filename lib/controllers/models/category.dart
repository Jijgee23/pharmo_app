class Category {
  int id;
  String name;
  int? parent;
  List<Category>? children;
  Category(this.id, this.name, this.parent, this.children);
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['id'],
      json['name'],
      json['parent'],
      (json['children'] as List).map((e) => Category.fromJson(e)).toList(),
    );
  }
}

class Manufacturer {
  int id;
  String name;
  int? cnt;
  Manufacturer(this.id, this.name, this.cnt);
  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      json['id'],
      json['name'],
      json['cnt'],
    );
  }
}
