import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/basket.dart';
import 'package:pharmo_app/models/order_qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  String? userrole = '';
  late Basket _basket;
  Basket get basket => _basket;
  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;
  BasketProvider() {
    getUser();
    getBasket();
  }
  void getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('userrole');
    userrole = userRole;
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  Future<dynamic> checkQTYs() async {
    try {
      String bearerToken = await getAccessToken();
      Map<String, int?> bodyStr = {};
      List<String> errorMessages = [];
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
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
            body: jsonEncode({"data": bodyStr}));
        if (response.statusCode == 200) {
          Map<String, dynamic> res =
              jsonDecode(utf8.decode(response.bodyBytes));
          for (String key in res.keys) {
            dynamic cart = shoppingCarts
                .firstWhere((s) => s['product_itemname_id'].toString() == key);
            if (res[key] == null) {
              errorMessages.add(cart['product_name'] + ' бараа дууссан байна.');
            } else if (res[key] == false) {
              errorMessages.add(cart['product_name'] +
                  ' барааны үлдэгдэл хүрэлцэхгүй байна.');
            }
          }
          if (errorMessages.isNotEmpty) {
            return {
              'errorType': 2,
              'data': null,
              'message': errorMessages.join("\n")
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

  Future<dynamic> checkQTY(
      {int? product_id, int? itemname_id, required int qty}) async {
    try {
      String bearerToken = await getAccessToken();
      Map<String, int?> bodyStr;
      String isProduct;
      if (itemname_id != null && itemname_id > 0) {
        bodyStr = {'$itemname_id': qty};
        isProduct = itemname_id.toString();
      } else {
        bodyStr = {'$product_id': qty};
        isProduct = product_id.toString();
      }
      final response = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}check_qty/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"data": bodyStr}));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        if (res[isProduct] == null) {
          return {'errorType': 2, 'data': null, 'message': 'Бараа дууссан.'};
        } else if (res[isProduct] == false) {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Барааны тоо хүрэхгүй байна.'
          };
        } else {
          return {'errorType': 1, 'data': res, 'message': ''};
        }
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Барааны тоо хүрэхгүй байна.'
        };
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> addBasket(
      {int? product_id, int? itemname_id, required int qty}) async {
    try {
      Map check = await checkQTY(
          product_id: product_id, itemname_id: itemname_id, qty: qty);
      if (check['errorType'] == 1) {
        String bearerToken = await getAccessToken();
        final response = await http.post(
            Uri.parse('${dotenv.env['SERVER_URL']}basket_item/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': bearerToken,
            },
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
      } else {
        return {'errorType': 2, 'data': null, 'message': check['message']};
      }
    } catch (e) {
      print(e);
      return {'errorType': 3, 'data': e, 'message': ''};
    }
  }

  void getBasket() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";

      final resBasket = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}get_basket'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': bearerToken,
        },
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

  Future<String?> get getBasketCount async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? basketCount = prefs.getString("basket_count");
      return basketCount;
    } catch (e) {
      print(e);
    }
    return '0';
  }

  Future<dynamic> clearBasket({required int basket_id}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}clear_basket/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({'basketId': basket_id}));
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

  Future<dynamic> createOrder(
      {required int basket_id,
      required int address,
      required String pay_type}) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode(
              {'basket': basket_id, 'address': address, 'payType': pay_type}));
      notifyListeners();
      if (response.statusCode == 201) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        await clearBasket(basket_id: basket_id);
        return {
          'errorType': 1,
          'data': res,
          'message': 'Захиалга амжилттай үүслээ.'
        };
      } else {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Захиалга үүсхэд алдаа гарлаа.'
        };
      }
    } catch (e) {
      print(e);
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> createQR(
      {required int basket_id,
      required int address,
      required String pay_type}) async {
    try {
      String bearerToken = await getAccessToken();
      final resQR = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}ci/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      notifyListeners();
      if (resQR.statusCode == 200) {
        final response = jsonDecode(utf8.decode(resQR.bodyBytes));
        _qrCode = OrderQRCode.fromJson(response);
        return {
          'errorType': 1,
          'data': response,
          'message': 'QR code амжилттай үүслээ.'
        };
      } else if (resQR.statusCode == 404) {
        return {
          'errorType': 2,
          'data': null,
          'message': 'Нийлүүлэгч QPay холбоогүй байна.'
        };
      } else if (resQR.statusCode == 400) {
        if (resQR.body == 'qpay') {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Нийлүүлэгч QPay холбоогүй байна.'
          };
        } else if (resQR.body == 'bad qpay') {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Нийлүүлэгчийн Qpay тохиргоо алдаатай.'
          };
        } else if (resQR.body == 'min') {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Төлбөрийн дүн 10 төг буюу түүнээс дээш байх.'
          };
        } else if (resQR.body == 'empty') {
          return {
            'errorType': 2,
            'data': null,
            'message': 'Захиалганд бараа байхгүй буюу сагс хоосон.'
          };
        }
      } else if (resQR.statusCode == 500) {
        return {'errorType': 2, 'data': null, 'message': 'Серверийн алдаа.'};
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> checkPayment() async {
    try {
      String bearerToken = await getAccessToken();
      final resQR = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}cp/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
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
          'message': 'Төлбөр төлөх үед алдаа гарлаа.'
        };
      }
    } catch (e) {
      print(e);
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> removeBasketItem(
      {required int basket_id, required int item_id}) async {
    try {
      String bearerToken = await getAccessToken();
      final resQR = await http.delete(
          Uri.parse('${dotenv.env['SERVER_URL']}basket_item/$item_id/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          });
      if (resQR.statusCode == 204) {
        getBasket();
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
      print(e);
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<dynamic> changeBasketItem(
      {required String type, required int item_id, required int qty}) async {
    try {
      String bearerToken = await getAccessToken();
      if (type == 'add') {
        qty = qty + 1;
      } else if (type == 'set' && qty > 0) {
        qty = qty;
      } else {
        qty = qty - 1;
      }
      final resQR = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}basket_item/$item_id/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': bearerToken,
          },
          body: jsonEncode({"qty": qty}));
      if (resQR.statusCode == 200) {
        getBasket();
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
      print(e);
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}
