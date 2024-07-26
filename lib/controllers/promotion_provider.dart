// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/marked_promo.dart';
import 'package:pharmo_app/models/promotion.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PromotionProvider extends ChangeNotifier {
  List<Promotion> promotions = <Promotion>[];
  List<MarkedPromo> markedPromotions = <MarkedPromo>[];
  final List<String> filterTypes = [
    'promo_type',
    'has_gift',
    'end_date',
  ];

  getPromotion() async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}get_promos/'),
          headers: {'Authorization': bearerToken});
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> promos = res['results'];
        // debugPrint('PROMOS: $promos');
        promotions = (promos).map((data) => Promotion.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  getMarkedPromotion(BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/'),
          headers: {'Authorization': bearerToken});
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('MARKED PROMOS: ${res[0]['bundle']}');
        markedPromotions =
            (res).map((data) => MarkedPromo.fromJson(data)).toList();
        notifyListeners();
      } else if (response.statusCode == 204) {}
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  filterPromotion(String type, String value) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}get_promos/?$type=$value'),
          headers: {'Authorization': bearerToken});
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> pro = res['results'];
        // debugPrint('FILTERED PROMOS: $pro');
        promotions.clear();
        promotions = (pro).map((data) => Promotion.fromJson(data)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  hidePromo(int id, BuildContext context) async {
    try {
      String bearerToken = await getAccessToken();
      final response = await http.patch(
          Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/$id/'),
          headers: {'Authorization': bearerToken});
      if (response.statusCode == 200) {
        showSuccessMessage(message: 'Амжилттай', context: context);
      } else {
        showFailedMessage(message: 'Амжилтгүй', context: context);
      }
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}
