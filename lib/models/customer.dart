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
