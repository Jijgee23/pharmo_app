import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/order_detail.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PharmacyList extends StatefulWidget {
  const PharmacyList({super.key});

  @override
  State<PharmacyList> createState() => _PharmacyListState();
}

class _PharmacyListState extends State<PharmacyList> {
  final List<Pharm> _pharmList = <Pharm>[];
  final _searchController = TextEditingController();
  int _basketId = 0;
  String pharmId = '';
  String searchQuery = '';
  List<Pharm> filteredItems = [];
  List<Pharm> _displayItems = [];
  @override
  void initState() {
    getPharmacyList();
    setState(() {
      _displayItems = _pharmList;
    });
    getBasketId();
    super.initState();
  }

  getBasketId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('http://192.168.88.39:8000/api/v1/get_basket/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      await prefs.setInt('basket_id', res['id']);
      setState(() {
        _basketId = res['id'];
      });
      print(_basketId);
    }
  }

  getPharmacyList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('http://192.168.88.39:8000/api/v1/seller/pharmacy_list/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> pharms = data['pharmacies'];
      for (int i = 0; i < pharms.length; i++) {
        setState(() {
          _pharmList.add(Pharm(pharms[i]['id'], pharms[i]['name']));
        });
      }
    }
  }

  void searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = _searchController.text;
    });
    for (int i = 0; i < _pharmList.length; i++) {
      if (searchQuery.isNotEmpty &&
          _pharmList[i]
              .name
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        filteredItems.add(Pharm(_pharmList[i].id, _pharmList[i].name));
        setState(() {
          _displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          _displayItems = _pharmList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          flex: 1,
          child: Visibility(
            visible: true,
            child: CustomSearchBar(
              searchController: _searchController,
              title: 'Хайх',
              onChanged: searchPharmacy,
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: ListView.builder(
              itemCount: _displayItems.length,
              itemBuilder: ((context, index) {
                return Card(
                  child: ListTile(
                    onTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('pharm_id');
                      setState(() {
                        pharmId = _pharmList[index].id.toString();
                      });
                      String? token = prefs.getString('access_token');
                      final response = await http.post(
                        Uri.parse(
                            'http://192.168.88.39:8000/api/v1/seller/order/'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode(
                          {
                            'user': pharmId,
                            'basket': _basketId,
                          },
                        ),
                      );

                      if (response.statusCode == 200) {
                        final data =
                            jsonDecode(utf8.decode(response.bodyBytes));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellerOrderDetail(
                              orderId: data['orderNo'],
                              totalAmount: data['totalPrice'],
                              quantity: data['totalCount'],
                            ),
                          ),
                        );
                      } else {
                        print('status not ok');
                      }
                    },
                    leading: const Icon(
                      Icons.medical_services,
                      color: Colors.blue,
                      size: 30,
                    ),
                    title: Text(_displayItems[index].name),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ));
  }
}
