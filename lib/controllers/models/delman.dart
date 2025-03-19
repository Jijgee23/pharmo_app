class Delman {
  int id;
  String name;
  Delman({
    required this.id,
    required this.name,
  });
  factory Delman.fromJson(Map<String, dynamic> json) {
    return Delman(
      id: json['id'],
      name: json['name'],
    );
  }
}
