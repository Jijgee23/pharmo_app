class Partner {
  final int id;
  final PartnerDetails partnerDetails;
  final bool isBad;
  final int badCnt;
  final double debt;
  final double debtLimit;

  Partner({
    required this.id,
    required this.partnerDetails,
    required this.isBad,
    required this.badCnt,
    required this.debt,
    required this.debtLimit,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'],
      partnerDetails: PartnerDetails.fromJson(json['partner']),
      isBad: json['isBad'],
      badCnt: json['badCnt'],
      debt: json['debt'],
      debtLimit: json['debtLimit'],
    );
  }
}

class PartnerDetails {
  final String name;
  final String rd;
  final String? email;
  final String? phone;

  PartnerDetails({
    required this.name,
    required this.rd,
    this.email,
    this.phone,
  });

  factory PartnerDetails.fromJson(Map<String, dynamic> json) {
    return PartnerDetails(
      name: json['name'],
      rd: json['rd'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
