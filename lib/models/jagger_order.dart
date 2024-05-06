import 'package:pharmo_app/models/jagger_order_item.dart';

class JaggerOrder {
  int? id;
  bool? isGiven;
  String? givenOn;
  String? note;
  int? orderNo;
  String? user;
  String? process;
  List<JaggerOrderItem>? jaggerOrderItems;
  List<dynamic>? items;

  JaggerOrder(
    this.id,
    this.isGiven,
    this.givenOn,
    this.note,
    this.orderNo,
    this.user,
    this.process,
    this.items,
  );
  JaggerOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isGiven = json['isGiven'];
    givenOn = json['givenOn'];
    note = json['note'];
    orderNo = json['orderNo'];
    user = json['user'];
    items = json['items'];
    // process = json['process'];
    switch (json['process'].toString()) {
      case 'N':
        process = 'Шинэ';
        break;
      case 'M':
        process = 'Бэлтгэж эхэлсэн';
        break;
      case 'P':
        process = 'Бэлэн болсон';
        break;
      case 'O':
        process = 'Хүргэлтэнд гарсан';
        break;
      default:
        process = 'Хүргэгдсэн';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isGiven': isGiven,
      'givenOn': givenOn,
      'note': note,
      'orderNo': orderNo,
      'user': user,
      'process': process,
      'items': items,
    };
  }
}
