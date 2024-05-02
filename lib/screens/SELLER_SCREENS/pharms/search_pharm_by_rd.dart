// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchPharm extends StatefulWidget {
  const SearchPharm({super.key});

  @override
  State<SearchPharm> createState() => _SearchPharmState();
}

class _SearchPharmState extends State<SearchPharm> {
  Map company = {};
  List<dynamic> branches = [];
  List<dynamic> manager = [];
  final _searchController = TextEditingController();
  fetchData(String cRd) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('access_token');
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/seller/search_pharmacy/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'cRd': cRd}));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> br = res['branches'];
        branches.clear();
        setState(() {
          company = res['company'];
          branches = br;
        });
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: CustomSearchBar(
          searchController: _searchController,
          keyboardType: TextInputType.number,
          title: 'Хайх',
          onChanged: (value) {
            if (value.length == 7) {
              setState(() {
                value = _searchController.text;
              });
              fetchData(value);
            } else {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
