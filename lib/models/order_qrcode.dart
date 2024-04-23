
class OrderQRCode {
  String? totalPrice;
  String? totalCount;
  String? qrTxt;

  OrderQRCode(
    this.qrTxt,
    this.totalPrice,
    this.totalCount,
  );

  OrderQRCode.fromJson(Map<String, dynamic> json)
      : totalPrice = json['totalPrice'],
        totalCount = json['totalCount'],
        qrTxt = json['qrTxt'];

  Map<String, dynamic> toJson() {
    return {
      'qrTxt': qrTxt,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
    };
  }
}
