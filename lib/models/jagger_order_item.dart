class JaggerOrderItem {
  int itemId;
  String? itemName;
  String? itemPrice;
  String? itemTotalPrice;
  int itemQty;
  int iQty;
  int? rQty;
  int? itemNameId;
  bool? isPromoItem;
  bool? isPromoGift;
  int? giftCount;
  int? order;
  int? product;
  JaggerOrderItem(
    this.itemId,
    this.itemName,
    this.itemPrice,
    this.itemTotalPrice,
    this.itemQty,
    this.iQty,
    this.rQty,
    this.itemNameId,
    this.isPromoItem,
    this.isPromoGift,
    this.giftCount,
    this.order,
    this.product,
  );

  JaggerOrderItem.fromJson(Map<String, dynamic> json)
      : itemId = json['itemId'],
        itemName = json['itemName'],
        itemPrice = json['itemPrice'],
        itemTotalPrice = json['itemTotalPrice'],
        itemQty = json['itemQty'],
        iQty = json['iQty'],
        rQty = json['rQty'],
        itemNameId = json['itemname_id'],
        isPromoItem = json['is_promo_item'],
        isPromoGift = json['is_promo_gift'],
        giftCount = json['gift_cnt'],
        order = json['order'],
        product = json['product'];


  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemTotalPrice': itemTotalPrice,
      'itemQty': itemQty,
      'iQty': iQty,
      'rQty': rQty,
      'itemname_id': itemNameId,
      'is_promo_item': isPromoItem,
      'is_promo_gift': isPromoGift,
      'gift_cnt': giftCount,
      'order': order,
      'product': product,
    };
  }
}
