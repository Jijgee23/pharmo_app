class RegisterPharm {
  final String cName;
  final int cRd;
  final String email;
  final int phone;
  final Address address;

  RegisterPharm({
    required this.cName,
    required this.cRd,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory RegisterPharm.fromJson(Map<String, dynamic> json) {
    return RegisterPharm(
      cName: json['cName'],
      cRd: json['cRd'],
      email: json['email'],
      phone: json['phone'],
      address: Address.fromJson(json['address']),
    );
  }
}

class Address {
  final int province;
  final int district;
  final int khoroo;
  final String detailed;

  Address({
    required this.province,
    required this.district,
    required this.khoroo,
    required this.detailed,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      province: json['province'],
      district: json['district'],
      khoroo: json['khoroo'],
      detailed: json['detailed'],
    );
  }
}
