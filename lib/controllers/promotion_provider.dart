import 'package:flutter/material.dart';
import 'package:pharmo_app/views/cart/order_done.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/models/a_models.dart';
import 'package:pharmo_app/utilities/a_utils.dart';

class PromotionProvider extends ChangeNotifier {
  List<Promotion> promotions = <Promotion>[];
  List<MarkedPromo> markedPromotions = <MarkedPromo>[];
  MarkedPromo promoDetail = MarkedPromo();
  Map<String, dynamic> qrCode = {};
  QrData qrData = QrData();
  String payType = 'C';
  bool hasNote = false;
  bool useBank = false;
  bool showQr = false;
  bool isCash = true;
  bool orderStarted = false;
  bool delivery = false;
  dis() {
    setDelivery(false);
    setBank(false);
    setHasnote(false);
    setQr(false);
    setIsCash(true);
    setOrderStartedWithVal(false);
    notifyListeners();
  }

  setOrderStartedWithVal(bool v) {
    orderStarted = v;
    notifyListeners();
  }

  setPayType() {
    if (payType == 'C') {
      payType = 'L';
    } else {
      payType = 'C';
    }
    notifyListeners();
  }

  setDelivery(bool v) {
    delivery = v;
    notifyListeners();
  }

  setOrderStarted() {
    orderStarted = !orderStarted;
    notifyListeners();
  }

  setIsCash(bool v) {
    isCash = v;
    notifyListeners();
  }

  setQr(bool v) {
    showQr = v;
    notifyListeners();
  }

  setHasnote(bool v) {
    hasNote = v;
    notifyListeners();
  }

  setBank(bool v) {
    useBank = v;
    notifyListeners();
  }

  setQrCode(Map<String, dynamic> v) {
    qrCode = v;
    notifyListeners();
  }

  void setMarkedPromo(MarkedPromo v) {
    promoDetail = v;
    notifyListeners();
  }

  void clearPromoDetail() {
    promoDetail = MarkedPromo();
    notifyListeners();
  }

  getPromotion() async {
    try {
      final response = await api(Api.get, 'get_promos/');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        print(res);
        promotions.clear();
        List<dynamic> promos = res['results'];
        promotions = (promos).map((data) => Promotion.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR AT PROMO: ${e.toString()}');
    }
  }

  getDetail(int promoId) async {
    try {
      final response = await api(Api.get, 'get_promos/$promoId/');
      if (response!.statusCode == 200) {
        Map<String, dynamic> p = convertData(response);
        MarkedPromo mp = MarkedPromo.fromJson(p);
        setMarkedPromo(mp);
        notifyListeners();
        return mp;
      }
    } catch (e) {
      debugPrint('ERROR AT PROMODETAIL: ${e.toString()}');
    }
  }

  getMarkedPromotion() async {
    try {
      markedPromotions.clear();
      final response = await api(Api.get, 'marked_promos/');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        markedPromotions =
            (res as List).map((data) => MarkedPromo.fromJson(data)).toList();
      } else if (response.statusCode == 204) {
        markedPromotions.clear();
      }
    } catch (e) {
      // debugPrint('ERROR AT MPROMO: ${e.toString()}');
    }
    notifyListeners();
  }

  filterPromotion(String type, String value) async {
    try {
      final response = await api(Api.get, 'get_promos/?$type=$value');
      if (response!.statusCode == 200) {
        final res = convertData(response);
        List<dynamic> pro = res['results'];
        promotions.clear();
        promotions = (pro).map((data) => Promotion.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR AT FILTER PROMO: ${e.toString()}');
    }
  }

  hidePromo(int id, BuildContext context) async {
    try {
      final response = await api(Api.patch, 'marked_promos/$id/', body: {});
      if (response!.statusCode == 200) {
        message('Амжилттай');
        getMarkedPromotion();
      } else {
        message('Амжилтгүй');
      }
    } catch (e) {
      debugPrint('ERROR AT HIDE PROMO: ${e.toString()}');
    }
  }

  orderPromo(
      int promoId, int branchId, String? note, BuildContext context) async {
    try {
      final body = {
        "payType": payType,
        "promoId": promoId,
        "branchId": (delivery == false) ? branchId : null,
        "note": note,
      };
      final response = await api(Api.post, 'pharmacy/promo_order/', body: body);
      var data = convertData(response!);
      if (response.statusCode == 200) {
        qrData = QrData.fromJson(data);
        setQr(true);
      } else if (response.statusCode == 400) {
        message('Урамшууллын хугацаа дууссан');
      } else {}
    } catch (e) {
      debugPrint('ERROR AT ORDER PROMO: ${e.toString()}');
    }
  }

  checkPayment(BuildContext context) async {
    final response = await api(Api.patch, 'pharmacy/promo_order/cp/',
        body: {"invoiceId": qrData.invoiceId});
    final data = convertData(response!);
    if (response.statusCode == 200) {
      goto(OrderDone(orderNo: data['orderNo'].toString()));
      message('Төлбөр төлөгдсөн байна');
      return true;
    } else {
      message('Төлбөр төлөгдөөгүй байна');
    }
  }
}
