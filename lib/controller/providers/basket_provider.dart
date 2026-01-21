import 'package:pharmo_app/application/application.dart';

class BasketProvider extends ChangeNotifier {
  final TextEditingController qty = TextEditingController();
  void setQTYvalue(String n) {
    qty.text = n;
    notifyListeners();
  }

  void write(String n) {
    if (n == '.' && qty.text.contains('.')) return;
    if (n == '.' && qty.text.isEmpty) {
      qty.text = '0.';
      notifyListeners();
      return;
    }
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
  Basket? basket;
  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;

  void increment() {
    _count++;
    notifyListeners();
  }

  Future getBasket() async {
    try {
      final r = await api(Api.get, basketUrl);
      if (r == null) {
        basket = null;
        notifyListeners();
        return;
      }
      if (r.statusCode == 200) {
        final res = convertData(r);
        basket = Basket.fromJson(res as Map<String, dynamic>);
        _count = basket!.items != null && basket!.items!.isNotEmpty
            ? basket!.items!.length
            : 0;
        _shoppingCarts = basket!.items!;
        notifyListeners();
      } else {
        basket = null;
        notifyListeners();
      }
    } catch (e) {
      print('e at get basket: $e');
      basket = null;
      notifyListeners();
      throw Exception(e);
    }
  }

  Future addProduct(int id, String name, double qty) async {
    try {
      final response = await api(
        Api.patch,
        basketUrl,
        body: {'product_id': id, 'qty': qty},
      );
      if (response == null) return;
      if (response.statusCode == 200) {
        print(response.body);
        if (convertData(response).toString().contains('available_qty')) {
          final result = convertData(response)['available_qty'];
          if (result == null) {
            messageWarning('Үлдэгдэл хүрэлцэхгүй байна.');
            return;
          }
          messageWarning(
            'Үлдэгдэл хүрэлцэхгүй байна. Боломжит үлдэглэл ${convertData(response)['available_qty'] ?? 0}',
          );
        } else {
          await getBasket();
          messageComplete('$name сагсанд нэмэгдлээ');
        }
      } else {
        messageWarning(wait);
      }
    } catch (e, stackTrace) {
      debugPrint('Stack Trace: $stackTrace');
      return messageError(wait);
    }
  }

  Future<dynamic> clearBasket() async {
    try {
      final r = await api(Api.patch, 'clear_basket/',
          body: {'basket_id': basket!.id});
      if (r == null) return;
      await getBasket();
      if (r.statusCode == 200) {
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
      final r = await api(Api.delete, '$basketUrl?item_id=$itemId');
      if (r == null) return;
      messageComplete('Сагснаас хасагдлаа');
      await getBasket();
    } catch (e) {
      messageWarning('Сагснаас бараа устгах үед алдаа гарлаа.');
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
      final r = await api(Api.post, 'pharmacy/order/', body: body);
      if (r == null) return;
      final res = convertData(r);
      if (r.statusCode == 200) {
        Future(() async {
          await clearBasket();
        }).then((value) => goto(OrderDone(orderNo: res['orderNo'].toString())));
        return res['orderNo'];
      } else if (r.statusCode == 400) {
        messageWarning('Сагс хоосон байна!');
      } else {
        messageError(res);
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
      final r = await api(Api.post, 'ci/', body: body);
      if (r == null) return;
      final data = convertData(r);
      final status = r.statusCode;
      print(r.body);
      if (status == 200) {
        _qrCode = OrderQRCode.fromJson(data);
        goto(const QRCode());
      } else if (status == 404) {
        if (data == 'qpay') {
          messageWarning('Нийлүүлэгч Qpay холбоогүй.');
        }
      } else if (status == 400) {
        if (data == 'bad qpay') {
          messageWarning('Нийлүүлэгчийн Qpay тохиргоо алдаатай!');
        } else if (data == 'min') {
          messageWarning('Төлбөрийн дүн 10₮-с дээш байх');
        } else if (data == 'empty') {
          messageWarning('Сагс хоосон байна!');
        } else if (data == 'branch not match') {
          messageWarning('Салбарын мэдээлэл буруу!');
        } else if (data['qpay'] == "not found") {
          messageWarning('Qpay холбоогүй.');
        }
      } else if (status == 500) {
        messageWarning('Админтай холбогдоно уу!');
      }
    } catch (e) {
      debugPrint('ERROR AT CREATE QR: $e');
    }
  }

  Future<dynamic> checkPayment() async {
    try {
      final r = await api(Api.post, 'cp/', body: {"invId": _qrCode.invId});
      if (r == null) return;
      if (r.statusCode == 200) {
        final data = convertData(r).toString();
        if (data.contains('not paid')) {
          messageWarning('Төлбөр төлөгдөөгүй байна.');
        } else if (data.contains('paid')) {
          messageComplete('Төлбөр амжилттай төлөгдсөн.');
          goto(OrderDone(orderNo: convertData(r)['orderNo'].toString()));
        } else {
          messageWarning('Төлбөр төлөгдөөгүй байна.');
        }
      } else if (r.statusCode == 404) {
        messageWarning('Нэхэмжлэх үүсээгүй.');
      }
    } catch (e) {
      return {'errorType': 3, 'data': e, 'message': e};
    }
  }

  void reset() {
    qty.clear();
    _count = 0;
    basket = null;
    shoppingCarts.clear();
    notifyListeners();
  }
}
