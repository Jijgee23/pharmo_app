import 'package:flutter/material.dart';
import 'package:pharmo_app/views/cart/order_done.dart';
import 'package:pharmo_app/views/cart/qr_code.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmo_app/controller/models/a_models.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class BasketProvider extends ChangeNotifier {
  final TextEditingController qty = TextEditingController();
  void setQTYvalue(String n) {
    qty.text = n;
    notifyListeners();
  }

  void write(String n) {
    qty.text = qty.text + n;
    notifyListeners();
  }

  void clear() {
    print(qty.text.length);
    if (qty.text.isEmpty || qty.text == '') {
      qty.text = '1';
    } else {
      qty.text = qty.text.substring(0, qty.text.length - 1);
    }
    notifyListeners();
  }

  int _count = 0;
  int get count => _count;
  String? userrole = '';
  Basket? basket;
  // Basket get basket => _basket;
  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];
  List<QTY> qtys = [];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;
  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userrole');
    userrole = userRole;
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  getBasket() async {
    try {
      final resBasket = await api(Api.get, 'get_basket/');
      if (resBasket!.statusCode == 200) {
        final res = convertData(resBasket);
        basket = Basket.fromJson(res);
        _count = basket!.items != null && basket!.items!.isNotEmpty
            ? basket!.items!.length
            : 0;
        _shoppingCarts = basket!.items!;
        notifyListeners();
      } else {
        return buildResponse(1, '', 'Сагсны мэдээлэл татахад алдаа гарлаа!');
      }
      notifyListeners();
    } catch (e) {
      //
    }
  }

  Future<dynamic> checkQTYs() async {
    try {
      Map<String, int?> bodyStr = {};
      if (_shoppingCarts.isNotEmpty) {
        for (int i = 0; i < _shoppingCarts.length; i++) {
          if (shoppingCarts[i]["product_itemname_id"] != null &&
              shoppingCarts[i]["product_itemname_id"] > 0) {
            bodyStr['${shoppingCarts[i]["product_itemname_id"]}'] =
                shoppingCarts[i]["qty"];
          } else {
            bodyStr['${shoppingCarts[i]["product_id"]}'] =
                shoppingCarts[i]["qty"];
          }
        }
        final response =
            await api(Api.patch, 'check_qty/', body: {"data": bodyStr});
        if (response!.statusCode == 200) {
          Map res = convertData(response);
          qtys.clear();
          res.forEach((k, v) {
            if (v == false) {
              qtys.add(QTY(k, v));
            }
          });
          if (qtys.isNotEmpty) {
            return buildResponse(
                0, null, 'Барааны үлдэгдэл хүрэлцэхгүй байна!');
          } else {
            return buildResponse(1, res, '');
          }
        }
      }
    } catch (e) {
      return buildResponse(2, null, 'Барааны үлдэгдэл шалгахад алдаа гарлаа.');
    }
  }

  checkItemQty(int id, int qty) async {
    try {
      final response = await api(Api.patch, 'check_qty/', body: {
        "data": {'$id': qty}
      });
      if (response!.statusCode == 200) {
        Map<String, dynamic> res = convertData(response);
        if (res['$id'] == null) {
          return buildResponse(0, res, null);
        } else if (res['$id'] == true) {
          return buildResponse(1, res, null);
        } else {
          return buildResponse(2, res, null);
        }
      } else {
        return buildResponse(3, null, null);
      }
    } catch (e) {
      print('checkITEMqty: $e');
      return buildResponse(4, null, null);
    }
  }

  Future addProduct(int id, String name, int qty) async {
    try {
      final response = await api(Api.patch, 'user_basket/',
          body: {'product_id': id, 'qty': qty});
      if (response == null) return;
      if (response.statusCode == 200) {
        if (convertData(response).toString().contains('available_qty')) {
          final result = convertData(response)['available_qty'];
          if (result == null) {
            message('Үлдэгдэл хүрэлцэхгүй байна.');
            return;
          }
          if (result.runtimeType == int) {
            message(
                'Үлдэгдэл хүрэлцэхгүй байна. Боломжит үлдэглэл ${convertData(response)['available_qty'] ?? 0}');
            return;
          }
        } else {
          await getBasket();
          message('$name сагсанд нэмэгдлээ', color: Colors.teal);
        }
      } else {
        message(wait);
      }
    } catch (e, stackTrace) {
      debugPrint('Stack Trace: $stackTrace');
      return message(wait);
    }
  }

  Future<String?> get getBasketCount async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? basketCount = prefs.getString("basket_count");
      return basketCount;
    } catch (e) {
      debugPrint(e.toString());
    }
    return '0';
  }

  Future<dynamic> clearBasket() async {
    try {
      final response = await api(Api.patch, 'clear_basket/',
          body: {'basket_id': basket!.id});
      await getBasket();
      if (response!.statusCode == 200) {
        debugPrint('basket cleared');
        await getBasket();
        notifyListeners();
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> removeBasketItem({required int itemId}) async {
    try {
      await api(Api.delete, 'user_basket/?item_id=$itemId');
      message('Сагснаас хасагдлаа');
      await getBasket();
    } catch (e) {
      message('Сагснаас бараа устгах үед алдаа гарлаа.');
    }
  }

  Future<dynamic> createOrder({
    required int basketId,
    required int branchId,
    required String note,
    required String deliveryType,
    required String pt,
    required BuildContext context,
  }) async {
    try {
      var body = {
        'basket_id': basketId,
        'branch_id': branchId,
        'pay_type': pt,
        'note': note != '' ? note : null,
        'is_come': deliveryType == 'N' ? true : false,
      };
      final response = await api(Api.post, 'pharmacy/order/', body: body);
      final res = convertData(response!);
      print(res);
      if (response.statusCode == 200) {
        Future(() async {
          await clearBasket();
        }).then((value) => goto(OrderDone(orderNo: res['orderNo'].toString())));
        return res['orderNo'];
      } else if (response.statusCode == 400) {
        message('Сагс хоосон байна!');
      } else {
        message(res);
      }
    } catch (e) {
      //
    }
  }

  Future<dynamic> createQR(
      {required int basketId,
      required int branchId,
      required String deliveryType,
      String? note,
      required BuildContext context}) async {
    try {
      var body = {
        'branch_id': branchId,
        'note': note != '' ? note : null,
        'is_come': deliveryType == 'N' ? true : false,
      };
      final resQR = await api(Api.post, 'ci/', body: body, showLog: true);
      final data = convertData(resQR!);
      final status = resQR.statusCode;
      print(resQR.body);
      if (status == 200) {
        _qrCode = OrderQRCode.fromJson(data);
        goto(const QRCode());
      } else if (status == 404) {
        if (data == 'qpay') {
          message('Нийлүүлэгч Qpay холбоогүй.');
        }
      } else if (status == 400) {
        if (data == 'bad qpay') {
          message('Нийлүүлэгчийн Qpay тохиргоо алдаатай!');
        } else if (data == 'min') {
          message('Төлбөрийн дүн 10₮-с дээш байх');
        } else if (data == 'empty') {
          message('Сагс хоосон байна!');
        } else if (data == 'branch not match') {
          message('Салбарын мэдээлэл буруу!');
        } else if (data['qpay'] == "not found") {
          message('Qpay холбоогүй.');
        }
      } else if (status == 500) {
        message('Админтай холбогдоно уу!');
      }
    } catch (e) {
      debugPrint('ERROR AT CREATE QR: $e');
    }
  }

  Future<dynamic> checkPayment() async {
    try {
      final resQR = await api(Api.post, 'cp/', body: {"invId": _qrCode.invId});
      if (resQR!.statusCode == 200) {
        final data = convertData(resQR).toString();
        if (data.contains('not paid')) {
          message('Төлбөр төлөгдөөгүй байна.');
        } else if (data.contains('paid')) {
          message('Төлбөр амжилттай төлөгдсөн.');
          goto(OrderDone(orderNo: convertData(resQR)['orderNo'].toString()));
        } else {
          message('Төлбөр төлөгдөөгүй байна.');
        }
      } else if (resQR.statusCode == 404) {
        message('Нэхэмжлэх үүсээгүй.');
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  void reset() {
    qty.clear();
    _count = 0;
    userrole = '';
    shoppingCarts.clear();
  }
}

class QTY {
  String id;
  bool val;
  QTY(this.id, this.val);
  factory QTY.fromJson(Map<String, dynamic> json) {
    return QTY(
      json['id'],
      json['val'],
    );
  }
}
