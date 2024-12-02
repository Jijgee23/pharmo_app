class Product {
  int id;
  String? expDate;
  String? discountExpireddate;
  String? name;
  double? price;
  int? itemnameId;
  String? barcode;
  String? salePrice;
  int? saleQty;
  double? discount;
  int? inStock;
  String? intName;
  String? description;
  String? createdAt;
  String? modifiedAt;
  String? mohs;
  int? supplier;
  Map<String, dynamic>? mnfr;
  Map<String, dynamic>? vndr;
  List<dynamic>? category;
  List<dynamic>? images;
  String? image;


  Product(
    this.id,
    this.expDate,
    this.discountExpireddate,
    this.name,
    this.price,
    this.itemnameId,
    this.barcode,
    this.salePrice,
    this.saleQty,
    this.discount,
    this.inStock,
    this.intName,
    this.description,
    this.createdAt,
    this.modifiedAt,
    this.mohs,
    this.supplier,
    this.mnfr,
    this.vndr,
    this.category,
    this.images,
    this.image
  );

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        expDate = json['expDate'].toString(),
        discountExpireddate = json['discount_expireddate'].toString(),
        name = json['name'],
        price = json['price'],
        itemnameId = json['itemname_id'],
        barcode = json['barcode'],
        salePrice = json['sale_price'],
        saleQty = json['sale_qty'],
        discount = json['discount'],
        inStock = json['in_stock'],
        intName = json['intName'],
        description = json['description'],
        createdAt = json['created_at'],
        modifiedAt = json['modified_at'],
        mohs = json['mohs'],
        supplier = json['supplier'],
        mnfr = json['mnfr'],
        vndr = json['vndr'],
        images = json['images'],
        image = json['image'],
        category = json['category'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expDate': expDate,
      'discount_expireddate': discountExpireddate,
      'name': name,
      'price': price,
      'itemname_id': itemnameId,
      'barcode': barcode,
      'sale_price': salePrice,
      'sale_qty': saleQty,
      'discount': discount,
      'in_stock': inStock,
      'intName': intName,
      'description': description,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'mohs': mohs,
      'supplier': supplier,
      'mnfr': mnfr,
      'vndr': vndr,
      'images': images,
      'image': image,
      'category': category
    };
  }
}
