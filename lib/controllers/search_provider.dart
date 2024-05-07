import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider {
  static Future<List<dynamic>?> getProdList(
    int page,
    int limit,
  ) async {
    try {
      // final serverUrl = dotenv.env['SERVER_URL'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse(
          // 'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'),
          '${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        return prods;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListByName(
    int page,
    int limit,
    String searchQuery,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));

        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i].name.toString().toLowerCase().contains(searchQuery.toString().toLowerCase())) {
            filteredItems.add(prods[i]);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListByIntName(
    int page,
    int limit,
    String searchQuery,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse(
          // 'http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'), headers: <String, String>{
          '${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i].intName.toString().toLowerCase().contains(searchQuery.toString().toLowerCase())) {
            filteredItems.add(prods[i]);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListByBarcode(
    int page,
    int limit,
    String searchQuery,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('${dotenv.env['SERVER_URL']}product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        // Map res = jsonDecode(response.body);
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i].barcode.toString().toLowerCase().contains(searchQuery.toString().toLowerCase())) {
            print(prods[i].barcode);
            filteredItems.add(prods[i]);
            //  print(filteredItems.length);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<List<dynamic>?> getProdListbyVitamin(
    int page,
    int limit,
    String searchQuery,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/product/?page=$page&page_size=$limit'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));

        List<Product> prods = (res['results'] as List).map((data) => Product.fromJson(data)).toList();
        List<dynamic> filteredItems = [];
        for (int i = 0; i < prods.length; i++) {
          if (prods[i].category.toString().toLowerCase().contains(searchQuery.toString().toLowerCase())) {
            filteredItems.add(prods[i]);
          }
        }
        return filteredItems;
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }
}
