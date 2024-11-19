class Manufacturer {
  final int id;
  final String name;

  Manufacturer({required this.id, required this.name});

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Vendor {
  final int id;
  final String name;

  Vendor({required this.id, required this.name});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Image {
  final String url;
  final String name;

  Image({required this.url, required this.name});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      url: json['url'],
      name: json['name'],
    );
  }
}

class ProductDetails {
  final int id;
  final String? expDate;
  final String? discountExpireDate;
  final String? name;
  final double? price;
  final int? itemnameId;
  final String? barcode;
  final double? salePrice;
  final int? saleQty;
  final double? discount;
  final int? inStock;
  final String? intName;
  final Manufacturer? mnfr;
  final Vendor? vndr;
  final List<int>? category;
  final List<Image>? images;
  final int? masterBoxQty;

  ProductDetails(
     {
    required this.id,
    this.expDate,
    this.discountExpireDate,
    this.name,
    this.price,
    this.itemnameId,
    this.barcode,
    this.salePrice,
    this.saleQty,
    this.discount,
    this.inStock,
    this.intName,
    this.mnfr,
    this.vndr,
    this.category,
    this.masterBoxQty,
    this.images,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    var categoryFromJson = json['category'];
    List<int> categoryList = List<int>.from(categoryFromJson);

    var imagesFromJson = json['images'] as List;
    List<Image> imagesList =
        imagesFromJson.map((i) => Image.fromJson(i)).toList();

    return ProductDetails(
      id: json['id'],
      expDate: json['expDate'],
      discountExpireDate: json['discount_expiredate'],
      name: json['name'],
      price: json['price'],
      itemnameId: json['itemname_id'],
      barcode: json['barcode'],
      salePrice: json['sale_price'],
      saleQty: json['sale_qty'],
      discount: json['discount'],
      inStock: json['in_stock'],
      masterBoxQty: json['master_box_qty'],
      intName: json['intName'],
      mnfr: Manufacturer.fromJson(json['mnfr']),
      vndr: Vendor.fromJson(json['vndr']),
      category: categoryList,
      images: imagesList,
    );
  }
}
