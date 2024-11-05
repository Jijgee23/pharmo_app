// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/models/promotion.dart';
import 'package:pharmo_app/models/qr_data.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final token = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}get_promos/'),
          headers: getHeader(token));
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
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
    final token = await getAccessToken();
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}get_promos/$promoId/'),
          headers: getHeader(token));
      if (response.statusCode == 200) {
        Map<String, dynamic> p = jsonDecode(utf8.decode(response.bodyBytes));
        MarkedPromo mp = MarkedPromo.fromJson(p);
        // clearPromoDetail();
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
      final token = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/'),
          headers: getHeader(token));
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        markedPromotions.clear();
        markedPromotions =
            (res).map((data) => MarkedPromo.fromJson(data)).toList();
        notifyListeners();
      } else if (response.statusCode == 204) {
        markedPromotions.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR AT MPROMO: ${e.toString()}');
    }
  }

  filterPromotion(String type, String value) async {
    final token = await getAccessToken();
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}get_promos/?$type=$value'),
          headers: getHeader(token));
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
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
    final token = await getAccessToken();
    try {
      final response = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/$id/'),
          headers: getHeader(token));
      if (response.statusCode == 200) {
        message(message: 'Амжилттай', context: context);
      } else {
        message(message: 'Амжилтгүй', context: context);
      }
    } catch (e) {
      debugPrint('ERROR AT HIDE PROMO: ${e.toString()}');
    }
  }

  orderPromo(
      int promoId, int branchId, String? note, BuildContext context) async {
    final token = await getAccessToken();
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/promo_order/'),
        headers: getHeader(token),
        body: jsonEncode(
          {
            "payType": payType,
            "promoId": promoId,
            (delivery == false) ? "branchId" : branchId: null,
            note != null ? "note" : note: null,
          },
        ),
      );
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        qrData = QrData.fromJson(data);
        setQr(true);
      } else if (response.statusCode == 400) {
        message(
            message: 'Урамшууллын хугацаа дууссан', context: context);
      } else {}
    } catch (e) {
      debugPrint('ERROR AT ORDER PROMO: ${e.toString()}');
    }
  }

  checkPayment(BuildContext context) async {
    final token = await getAccessToken();
    final response = await http.patch(
      Uri.parse('${dotenv.env['SERVER_URL']}pharmacy/promo_order/cp/'),
      headers: getHeader(token),
      body: jsonEncode(
        {
          "invoiceId": qrData.invoiceId,
        },
      ),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      goto(OrderDone(orderNo: data['orderNo'].toString()));
      message(message: 'Төлбөр төлөгдсөн байна', context: context);
      return true;
    } else {
      message(message: 'Төлбөр төлөгдөөгүй байна', context: context);
    }
  }
}
