// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/qr_code.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketProvider extends ChangeNotifier {
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
        Map<String, dynamic> res = jsonDecode(utf8.decode(resBasket.bodyBytes));
        _basket = Basket.fromJson(res);
        _count = _basket.items != null && _basket.items!.isNotEmpty
            ? _basket.items!.length
            : 0;
        _shoppingCarts = _basket.items!;
        notifyListeners();
      }
    } catch (e) {
      notifyListeners();
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
          Map res = jsonDecode(utf8.decode(response.bodyBytes));
          qtys.clear();
          res.forEach((k, v) {
            if (v == false) {
              qtys.add(QTY(k, v));
            }
          });
          if (qtys.isNotEmpty) {
            return {
              'errorType': 5,
              'data': null,
              'message': 'Барааны үлдэгдэл хүрэлцэхгүй байна!'
            };
          } else {
            return {'errorType': 1, 'data': res, 'message': ''};
          }
        }
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  errorAt(String type, String e) {
    debugPrint('ERROR AT $type e: $e');
  }

  checkItemQty(int id, int qty) async {
    try {
      final response = await apiPatch(
          'check_qty/',
          jsonEncode({
            "data": {"$id": qty}
          }));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        if (res['$id'] == null) {
          return {
            'v': 0,
          };
        } else if (res['$id'] == true) {
          return {'v': 1};
        } else {
          return {
            'v': 2,
          };
        }
      } else {
        return {
          'v': 3,
        };
      }
    } catch (e) {
      errorAt('CHECK QTY', e.toString());
      return {
        'v': 4,
      };
    }
  }

  Future<dynamic> addBasket(
      {int? product_id, int? itemname_id, required int qty}) async {
    print('id $product_id itemid: $itemname_id');
    int checkId = (itemname_id == null) ? product_id! : itemname_id;
    try {
      dynamic check = await checkItemQty(checkId, qty);
      if (check['v'] == 0) {
        return {'errorType': 0, 'data': null, 'message': 'Бараа дууссан.'};
      } else if (check['v'] == 1) {
        final response = await apiPost(
            'basket_item/', jsonEncode({'product': product_id, 'qty': qty}));
        if (response.statusCode == 201) {
          return {
            'errorType': 1,
            'data': response,
            'message': 'Сагсанд амжилттай нэмэгдлээ.'
          };
        } else {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.'
          };
        }
      } else if (check['v'] == 2) {
        return {
          'errorType': 3,
          'data': null,
          'message': 'Барааны үлдэгдэл хүрэлцэхгүй байна.'
        };
      } else if (check['v'] == 4) {
        return {'errorType': 4, 'data': null, 'message': 'Алдаа гарлаа.'};
      }
    } catch (e) {
      return {'errorType': 4, 'data': e, 'message': 'Алдаа гарлаа.'};
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

  Future<dynamic> clearBasket({required int basket_id}) async {
    try {
      final response =
          await apiPost('clear_basket/', jsonEncode({'basketId': basket_id}));
      await getBasket();
      notifyListeners();
      if (response.statusCode == 200) {
        return {
          'errorType': 1,
          'data': response,
          'message': 'Сагсан дахь бараа амжилттай устлаа.'
        };
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Уг бараа өмнө сагсанд бүртгэгдсэн байна.'
        };
      }
    } catch (e) {
      return {'fail': e};
    }
  }

  Future<dynamic> removeBasketItem(
      {required int basket_id, required int item_id}) async {
    try {
      final resQR = await apiDelete('basket_item/$item_id/');
      if (resQR.statusCode == 204) {
        await getBasket();
        notifyListeners();
        return {
          'errorType': 1,
          'data': null,
          'message': 'Сагснаас бараа амжилттай устгалаа.!'
        };
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Сагснаас бараа устгах үед алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> changeBasketItem(
      {required String type, required int item_id, required int qty}) async {
    try {
      if (type == 'add') {
        qty = qty + 1;
      } else if (type == 'set' && qty > 0) {
        qty = qty;
      } else {
        qty = qty - 1;
      }
      final resQR = await apiPatch('basket_item/$item_id/',
          jsonEncode({"qty": int.parse(qty.toString())}));
      if (resQR.statusCode == 200) {
        await getBasket();
        notifyListeners();
        return {
          'errorType': 1,
          'data': null,
          'message': 'Барааны тоог амжилттай өөрчиллөө.'
        };
      } else {
        notifyListeners();
        return {
          'errorType': 2,
          'data': null,
          'message': 'Барааны тоог өөрчлөх үед алдаа гарлаа.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> createOrder(
      {required int basket_id,
      required int branch_id,
      required String note,
      required BuildContext context}) async {
    try {
      var body = jsonEncode({
        'basketId': basket_id,
        'branchId': (branch_id == -1) ? null : branch_id,
        'note': note != '' ? note : null
      });
      final response = await apiPost('pharmacy/order/', body);
      final res = jsonDecode(utf8.decode(response.bodyBytes));
      final status = response.statusCode;
      debugPrint('basket_id: $basket_id, status code: $status, body: $res');
      if (response.statusCode == 200) {
        Future(() async {
          await clearBasket(basket_id: basket_id);
        }).then((value) => goto(OrderDone(orderNo: res['orderNo'].toString())));
        return res['orderNo'];
      } else if (response.statusCode == 400) {
        message(message: 'Сагс хоосон байна!', context: context);
      } else {
        message(message: res, context: context);
      }
    } catch (e) {
      //
    }
  }

  Future<dynamic> createQR(
      {required int basket_id,
      required int branch_id,
      String? note,
      required BuildContext context}) async {
    try {
      var body = jsonEncode({
        'branchId': (branch_id == 0) ? null : branch_id,
        'note': note != '' ? note : null
      });
      final resQR = await apiPost('ci/', body);
      final data = jsonDecode(utf8.decode(resQR.bodyBytes));
      final status = resQR.statusCode;
      debugPrint('status code: $status, body: $data');
      if (status == 200) {
        _qrCode = OrderQRCode.fromJson(data);
        goto(const QRCode());
      } else if (status == 404) {
        if (data == 'qpay') {
          message(message: 'Нийлүүлэгч Qpay холбоогүй.', context: context);
        }
      } else if (status == 400) {
        if (data == 'bad qpay') {
          message(
              message: 'Нийлүүлэгчийн Qpay тохиргоо алдаатай!',
              context: context);
        } else if (data == 'min') {
          message(message: 'Төлбөрийн дүн 10₮-с дээш байх', context: context);
        } else if (data == 'empty') {
          message(message: 'Сагс хоосон байна!', context: context);
        } else if (data == 'branch not match') {
          message(message: 'Салбарын мэдээлэл буруу!', context: context);
        }
      } else if (status == 500) {
        message(message: 'Админтай холбогдоно уу!', context: context);
      }
    } catch (e) {
      debugPrint('ERROR AT CREATE QR: $e');
    }
  }

  Future<dynamic> checkPayment() async {
    try {
      final resQR = await apiGet('cp/');
      if (resQR.statusCode == 200) {
        dynamic response = jsonDecode(utf8.decode(resQR.bodyBytes));
        await clearBasket(basket_id: basket.id);
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
