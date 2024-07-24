// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/promotion.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PromotionProvider extends ChangeNotifier {
  List<Promotion> promotions = <Promotion>[];
  List<Promotion> markedPromos = <Promotion>[];
  List<Promotion> filteredPromos = <Promotion>[];
  final List<String> filterTypes = [
    'promo_type',
    'has_gift',
    'end_date',
  ];

  getPromotion() async {
    String bearerToken = await getAccessToken();
    final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}get_promos/'),
        headers: {'Authorization': bearerToken});
    if (response.statusCode == 200) {
      final res = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> promos = res['results'];
      promotions = (promos).map((data) => Promotion.fromJson(data)).toList();
      notifyListeners();
    }
  }

  getMarkedPromotion(BuildContext context) async {
    String bearerToken = await getAccessToken();
    final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/'),
        headers: {'Authorization': bearerToken});
    if (response.statusCode == 200) {
      final res = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> promos = res['results'];
      markedPromos = (promos).map((data) => Promotion.fromJson(data)).toList();
      notifyListeners();
    } else if (response.statusCode == 204){
      showFailedMessage(message: 'Онцлох урамшуулал байхгүй', context: context);
    }
  }

  filterPromotion(String filter, String type, String value) async {
    String bearerToken = await getAccessToken();
    final response = await http.get(
        Uri.parse('${dotenv.env['SERVER_URL']}get_promos/?$type=$value'),
        headers: {'Authorization': bearerToken});
    if (response.statusCode == 200) {
      final res = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> promos = res['results'];
      filteredPromos =
          (promos).map((data) => Promotion.fromJson(data)).toList();
      notifyListeners();
    } 
  }
  hidePromo(int id, BuildContext context) async {
    String bearerToken = await getAccessToken();
    final response = await http.patch(
        Uri.parse('${dotenv.env['SERVER_URL']}marked_promos/$id/'),
        headers: {'Authorization': bearerToken});
        if(response.statusCode == 200){
          showSuccessMessage(message: 'Амжилттай', context: context);
        } else {
          showFailedMessage(message: 'Амжилтгүй', context: context);
        }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");
    String bearerToken = "Bearer $token";
    return bearerToken;
  }
}

