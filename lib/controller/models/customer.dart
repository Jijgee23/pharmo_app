class Customer {
  int id;
  String? name;
  String? rn;
  String? phone;
  String? phone2;
  String? phone3;
  String? note;
  bool? location;
  bool? loanBlock;
  int? addedUserId;

  // Constructor
  Customer(
      {this.id = 0,
      this.name,
      this.rn,
      this.phone,
      this.phone2,
      this.phone3,
      this.note,
      this.location,
      this.loanBlock,
      this.addedUserId});

  // Factory method to create a `Customer` instance from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      rn: json['rn'],
      phone: json['phone'].toString(),
      phone2: json['phone2'].toString(),
      phone3: json['phone3'].toString(),
      note: json['note'].toString(),
      addedUserId: json['added_by_id'],
      location: json['location'],
      loanBlock: json['loanBlock'],
    );
  }

  // Method to convert a `Customer` instance to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rn': rn,
      'phone': phone,
      'phone2': phone2,
      'phone3': phone3,
      'note': note,
      'location': location,
      'loanBlock': loanBlock
    };
  }
}
