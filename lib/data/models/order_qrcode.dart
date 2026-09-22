import 'package:pharmo_app/application/app_lite.dart';

class OrderQRCode {
  final String invId;
  final double totalPrice;
  final double? totalCount;
  final String? qrTxt;
  final List<BankUrl>? urls;

  OrderQRCode({
    required this.invId,
    required this.qrTxt,
    required this.totalPrice,
    required this.totalCount,
    required this.urls,
  });

  factory OrderQRCode.fromJson(Map<String, dynamic> json) {
    return OrderQRCode(
      invId: json['invId'] ?? "",
      qrTxt: json['qrTxt'] ?? '',
      totalPrice: parseDouble(json['totalPrice']),
      totalCount: parseDouble(json['totalCount']),
      urls: json['urls'] != null
          ? (json['urls'] as List).map((url) => BankUrl.fromJson(url)).toList()
          : [],
    );
  }

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

class BankUrl {
  final String name;
  final String description;
  final String logo;
  final String link;
  const BankUrl({
    required this.name,
    required this.description,
    required this.logo,
    required this.link,
  });

  factory BankUrl.fromJson(Map<String, dynamic> json) {
    return BankUrl(
      name: json['name'] ?? "",
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      link: json['link'] ?? '',
    );
  }
}
