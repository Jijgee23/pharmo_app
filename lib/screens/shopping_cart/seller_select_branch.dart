// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/screens/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectSellerBranchPage extends StatefulWidget {
  const SelectSellerBranchPage({super.key});
  @override
  State<SelectSellerBranchPage> createState() => _SelectSellerBranchPageState();
}

class _SelectSellerBranchPageState extends State<SelectSellerBranchPage> {
  List<Branch> sellerBranchList = <Branch>[];
  int _selectedIndex = -1;
  int _selectedAddress = 0;
  int _basketId = 0;
  String _selectedRadioValue = '';
  bool invisible = false;
  int? pharmId = 0;

  @override
  void initState() {
    getCustomerBranch();
    getBasketId();
    getcustomerId();
    super.initState();
  }

  getcustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? customerId = prefs.getInt('pharmId');
    setState(() {
      pharmId = customerId;
    });
  }

  getBasketId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['SERVER_URL']}get_basket/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    final res = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      setState(() {
        _basketId = res['id'];
      });
    }
  }

  getCustomerBranch() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'customerId': pharmId}));
      sellerBranchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          for (int i = 0; i < res.length; i++) {
            sellerBranchList.add(Branch.fromJson(res[i]));
          }
        });
        await prefs.setInt('branchId', res[0]['id']);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа.', context: context);
    }
  }

  createSellerOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (_selectedRadioValue == 'L') {
        if (_selectedIndex == -1) {
          showFailedMessage(message: 'Салбар сонгоно уу.', context: context);
        }
        final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
            {
              'userId': pharmId,
              'branchId': _selectedAddress,
              'basket': _basketId,
            },
          ),
        );
        if (response.statusCode == 200) {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          final orderNumber = res['orderNo'];
          showSuccessMessage(
              message: 'Захиалга амжилттай  үүслээ.', context: context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDone(orderNo: orderNumber.toString()),
            ),
          );
        } else {
          showFailedMessage(message: 'Сагс хоосон байна', context: context);
        }
      }
      if (_selectedRadioValue == 'C') {
        final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
            {
              'userId': pharmId,
            },
          ),
        );
        if (response.statusCode == 200) {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          final orderNumber = res['orderNo'];
          showSuccessMessage(
              message: 'Захиалга амжилттай  үүслээ.', context: context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDone(orderNo: orderNumber.toString()),
            ),
          );
        } else {
          showFailedMessage(message: 'Сагс хоосон байна', context: context);
        }
      }
    } catch (e) {
      showFailedMessage(
          message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    //  final basketProvider = Provider.of<BasketProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Захиалга үүсгэх',
        ),
        body: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: 'L',
                      groupValue: _selectedRadioValue,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRadioValue = value!;
                          invisible = !invisible;
                          getCustomerBranch();
                        });
                      },
                    ),
                    const Text(
                      'Хүргэлтээр',
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
                          invisible = false;
                        });
                      },
                    ),
                    const Text(
                      'Очиж авах',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Visibility(
                  visible: invisible,
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Салбар сонгоно уу : '))),
                ),
                Visibility(
                  visible: invisible,
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: sellerBranchList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                                _selectedAddress = sellerBranchList[index].id;
                              });
                            },
                            tileColor:
                                _selectedIndex == index ? Colors.grey : null,
                            leading: const Icon(Icons.home),
                            title:
                                Text(sellerBranchList[index].name.toString()),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      createSellerOrder();
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
