class Pharm {
  int id;
  String name;
  Pharm(
    this.id,
    this.name,
  );
}

class Pharmo {
  String cName;
  String cRd;
  String email;
  String phone;
  Address address;
  Pharmo(
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
