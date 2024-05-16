
class OrderQRCode {
  String? totalPrice;
  String? totalCount;
  String? qrTxt;
  List<dynamic>? urls;

  OrderQRCode(
    this.qrTxt,
    this.totalPrice,
    this.totalCount,
    this.urls,
  );

  OrderQRCode.fromJson(Map<String, dynamic> json)
      : totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        urls = json['urls'],
        qrTxt = json['qrTxt'];

  Map<String, dynamic> toJson() {
    return {
      'qrTxt': qrTxt,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'urls': urls,
    };
  }
}
