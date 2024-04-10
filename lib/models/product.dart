class Product {
  final String name;
  final String barcode;
  final double price;
  final String imageUrl;
  final DateTime endOver;
  final int count;
  final String salePrice;
  final DateTime saleOffTime;
  final String creater;
  final String generalName;
  Product(
    this.endOver,
    this.count,
    this.salePrice,
    this.saleOffTime,
    this.creater,
    this.generalName,
    this.name,
    this.barcode,
    this.price,
    this.imageUrl,
  );
}
