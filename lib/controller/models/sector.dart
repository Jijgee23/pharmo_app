class Sector {
  int id;
  Map<String, dynamic>? address;
  String? name;
  String? phone;
  Map<String, dynamic>? manager;
  bool? isMain;
  String? cmpName;
  String? cmpRd;
  int? mgrPk;

  Sector(
    this.id,
    this.address,
    this.phone,
    this.name,
    this.manager,
    this.isMain,
    this.cmpName,
    this.cmpRd,
    this.mgrPk,
  );

  Sector.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        address = json['address'],
        phone = json['phone'],
        name = json['name'],
        manager = json['manager'],
        isMain = json['isMain'],
        cmpName = json['cmpName'],
        cmpRd = json['cmpRd'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'phone': phone,
      'name': name,
      'manager': manager,
      'isMain': isMain,
      'cmpName': cmpName,
      'cmpRd': cmpRd,
    };
  }
}
