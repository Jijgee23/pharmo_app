import 'package:pharmo_app/application/application.dart';

class CartProvider extends ChangeNotifier {
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
    if (qty.text.isEmpty || qty.text == '') {
      qty.text = '1';
    } else {
      qty.text = qty.text.substring(0, qty.text.length - 1);
    }
    notifyListeners();
  }

  Basket? basket;

  bool get basketIsEmpty => (basket == null ||
      (basket != null && basket!.totalCount == 0) ||
      (basket != null && basket!.items.isEmpty));

  bool get isCashOnlyBasket =>
      basket != null && basket!.items.isNotEmpty && basket!.items.every((i) => i.cashOnly);
  List<dynamic> _shoppingCarts = [];
  List<dynamic> get shoppingCarts => [..._shoppingCarts];

  late OrderQRCode _qrCode;
  OrderQRCode get qrCode => _qrCode;

  Future<bool> checkLoan(int bId) async {
    final user = Authenticator.security;
    bool isPharmacist = user != null && user.isPharmacist;
    String sellerUrl = 'seller/customer/$bId/check_loan_info/?total_price=${basket!.totalPrice}';
    String paUrl = 'check_loan_info/?branch_id=$bId&total_price=${basket!.totalPrice}';
    final r = await api(Api.get, isPharmacist ? paUrl : sellerUrl);
    if (r == null) return false;
    if (r.statusCode == 200) {
      if (convertData(r)['is_loan_available'] == true) {
        return true;
      }
      messageError(convertData(r)['msg']);
      return false;
    }
    messageError(convertData(r)['msg']);
    return false;
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
        _shoppingCarts = basket!.items;
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
      final data = convertData(response);
      print(response.data);
      if (response.statusCode == 200) {
        if (data.toString().contains('available_qty')) {
          final result = data['available_qty'];
          if (result == null) {
            messageWarning('Үлдэгдэл хүрэлцэхгүй байна.');
            return;
          }
          messageWarning(
            'Үлдэгдэл хүрэлцэхгүй байна. Боломжит үлдэглэл ${data['available_qty'] ?? 0}',
          );
        } else {
          await getBasket();
          messageComplete('$name сагсанд нэмэгдлээ');
        }
      } else {
        if (data.toString().contains('Product not found!')) {
          messageWarning('Бараа олдсонгүй!');
          return;
        }
        messageWarning(wait);
      }
    } catch (e, stackTrace) {
      debugPrint('Stack Trace: $stackTrace');
      return messageError(wait);
    }
  }

  Future<dynamic> clearBasket() async {
    try {
      final r = await api(Api.patch, 'clear_basket/', body: {'basket_id': basket!.id});
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

  Future<void> removeCashOnlyItems() async {
    if (basket == null) return;
    final cashOnlyIds = basket!.items.where((i) => i.cashOnly).map((i) => i.id).toList();
    for (final id in cashOnlyIds) {
      await removeBasketItem(itemId: id);
    }
  }

  Future<dynamic> createOrder({
    // required int basketId,
    required int branchId,
    required String note,
    required String deliveryType,
    required String pt,
  }) async {
    await LoadingService.run(() async {
      try {
        var body = {
          'basket_id': basket!.id,
          'branch_id': branchId,
          'pay_type': pt,
          'note': note != '' ? note : null,
          'is_come': deliveryType == 'N' ? true : false,
        };
        final r = await api(Api.post, 'pharmacy/order/', body: body);
        if (r == null) return;
        final res = convertData(r);
        if (r.statusCode == 200) {
          // The delivery type/branch/payment type this order was placed
          // with no longer need to be pre-filled for a *next* order.
          Get.context?.read<HomeProvider>().clearOrderSelections();
          Future(() async {
            await clearBasket();
          }).then((value) => goto(OrderDone(orderNo: res['orderNo'].toString())));
          return res['orderNo'];
        } else if (r.statusCode == 400) {
          if (res['payType'] != null) {
            LoadingService.hide();
            bool payViaQpay = false;
            final confirmed = await confirmDialog(
              title: res['payType'][0].toString(),
              titleColor: Colors.red,
              message: 'Зөвхөн бэлнээр төлөгдөх бараануудыг сагснаас хасах уу?\n'
                  'Эсвэл шууд Qpay-р төлж болно.',
              content: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    payViaQpay = true;
                    final context = Get.context ?? GlobalKeys.navigatorKey.currentContext;
                    if (context != null) Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.qr_code_rounded, size: 18),
                  label: const Text('Шууд Qpay-р төлөх'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            );
            if (!confirmed) return;
            if (payViaQpay) {
              await createQR(branchId: branchId, note: note, deliveryType: deliveryType);
            } else {
              await removeCashOnlyItems();
              // Close the OrderSheet (still open behind this dialog) so the
              // user lands back on the basket and sees it without the
              // cash-only items instead of staying on a now-stale order
              // summary that still reflects the pre-removal total.
              if (Get.isBottomSheetOpen ?? false) Get.back();
            }
            return;
          }
          messageWarning(res.toString());
        } else {
          messageError(res.toString());
        }
      } catch (e) {
        messageError('Захиалга үүсгэх үед алдаа гарлаа. Админтай холбогдоно уу!');
      }
    });
  }

  bool loading = true;
  setLoading(bool val) {
    loading = val;
    notifyListeners();
  }

  Future<dynamic> createQR({int? branchId, required String deliveryType, String? note}) async {
    try {
      // final user = Authenticator.security;
      // if (user == null) {
      //   messageWarning('Нэвтэрнэ үү!');
      //   return;
      // }
      // bool isPharmacist = user.isPharmacist;

      var body = {
        'branch_id': branchId,
        'note': note != '' ? note : null,
        'is_come': deliveryType == 'N' ? true : false,
      };
      final r = await api(Api.post, 'ci/', body: body);
      if (r == null) return;
      final data = convertData(r);
      final status = r.statusCode;
      if (status == 200) {
        _qrCode = OrderQRCode.fromJson(data);
        goto(const QRCode());
      } else if (status == 404) {
        if (data == 'qpay') {
          messageWarning('Нийлүүлэгч Qpay холбоогүй.');
        }
      } else if (status == 403) {
        messageWarning('Хэрэглэгчийн эрх хүрэхгүй байна.');
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
          Get.context?.read<HomeProvider>().clearOrderSelections();
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

  // ── Seller/VS order QPay (seller/order/{orderId}/qpay/*) ──────────────
  // Distinct from createQR()/checkPayment() above, which are the
  // pharmacist ci//cp/ flow: a seller order already exists (status W)
  // before any of these are called - QPay never gates recording the sale.

  Future<SellerQpayInvoice?> createSellerQpayInvoice(int orderId) async {
    final r = await api(Api.post, 'seller/order/$orderId/qpay/');
    if (r == null) return null;
    if (r.statusCode == 200 || r.statusCode == 201) {
      return SellerQpayInvoice.fromJson(convertData(r));
    }
    messageWarning('Qpay нэхэмжлэх үүсгэж чадсангүй.');
    return null;
  }

  Future<bool> checkSellerQpayPayment(int orderId) async {
    final r = await api(Api.post, 'seller/order/$orderId/qpay/check/');
    if (r == null) return false;
    if (r.statusCode == 200) {
      return convertData(r)['isPaid'] == true;
    }
    return false;
  }

  Future<bool> skipSellerQpay(int orderId, String reason) async {
    final r = await api(Api.post, 'seller/order/$orderId/qpay/skip/', body: {'reason': reason});
    if (r == null) return false;
    if (r.statusCode == 200) {
      return convertData(r)['skipped'] == true;
    }
    return false;
  }

  SellerPaymentSettings? paymentSettings;

  Future<void> getSellerPaymentSettings() async {
    try {
      final r = await api(Api.get, 'seller/payment_settings/');
      if (r == null || r.statusCode != 200) return;
      paymentSettings = SellerPaymentSettings.fromJson(convertData(r));
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR AT getSellerPaymentSettings: $e');
    }
  }

  // Pharmacy ordering roles (PA) equivalent of getSellerPaymentSettings()
  // above — different endpoint (describes the supplier currently selected
  // on the session, not the caller's own org), but an identical response
  // shape, so it's parsed into the same SellerPaymentSettings/BankAccount
  // models and stored in the same paymentSettings field OrderSheet already
  // reads regardless of role.
  Future<void> getSupplierOrderSettings() async {
    try {
      final r = await api(Api.get, 'supplier_order_settings/');
      if (r == null || r.statusCode != 200) return;
      paymentSettings = SellerPaymentSettings.fromJson(convertData(r));
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR AT getSupplierOrderSettings: $e');
    }
  }

  void reset() {
    qty.clear();
    basket = null;
    paymentSettings = null;
    shoppingCarts.clear();
    notifyListeners();
  }
}
