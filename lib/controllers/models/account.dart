class Account {
  final int uid;
  final String email;
  final String? name;
  final String? companyName;
  final int? supplier;
  final String role;
  final int? promoCount;

  Account({
    required this.uid,
    required this.email,
    this.name,
    this.companyName,
    this.supplier,
    required this.role,
    this.promoCount,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['user_id'],
      email: json['email'] as String,
      name: json['name'] as String?,
      companyName: json['company_name'] as String?,
      supplier: json['supplier'] as int?,
      role: json['role'] as String,
      promoCount: json['promos_cnt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': uid,
      'email': email,
      'name': name,
      'company_name': companyName,
      'supplier': supplier,
      'role': role,
      'promos_cnt': promoCount,
    };
  }
}
