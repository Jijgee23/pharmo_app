class Branch {
  final int id;
  final String name;
  final String phone;
  final String address;
  final Manager manager;
  Branch(
      {required this.id,
      required this.name,
      required this.phone,
      required this.address,
      required this.manager});
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      manager: Manager.fromJson(json['manager']),
    );
  }
}

class Manager {
  late String name;
  late String phone;
  late String email;

  Manager({required this.name, required this.phone, required this.email});
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}
