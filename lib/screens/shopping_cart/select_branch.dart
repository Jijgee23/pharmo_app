import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/models/order.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/screens/shopping_cart/order_done.dart';
import 'package:pharmo_app/screens/shopping_cart/qr_code.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
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
    getCustomerBranch();
    super.initState();
  }

  void getData() async {
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

  void getCustomerBranch() async {
    List<Branch> branchList = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    String? customerId = prefs.getString('customerId');
    final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/seller/customer_branch/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'customerId': customerId}));
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    for (int i = 0; i < res.length; i++) {
      branchList.add(Branch.fromJson(res[i]));
    }
    print(res);
    await prefs.setInt('branchId', res[0]['id']);
  }

  void createOrder() async {
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
      dynamic resCheck = await basketProvider.checkQTYs();
      if (resCheck['errorType'] == 1) {
        if (_selectedRadioValue == 'L') {
          dynamic res = await basketProvider.createQR(basket_id: basketProvider.basket.id, address: _selectedAddress, pay_type: _selectedRadioValue);
          if (res['errorType'] == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QRCode()));
          } else {
            showFailedMessage(message: res['message'], context: context);
          }
        } else {
          dynamic res = await basketProvider.createOrder(basket_id: basketProvider.basket.id, address: _selectedAddress, pay_type: _selectedRadioValue);
          Order order = Order.fromJson(res['data']);
          if (res['errorType'] == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDone(orderNo: order.orderNo.toString())));
          } else {
            showFailedMessage(message: res['message'], context: context);
          }
        }
      } else {
        showFailedMessage(message: resCheck['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text(
      //     'Барааны дэлгэрэнгүй',
      //   ),
      //   actions: [
      //     IconButton(
      //         icon: const Icon(
      //           Icons.notifications,
      //           color: Colors.blue,
      //         ),
      //         onPressed: () {}),
      //     Container(
      //       margin: const EdgeInsets.only(right: 15),
      //       child: InkWell(
      //         onTap: () {
      //           print('odko');
      //         },
      //         child: badges.Badge(
      //           badgeContent: Text(
      //             '${basketProvider.count}',
      //             style: const TextStyle(color: Colors.white, fontSize: 10),
      //           ),
      //           badgeStyle: const badges.BadgeStyle(
      //             badgeColor: Colors.blue,
      //           ),
      //           child: const Icon(
      //             Icons.shopping_basket,
      //             color: Colors.red,
      //           ),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      appBar: const CustomAppBar(
        title: 'Төлбөрийн хэлбэр',
      ),
      body: ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(bottom: 5), child: const Align(alignment: Alignment.centerLeft, child: Text('Салбар сонгоно уу : '))),
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
