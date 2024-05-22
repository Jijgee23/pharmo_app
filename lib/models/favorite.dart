class Favorite {
  int id;
  String name;
  int itemNameId;
  int orders;
  int avgQty;

  Favorite({
    required this.id,
    required this.name,
    required this.itemNameId,
    required this.orders,
    required this.avgQty,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      itemNameId: json['itemname_id'],
      orders: json['orders'],
      avgQty: json['avgQty'],
    );
  }
}
