class Partner {
  final int id;
  final PartnerInfo partner;
  final bool isBad;
  final int badCnt;
  final double debt;
  final double debtLimit;

  Partner({
    required this.id,
    required this.partner,
    required this.isBad,
    required this.badCnt,
    required this.debt,
    required this.debtLimit,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      partner: PartnerInfo.fromJson(json['partner']),
      isBad: json['isBad'],
      badCnt: json['badCnt'],
      debt: json['debt'],
      debtLimit: json['debtLimit'],
    );
  }
}

class PartnerInfo {
  final String name;
  final String rd;
  final String email;
  final String phone;

  PartnerInfo({
    required this.name,
    required this.rd,
    required this.email,
    required this.phone,
  });

  factory PartnerInfo.fromJson(Map<String, dynamic> json) {
    return PartnerInfo(
      name: json['name'],
      rd: json['rd'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
