class Income {
  final int id;
  final String? note;
  final double amount;
  final DateTime createdOn;
  final int delman;
  final int? customer;
  final int supplier;

  Income({
    required this.id,
    this.note,
    required this.amount,
    required this.createdOn,
    required this.delman,
    this.customer,
    required this.supplier,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      note: json['note'],
      amount: json['amount']?.toDouble() ?? 0.0,
      createdOn: DateTime.parse(json['createdOn']),
      delman: json['delman'],
      customer: json['customer'],
      supplier: json['supplier'],
    );
  }
}
