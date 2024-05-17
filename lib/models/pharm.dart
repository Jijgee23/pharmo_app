class Pharm {
  int id;
  String name;
  bool isCustomer;
  int? badCnt;
  Pharm(
    this.id,
    this.name,
    this.isCustomer,
    this.badCnt,
  );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCustomer': isCustomer,
      'badCnt': badCnt,
    };
  }

  factory Pharm.fromJson(Map<String, dynamic> json) {
    return Pharm(
      json['id'],
      json['name'],
      json['isCustomer'],
      json['badCnt'],
    );
  }
}

