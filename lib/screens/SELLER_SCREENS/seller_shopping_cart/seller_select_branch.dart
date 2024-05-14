// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/screens/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
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
  List<Branch> branchList = <Branch>[];
  int _selectedIndex = -1;
  int _selectedAddress = 0;
  String _selectedRadioValue = '';
  bool invisible = false;
  late HomeProvider homeProvider;

  @override
  void initState() {
    getCustomerBranch();
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
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
          body: jsonEncode({'customerId': homeProvider.selectedCustomerId}));
      branchList.clear();
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          for (int i = 0; i < res.length; i++) {
            branchList.add(Branch.fromJson(res[i]));
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
              'userId': homeProvider.selectedCustomerId,
              'branchId': _selectedAddress,
              'basket': homeProvider.basketId,
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
              'userId': homeProvider.selectedCustomerId,
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
    return Consumer<HomeProvider>(
      builder: (_, sellerprovider, child) {
        return Scaffold(
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
                    child: branchList.isEmpty
                        ? Column(
                            children: [
                              const Text('Захиалагч сонгоно уу!'),
                              TextButton(
                                onPressed: () {
                                  homeProvider.changeIndex(0);
                                  goto(const SellerHomePage(), context);
                                },
                                child: const Text(
                                  'Сонгох',
                                  style: TextStyle(
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: branchList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      _selectedAddress = branchList[index].id;
                                    });
                                  },
                                  tileColor: _selectedIndex == index
                                      ? Colors.grey
                                      : null,
                                  leading: const Icon(Icons.home),
                                  title:
                                      Text(branchList[index].name.toString()),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
