import 'dart:math';
 
class Customer {
  int id;
  CustomerDetails customer;
  bool isBad;
  int badCnt;
  double debt;
  double debtLimit;

  Customer({
    required this.id,
    required this.customer,
    required this.isBad,
    required this.badCnt,
    required this.debt,
    required this.debtLimit,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customer: CustomerDetails.fromJson(json['customer']),
      isBad: json['isBad'],
      badCnt: json['badCnt'],
      debt: json['debt'].toDouble(),
      debtLimit: json['debtLimit'].toDouble(),
    );
  }
}

class CustomerDetails {
  int id;
  String name;
  String rd;
  String? email;
  String? phone;

  CustomerDetails({
    required this.id,
    required this.name,
    required this.rd,
    this.email,
    this.phone,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: json['id'],
      name: json['name'],
      rd: json['rd'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
class NearestCustomer {
  final double lat;
  final double lon;

  NearestCustomer({required this.lat, required this.lon});
  factory NearestCustomer.fromJson(Map<String, dynamic> json) {
    return NearestCustomer(
      lat: json['lat'],
      lon: json['lon'],
    );
  }
  // Calculate distance between two points using Haversine formula
  double distanceTo(double otherLat, double otherLon) {
    const double earthRadius = 6371.0; 

    final double lat1Rad = lat * (pi / 180.0);
    final double lon1Rad = lon * (pi / 180.0);
    final double lat2Rad = otherLat * (pi / 180.0);
    final double lon2Rad = otherLon * (pi / 180.0);

    final double dLon = lon2Rad - lon1Rad;
    final double dLat = lat2Rad - lat1Rad;

    final double a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}
