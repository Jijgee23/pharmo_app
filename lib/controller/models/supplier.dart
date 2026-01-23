import 'package:pharmo_app/application/function/utilities/utils.dart';

class Supplier {
  final int id;
  final String name;
  final String? logo;
  final List<Stock> stocks;

  Supplier({
    required this.id,
    required this.name,
    this.logo,
    required this.stocks,
  });
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: parseInt(json['id']),
      name: json['name'],
      logo: json['logo'],
      stocks: (json['stocks'] as List)
          .map((stock) => Stock.fromJson(stock))
          .toList(),
    );
  }
}

class Stock {
  final int id;
  final String name;
  Stock({required this.id, required this.name});
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(id: parseInt(json['id']), name: json['name']);
  }
}
