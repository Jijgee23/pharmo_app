class Province {
  final int id;
  final String name;

  Province({
    required this.id,
    required this.name,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Province{id: $id, name: $name}';
  }
}

class District {
  final int id;
  final String ner;
  final int aimag;
  District({
    required this.id,
    required this.ner,
    required this.aimag,
  });
  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      ner: json['ner'],
      aimag: json['aimag'],
    );
  }
  @override
  String toString() {
    return 'District{id: $id, ner: $ner, aimag: $aimag}';
  }
}

class Khoroo {
  final int id;
  final String ner;
  final int sum;
  final int aimag;
  Khoroo({
    required this.id,
    required this.ner,
    required this.sum,
    required this.aimag,
  });
  factory Khoroo.fromJson(Map<String, dynamic> json) {
    return Khoroo(
      id: json['id'],
      ner: json['ner'],
      sum: json['sum'],
      aimag: json['aimag'],
    );
  }
  @override
  String toString() {
    return 'Khoroo{id: $id, ner: $ner, sum: $sum, aimag: $aimag}';
  }
}

class RegisterPharm {
  String cName;
  String cRd;
  String email;
  String phone;
  Address address;
  RegisterPharm(
    this.cName,
    this.cRd,
    this.email,
    this.phone,
    this.address,
  );
}

class Address {
  String province;
  String district;
  String khoroo;
  String detailed;
  Address(
    this.province,
    this.district,
    this.khoroo,
    this.detailed,
  );
}
