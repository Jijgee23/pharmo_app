class Store {
  int id;
  String name;
  String phone;
  String address;
  Manager manager;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.manager,
  });
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      manager: Manager(
        name: json['manager']['name'],
        email: json['manager']['email'],
        phone: json['manager']['phone'],
      ),
    );
  }
}

class Manager {
  String? name;
  String email;
  String phone;

  Manager({
    required this.name,
    required this.email,
    required this.phone,
  });
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
