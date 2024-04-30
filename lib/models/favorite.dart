class Favorite {
  int id;
  String name;
  int orders;
  int avgQty;

  Favorite({
    required this.id,
    required this.name,
    required this.orders,
    required this.avgQty,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      orders: json['orders'],
      avgQty: json['avgQty'],
    );
  }
}
