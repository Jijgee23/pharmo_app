class OrderQRCode {
  String? invId;
  double? totalPrice;
  int? totalCount;
  String? qrTxt;
  List<dynamic>? urls;

  OrderQRCode(
    this.invId,
    this.qrTxt,
    this.totalPrice,
    this.totalCount,
    this.urls,
  );

  OrderQRCode.fromJson(Map<String, dynamic> json)
      : totalPrice = json['totalPrice'],
        invId = json['invId'],
        totalCount = json['totalCount'],
        urls = json['urls'],
        qrTxt = json['qrTxt'];

  Map<String, dynamic> toJson() {
    return {
      'qrTxt': qrTxt,
      'invId': invId,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'urls': urls,
    };
  }
}
