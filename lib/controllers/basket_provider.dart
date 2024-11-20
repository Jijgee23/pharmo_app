// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
      String bearerToken = await getAccessToken();
      final resBasket = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}get_basket'),
        headers: getHeader(bearerToken),
      );
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
      String bearerToken = await getAccessToken();
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
        final response = await http.patch(
            Uri.parse('${dotenv.env['SERVER_URL']}check_qty/'),
            headers: getHeader(bearerToken),
            body: jsonEncode({"data": bodyStr}));
        if (response.statusCode == 200) {
          Map res = jsonDecode(utf8.decode(response.bodyBytes));
          // print(res);
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
      String bearerToken = await getAccessToken();
      final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_URL']}check_qty/'),
        headers: getHeader(bearerToken),
        body: jsonEncode(
          {
            "data": {"$id": qty}
          },
        ),
      );
      debugPrint(
          'CHECK QTY ID:${id} STATUS: ${response.statusCode} BODY: ${response.body}');
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
    String bearerToken = await getAccessToken();
    try {
      dynamic check = await checkItemQty(checkId, qty);
      if (check['v'] == 0) {
        return {'errorType': 0, 'data': null, 'message': 'Бараа дууссан.'};
      } else if (check['v'] == 1) {
        final response = await http.post(
            Uri.parse('${dotenv.env['SERVER_URL']}basket_item/'),
            headers: getHeader(bearerToken),
            body: jsonEncode({'product': product_id, 'qty': qty}));
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
      String bearerToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}clear_basket/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({'basketId': basket_id}));
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
      String bearerToken = await getAccessToken();
      final resQR = await http.delete(
          Uri.parse('${dotenv.env['SERVER_URL']}basket_item/$item_id/'),
          headers: getHeader(bearerToken));
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
      String bearerToken = await getAccessToken();
      // checkQTY(qty: qty);
      if (type == 'add') {
        qty = qty + 1;
      } else if (type == 'set' && qty > 0) {
        qty = qty;
      } else {
        qty = qty - 1;
      }
      final resQR = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}basket_item/$item_id/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({"qty": int.parse(qty.toString())}));
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
      String bearerToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/order/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({
            'basketId': basket_id,
            'branchId': (branch_id == -1) ? null : branch_id,
            'note': note != '' ? note : null
          }));
      final res = jsonDecode(utf8.decode(response.bodyBytes));
      final status = response.statusCode;
      debugPrint('basket_id: $basket_id, status code: $status, body: $res');
      if (response.statusCode == 200) {
        Future(() async {
          await clearBasket(basket_id: basket_id);
        }).then((value) => goto(OrderDone(orderNo: res['orderNo'].toString())));
        // goto(OrderDone(orderNo: res['orderNo']), context);
        // await clearBasket(basket_id: basket_id);
        return res['orderNo'];
      } else if (response.statusCode == 400) {
        message(message: 'Сагс хоосон байна!', context: context);
      } else {
        // return {'errorType': 2, 'data': null, 'message': response.body};
        message(message: res, context: context);
      }
    } catch (e) {
      // return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> createQR(
      {required int basket_id,
      required int branch_id,
      String? note,
      required BuildContext context}) async {
    try {
      String bearerToken = await getAccessToken();
      final resQR = await http.post(Uri.parse('${dotenv.env['SERVER_URL']}ci/'),
          headers: getHeader(bearerToken),
          body: jsonEncode({
            'branchId': (branch_id == 0) ? null : branch_id,
            'note': note != '' ? note : null
          }));
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
      String bearerToken = await getAccessToken();
      final resQR = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}cp/'),
          headers: getHeader(bearerToken));
      print(resQR.body);
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
