import 'package:flutter/material.dart';

enum LoadState { loading, loaded, error }

enum Api { get, post, patch, delete }

enum AuthState { unknown, loggedIn, notLoggedIn, expired, notSplashed }

enum Role { noUser, seller, driver, orderer, admin, repman }

// enum NetworkStatus { online, offline, hasConnectionButNotInternet }

// enum Tracker { sellerTrack, driverTrack }

enum OrderProcess {
  all("", "Бүгд", '📊', Colors.grey),
  newOrder("N", "Шинэ", '✨', Colors.blue),
  accepted("A", "Хүлээн авсан", '🤝', Colors.indigo),
  packing("T", "Бэлтгэж эхэлсэн", '👨‍🍳', Colors.orange),
  packed("P", "Бэлэн болсон", '📦', Colors.teal),
  onDelivery("O", "Түгээлтэнд гарсан", '🛵', Colors.purple),
  delivered("D", "Хүргэгдсэн", '🏠', Colors.green),
  returned("R", "Буцаагдсан", '🔄', Colors.redAccent),
  closed("C", "Хаалттай", '🔒', Colors.blueGrey),
  unknown("U", "Тодорхойгүй", '❓', Colors.red);

  final String code, name, icon;
  final Color color;

  const OrderProcess(this.code, this.name, this.icon, this.color);

  static OrderProcess fromCode(String code) {
    return OrderProcess.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderProcess.unknown,
    );
  }

  static OrderProcess fromName(String name) {
    return OrderProcess.values.firstWhere(
      (e) => e.name == name,
      orElse: () => OrderProcess.unknown,
    );
  }

  static List<OrderProcess> get filterList =>
      OrderProcess.values.where((e) => e != OrderProcess.unknown).toList();
  static List<OrderProcess> get deliveryProcess => OrderProcess.values
      .where((e) =>
          e == OrderProcess.onDelivery ||
          e == OrderProcess.delivered ||
          e == OrderProcess.returned ||
          e == OrderProcess.closed)
      .toList();
}

enum PayType {
  cash("C", "Бэлнээр", '💰', Colors.green),
  loan("L", "Зээлээр", '📝', Colors.orange),
  transAccount("T", "Дансаар", '💳', Colors.blue),
  unknown("U", "Төлбөрийн хэлбэр", '❓', Colors.grey);

  final String value, name, icon;
  final Color color; // UI-д ашиглах өнгө

  const PayType(this.value, this.name, this.icon, this.color);

  static PayType fromValue(String value) {
    return PayType.values.firstWhere(
      (role) => role.value == value,
      orElse: () => PayType.unknown,
    );
  }

  static PayType fromName(String value) {
    return PayType.values.firstWhere(
      (role) => role.name == value,
      orElse: () => PayType.unknown,
    );
  }

  static List<PayType> get filterList => PayType.values.reversed.toList();
}

List<PayType> paymentMethods = [PayType.cash, PayType.loan, PayType.transAccount];

enum OrderStatus {
  all("", "Бүгд", '📑', Colors.grey),
  waiting("W", "Төлбөр хүлээгдэж буй", '⏳', Colors.orange),
  paid("P", "Төлбөр төлөгдсөн", '💳', Colors.green),
  cancelled("S", "Цуцлагдсан", '🚫', Colors.red),
  completed("C", "Биелсэн", '🏁', Colors.teal),
  unknown("U", "Тодорхойгүй", '❓', Colors.red);

  final String value, name, icon;
  final Color color;

  const OrderStatus(this.value, this.name, this.icon, this.color);

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.unknown,
    );
  }

  static OrderStatus fromName(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.unknown,
    );
  }

  static List<OrderStatus> get filterList =>
      OrderStatus.values.where((e) => e != OrderStatus.unknown).toList();
}
