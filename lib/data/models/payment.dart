import 'package:pharmo_app/application/function/utilities/a_utils.dart';

class Cust {
  final int id;
  final String? name;
  final String? rn;

  Cust({required this.id, required this.name, required this.rn});

  factory Cust.fromJson(Map<String, dynamic> json) {
    return Cust(
      id: json['id'],
      name: json['name'].toString(),
      rn: json['rn'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rn': rn,
    };
  }
}

//
class Receiver {
  final int id;
  final String name;

  Receiver({required this.id, required this.name});

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
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
}

class Payment {
  final Cust cust;
  final int paymentId;
  final double amount;
  final String payType;
  final Receiver receiver;
  final DateTime paidOn;

  Payment({
    required this.cust,
    required this.paymentId,
    required this.amount,
    required this.payType,
    required this.receiver,
    required this.paidOn,
  });

  PayType get paymentType => PayType.fromValue(payType);

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      cust: Cust.fromJson(json['customer']),
      paymentId: json['payment_id'],
      amount: json['amount'].toDouble(),
      payType: json['pay_type'],
      receiver: Receiver.fromJson(json['receiver']),
      paidOn: DateTime.parse(json['paid_on']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Cust': cust.toJson(),
      'payment_id': paymentId,
      'amount': amount,
      'pay_type': payType,
      'receiver': receiver.toJson(),
      'paid_on': paidOn.toIso8601String(),
    };
  }
}
