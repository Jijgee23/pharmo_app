class FilteredProduct {
  int id;
  int itemname_id;
  String name;
  double price;
  String? barcode;
  String? intName;
  String? image;

  FilteredProduct({
    required this.id,
    required this.itemname_id,
    required this.name,
    required this.price,
    this.barcode,
    this.intName,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemname_id': itemname_id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'intName': intName,
      'image': image,
    };
  }

  factory FilteredProduct.fromJson(Map<String, dynamic> json) {
    return FilteredProduct(
      id: json['id'],
      itemname_id: json['itemname_id'],
      name: json['name'],
      price: json['price'],
      barcode: json['barcode'],
      intName: json['intName'],
      image: json['image'],
    );
  }
}
