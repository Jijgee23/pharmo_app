import 'package:hive/hive.dart';

part 'security.g.dart';

@HiveType(typeId: 3) // typeId нь давтагдашгүй байх ёстой
class Security extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final int? supplierId;

  @HiveField(5)
  final int? stockId;

  @HiveField(6)
  final int? stocks;

  @HiveField(7)
  final int? customerId;

  @HiveField(8)
  final String companyName;

  @HiveField(9)
  final String access;

  @HiveField(10)
  final String refresh;

  Security({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.supplierId,
    this.stockId,
    this.stocks,
    this.customerId,
    required this.companyName,
    required this.access,
    required this.refresh,
  });

  factory Security.fromJson(
      Map<String, dynamic> json, String access, String refresh) {
    return Security(
      id: json['user_id'],
      name: json['name'].toString(),
      email: json['email'].toString(),
      role: json['role'].toString(),
      supplierId: json['supplier_id'] ?? 0,
      stockId: json['stock_id'] ?? 0,
      stocks: json['stocks'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      companyName: json['company_name'] ?? '',
      access: access,
      refresh: refresh,
    );
  }
}
