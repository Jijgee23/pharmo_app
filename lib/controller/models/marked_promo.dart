

class MarkedPromo {
  int? id;
  String? name;
  int? code;
  String? desc;
  bool? isActive;
  bool? isMarked;
  int? promoType;
  int? targetType;
  String? startDate;
  String? endDate;
  List<dynamic>? target;
  List<dynamic>? bundles;
  double? bundlePrice;
  double? total;
  bool? isPer;
  bool? isCash;
  bool? hasGift;
  List<dynamic>? gift;
  double? procent;
  String? updatedAt;
  String? createdAt;
  int? supplier;

  MarkedPromo({
     this.id,
    this.name,
    this.code,
    this.desc,
    this.isActive,
    this.isMarked,
    this.promoType,
    this.targetType,
    this.startDate,
    this.endDate,
    this.target,
    this.bundles,
    this.bundlePrice,
    this.total,
    this.isPer,
    this.isCash,
    this.hasGift,
    this.gift,
    this.procent,
    this.updatedAt,
    this.createdAt,
    this.supplier,
  });

  factory MarkedPromo.fromJson(Map<String, dynamic> json) {
    return MarkedPromo(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      desc: json['desc'],
      isActive: json['is_active'],
      isMarked: json['is_marked'],
      promoType: json['promo_type'],
      targetType: json['target_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      target: json['target'],
      bundles: json['bundle'],
      bundlePrice: json['bundle_price'],
      total: json['total'],
      isPer: json['is_per'],
      isCash: json['is_cash'],
      hasGift: json['has_gift'],
      gift: json['gift'],
      procent: json['procent'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      supplier: json['supplier'],
    );
  }
}

class Item {
  int id;
  int? qtyId;
  String? name;
  double? price;
  String? barcode;
  int? qty;

  Item({
    required this.id,
    this.qtyId,
    this.name,
    this.price,
    this.barcode,
    this.qty,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      qtyId: json['qtyId'],
      name: json['name'],
      price: json['price'],
      barcode: json['barcode'],
      qty: json['qty'],
    );
  }
}
