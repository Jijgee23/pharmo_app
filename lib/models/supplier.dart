class Supplier {
  String id;
  String name;

  Supplier(
    this.id,
    this.name,
  );
  Supplier.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
