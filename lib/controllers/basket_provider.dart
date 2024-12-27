// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/cart/order_done.dart';
import 'package:pharmo_app/views/public_uses/cart/qr_code.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late Basket _basket;
  Basket get basket => _basket;
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
      final resBasket = await apiGet('get_basket');
      if (resBasket.statusCode == 200) {
        final res = convertData(resBasket);
        _basket = Basket.fromJson(res);
        _count = _basket.items != null && _basket.items!.isNotEmpty
            ? _basket.items!.length
            : 0;
        _shoppingCarts = _basket.items!;
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
            await apiPatch('check_qty/', jsonEncode({"data": bodyStr}));
        if (response.statusCode == 200) {
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
      var body = jsonEncode({
        "data": {"$id": qty}
      });
      final response = await apiPatch('check_qty/', body);
      if (response.statusCode == 200) {
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

  Future<Map<String, dynamic>> addBasket({
    int? productId,
    int? itemnameId,
    required int qty,
  }) async {
    final int checkId = itemnameId ?? productId!;
    try {
      final dynamic check = await checkItemQty(checkId, qty);
      final int status = check['errorType'];
      switch (status) {
        case 0:
          return buildResponse(0, null, 'Бараа дууссан.');
        case 1:
          final response = await apiPost(
            'basket_item/',
            jsonEncode({'product': productId, 'qty': qty}),
          );
          if (response.statusCode == 201) {
            return buildResponse(1, response, 'сагсанд нэмэгдлээ.');
          } else {
            return buildResponse(
                2, null, 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.');
          }
        case 2:
          return buildResponse(3, null, 'Барааны үлдэгдэл хүрэлцэхгүй байна.');
        case 3:
        default:
          return buildResponse(4, null, 'Алдаа гарлаа.');
      }
    } catch (e, stackTrace) {
      debugPrint('Stack Trace: $stackTrace');
      return buildResponse(4, e, 'Алдаа гарлаа.');
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
      final response =
          await apiPost('clear_basket/', jsonEncode({'basketId': basket.id}));
      await getBasket();
      if (response.statusCode == 200) {
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
      await apiDelete('basket_item/$itemId/');
    } catch (e) {
      return buildResponse(2, null, 'Сагснаас бараа устгах үед алдаа гарлаа.');
    }
  }

  Future<dynamic> changeBasketItem(
      {required String type, required int itemId, required int qty}) async {
    try {
      if (type == 'add') {
        qty = qty + 1;
      } else if (type == 'set' && qty > 0) {
        qty = qty;
      } else {
        qty = qty - 1;
      }
      final resQR = await apiPatch('basket_item/$itemId/',
          jsonEncode({"qty": int.parse(qty.toString())}));
      if (resQR.statusCode == 200) {
        await getBasket();
        return buildResponse(1, null, 'Барааны тоог амжилттай өөрчиллөө.');
      } else {
        notifyListeners();
        return buildResponse(2, null, 'Барааны тоог өөрчлөх үед алдаа гарлаа.');
      }
    } catch (e) {
      return buildResponse(2, null, 'Барааны тоог өөрчлөх үед алдаа гарлаа.');
    }
  }

  Future<dynamic> createOrder(
      {required int basketId,
      required int branchId,
      required String note,
      required BuildContext context}) async {
    try {
      var body = jsonEncode({
        'basketId': basketId,
        'branchId': (branchId == -1) ? null : branchId,
        'note': note != '' ? note : null
      });
      final response = await apiPost('pharmacy/order/', body);
      final res = convertData(response);
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
      String? note,
      required BuildContext context}) async {
    try {
      var body = jsonEncode({
        'branchId': (branchId == 0) ? null : branchId,
        'note': note != '' ? note : null
      });
      final resQR = await apiPost('ci/', body);
      final data = convertData(resQR);
      final status = resQR.statusCode;
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
      final resQR = await apiGet('cp/');
      if (resQR.statusCode == 200) {
        dynamic response = convertData(resQR);
        await clearBasket();
        notifyListeners();
        return {
          'errorType': 1,
          'data': response,
          'message': 'Төлбөр амжилттай төлөгдсөн байна.'
        };
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Төлбөр шалгах үед алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
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
