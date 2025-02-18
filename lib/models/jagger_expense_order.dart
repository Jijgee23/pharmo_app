class JaggerExpenseOrder {
  int id;
  String? note;
  double? amount;
  String? createdOn;
  int? ship;
  int? delman;

  JaggerExpenseOrder(
    this.id,
    this.note,
    this.amount,
    this.createdOn,
    this.ship,
    this.delman,
  );

  JaggerExpenseOrder.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        note = json['note'],
        amount = json['amount'],
        createdOn = json['createdOn'],
        ship = json['ship'],
        delman = json['delman'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'amount': amount,
      'createdOn': createdOn,
      'ship': ship,
      'delman': delman,
    };
  }
}
