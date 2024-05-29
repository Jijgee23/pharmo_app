class Product {
  int id;
  String? expDate;
  String? discount_expireddate;
  String? name;
  String? price;
  int? itemname_id;
  String? barcode;
  String? sale_price;
  int? sale_qty;
  String? discount;
  int? in_stock;
  String? intName;
  String? description;
  String? created_at;
  String? modified_at;
  String? mohs;
  int? supplier;
  Map<String, dynamic>? mnfr;
  Map<String, dynamic>? vndr;
  List<dynamic>? category;
  List<dynamic>? images;

  Product(
    this.id,
    this.expDate,
    this.discount_expireddate,
    this.name,
    this.price,
    this.itemname_id,
    this.barcode,
    this.sale_price,
    this.sale_qty,
    this.discount,
    this.in_stock,
    this.intName,
    this.description,
    this.created_at,
    this.modified_at,
    this.mohs,
    this.supplier,
    this.mnfr,
    this.vndr,
    this.category,
    this.images,
  );

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        expDate = json['expDate'].toString(),
        discount_expireddate = json['discount_expireddate'].toString(),
        name = json['name'],
        price = json['price'].toString(),
        itemname_id = json['itemname_id'],
        barcode = json['barcode'],
        sale_price = json['sale_price'],
        sale_qty = json['sale_qty'],
        discount = json['discount'].toString(),
        in_stock = json['in_stock'],
        intName = json['intName'],
        description = json['description'],
        created_at = json['created_at'],
        modified_at = json['modified_at'],
        mohs = json['mohs'],
        supplier = json['supplier'],
        mnfr = json['mnfr'],
        vndr = json['vndr'],
        images = json['images'],
        category = json['category'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expDate': expDate,
      'discount_expireddate': discount_expireddate,
      'name': name,
      'price': price,
      'itemname_id': itemname_id,
      'barcode': barcode,
      'sale_price': sale_price,
      'sale_qty': sale_qty,
      'discount': discount,
      'in_stock': in_stock,
      'intName': intName,
      'description': description,
      'created_at': created_at,
      'modified_at': modified_at,
      'mohs': mohs,
      'supplier': supplier,
      'mnfr': mnfr,
      'vndr': vndr,
      'images': images,
    };
  }
}
