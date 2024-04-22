import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/order.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/screens/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectBranchPage extends StatefulWidget {
  const SelectBranchPage({super.key});
  @override
  State<SelectBranchPage> createState() => _SelectBranchPageState();
}

class _SelectBranchPageState extends State<SelectBranchPage> {
  List<Sector> _branchList = <Sector>[];
  String _selectedRadioValue = '';
  int _selectedIndex = -1;
  int _selectedAddress = 0;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/branch'), headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _branchList = (res).map((data) => Sector.fromJson(data)).toList();
        });
      } else {
        showFailedMessage(message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  createOrder() async {
    try {
      if (_selectedRadioValue == '') {
        showFailedMessage(message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
        return;
      }
      if (_selectedIndex == -1) {
        showFailedMessage(message: 'Салбар сонгоно уу!', context: context);
        return;
      }
      final basketProvider = Provider.of<BasketProvider>(context, listen: false);
      basketProvider.checkQTYs();
      dynamic res = await basketProvider.createOrder(basket_id: basketProvider.basket.id, address: _selectedAddress, pay_type: _selectedRadioValue);
      Order order = Order.fromJson(res['data']);
      if (res['errorType'] == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDone(order: order)));
      } else {
        showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Барааны дэлгэрэнгүй',
          ),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.blue,
                ),
                onPressed: () {}),
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: () {
                  print('odkooooooo');
                },
                child: badges.Badge(
                  badgeContent: Text(
                    '${basketProvider.count}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.shopping_basket,
                    color: Colors.red,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(15),
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _branchList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () async {
                          setState(() {
                            _selectedIndex = index;
                            _selectedAddress = _branchList[index].id;
                          });
                        },
                        tileColor: _selectedIndex == index ? Colors.grey : null,
                        leading: const Icon(Icons.home),
                        title: Text(_branchList[index].name.toString()),
                        subtitle: Text(_branchList[index].address!["address"]),
                      ),
                    );
                  }),
            ),
            Card(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Column(children: [
                  const Align(alignment: Alignment.centerLeft, child: Text('Төлбөрийн хэлбэр сонгоно уу : ')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'L',
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Бэлнээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Radio(
                        value: 'C',
                        groupValue: _selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedRadioValue = value!;
                          });
                        },
                      ),
                      const Text(
                        'Зээлээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton.icon(
                onPressed: () {
                  createOrder();
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  'Захиалга үүсгэх',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
