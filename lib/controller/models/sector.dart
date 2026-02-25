import 'package:pharmo_app/application/function/utilities/utils.dart';

class Sector {
  int id;
  String name;
  String? phone, phone2, phone3, email, note;
  BranchManager? manager;
  bool isMain;
  double? latitude, longitude;
  Cmp cmp;

  Sector(
    this.id,
    this.name,
    this.phone,
    this.phone2,
    this.phone3,
    this.email,
    this.manager,
    this.isMain,
    this.note,
    this.latitude,
    this.longitude,
    this.cmp,
  );

  Sector.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '?',
        phone = json['phone'],
        phone2 = json['phone2'],
        phone3 = json['phone3'],
        email = json['email'],
        note = json['note'],
        latitude = json['lat'],
        longitude = json['lng'],
        manager = BranchManager.fromJson(json['manager']),
        isMain = json['isMain'],
        cmp = Cmp.fromJson(json['cmp']);
}

class Cmp {
  int id;
  String name;
  Cmp(this.id, this.name);
  factory Cmp.fromJson(Map<String, dynamic> json) {
    return Cmp(parseInt(json['id']), json['name'] ?? '?');
  }
}

class BranchManager {
  int id;
  String? name, lastname, email, rd, phone;
  String role;

  BranchManager({
    required this.id,
    this.name,
    this.lastname,
    this.email,
    this.phone,
    this.rd,
    required this.role,
  });

  factory BranchManager.fromJson(Map<String, dynamic> json) {
    return BranchManager(
      id: parseInt(json['id']),
      role: json['role'],
      name: json['name'],
      lastname: json['last_name'],
      email: json['email'],
      rd: json['rd'],
      phone: json['phone'],
    );
  }
}
