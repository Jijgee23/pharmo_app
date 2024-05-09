import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pharmo_app/models/pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/favorites.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/order/order_history_list.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SellerCustomerOrderHisrtory extends StatefulWidget {
  const SellerCustomerOrderHisrtory({super.key});

  @override
  State<SellerCustomerOrderHisrtory> createState() =>
      _SellerCustomerOrderHisrtoryState();
}

class _SellerCustomerOrderHisrtoryState
    extends State<SellerCustomerOrderHisrtory> {
  @override
  void initState() {
    getPharmacyList();
    setState(() {
      displayItems = pharmList;
    });
    super.initState();
  }

  List<Pharm> pharmList = <Pharm>[];
  List<Pharm> displayItems = <Pharm>[];
  List<Pharm> filteredItems = <Pharm>[];
  TextEditingController searchController = TextEditingController();
  searchPharmacy(String searchQuery) {
    filteredItems.clear();
    setState(() {
      searchQuery = searchController.text;
    });
    for (int i = 0; i < pharmList.length; i++) {
      if (searchQuery.isNotEmpty &&
          pharmList[i].name.toLowerCase().contains(searchQuery.toLowerCase())) {
        filteredItems.add(
            Pharm(pharmList[i].id, pharmList[i].name,
            pharmList[i].isCustomer, pharmList[i].badCnt));
        setState(() {
          displayItems = filteredItems;
        });
      }
      if (searchQuery.isEmpty) {
        setState(() {
          displayItems = pharmList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Эмийн сангууд'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: CustomSearchBar(
                  searchController: searchController,
                  title: 'Хайх',
                  onChanged: (value) {
                    searchPharmacy(value);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: ListView.builder(
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(displayItems[index].name),
                      trailing: IconButton(
                          onPressed: () {
                            goto(
                                FavoriteList(
                                    customerId: displayItems[index].id),
                                context);
                          },
                          icon: const Icon(
                            Icons.favorite,
                            color: AppColors.secondary,
                          )),
                      onTap: () {
                        goto(
                            OrderhistoryListPage(
                                customerId: displayItems[index].id),
                            context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getPharmacyList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}seller/pharmacy_list/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> pharms = data['pharmacies'];
      pharmList.clear();
      for (int i = 0; i < pharms.length; i++) {
        setState(() {
          pharmList.add(Pharm(
                pharms[i]['id'],
                pharms[i]['name'],
                pharms[i]['isCustomer'],
                pharms[i]['badCnt'],
              ),
            );
          },
        );
      }
    }
  }
}
