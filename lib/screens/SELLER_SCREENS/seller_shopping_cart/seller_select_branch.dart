// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_shopping_cart/seller_qr_code.dart';
import 'package:pharmo_app/screens/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/custom_text_filed.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectSellerBranchPage extends StatefulWidget {
  const SelectSellerBranchPage({super.key});
  @override
  State<SelectSellerBranchPage> createState() => _SelectSellerBranchPageState();
}

class _SelectSellerBranchPageState extends State<SelectSellerBranchPage> {
  int _selectedIndex = -1;
  String _selectedRadioValue = 'NODELIVERY';
  String _selectedRadioValue2 = '';
  bool invisible = false;
  String? note;
  late HomeProvider homeProvider;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getCustomerBranch();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, provider, child) {
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
                      value: 'DELIVERY',
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
                      value: 'NODELIVERY',
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
                    child: provider.branchList.isEmpty
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
                            itemCount: provider.branchList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      homeProvider.selectedBranchId =
                                          provider.branchList[index].id;
                                    });
                                  },
                                  leading: Icon(
                                    Icons.home,
                                    color: _selectedIndex == index
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  title: Text(provider.branchList[index].name
                                      .toString()),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.27,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: noteController,
                        hintText: 'Тайлбар',
                        onChanged: (value) {
                          setState(() {
                            homeProvider.note = noteController.text;
                            note = noteController.text;
                          });
                        },
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Төлбөрийн хэлбэр сонгоно уу : '),
                      ),
                      Card(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio(
                                    value: 'NOW',
                                    groupValue: _selectedRadioValue2,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedRadioValue2 = value!;
                                        homeProvider.payType = value;
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
                                    value: 'LATER',
                                    groupValue: _selectedRadioValue2,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRadioValue2 = value!;
                                        homeProvider.payType = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Зээлээр',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              if (_selectedRadioValue2 == '') {
                                showFailedMessage(
                                    context: context,
                                    message: 'Төлбөрийн хэлбэр сонгоно уу!');
                              }
                              if (_selectedRadioValue2 == 'LATER') {
                                createSellerOrder();
                              }
                              if (_selectedRadioValue2 == 'NOW') {
                                goto(const SellerQRCode(), context);
                              }
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
              ],
            ),
          ),
        );
      },
    );
  }

  createSellerOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (_selectedRadioValue == 'DELIVERY') {
        if (_selectedIndex == -1) {
          showFailedMessage(message: 'Салбар сонгоно уу.', context: context);
        }
        final response = await http.post(
            Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: homeProvider.note == null
                ? jsonEncode(
                    {
                      'userId': homeProvider.selectedCustomerId,
                      'branchId': homeProvider.selectedBranchId,
                      'basket': homeProvider.basketId,
                    },
                  )
                : jsonEncode(
                    {
                      'userId': homeProvider.selectedCustomerId,
                      'branchId': homeProvider.selectedBranchId,
                      'basket': homeProvider.basketId,
                      "note": homeProvider.note
                    },
                  ));
        print(response.statusCode);
        if (response.statusCode == 200) {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          final orderNumber = res['orderNo'];
          showSuccessMessage(
              message: 'Захиалга амжилттай  үүслээ.', context: context);
          goto(OrderDone(orderNo: orderNumber.toString()), context);
          setState(() {
            homeProvider.note = null;
          });
        } else {
          showFailedMessage(message: 'Сагс хоосон байна', context: context);
        }
      }
      if (_selectedRadioValue == 'NODELIVERY') {
        final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
            {
              'userId': homeProvider.selectedCustomerId,
              'note': noteController.text,
            },
          ),
        );
        if (response.statusCode == 200) {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          final orderNumber = res['orderNo'];
          showSuccessMessage(
              message: 'Захиалга амжилттай  үүслээ.', context: context);
          goto(OrderDone(orderNo: orderNumber.toString()), context);
        } else {
          showFailedMessage(message: 'Сагс хоосон байна', context: context);
        }
      }
    } catch (e) {
      showFailedMessage(
          message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
    }
  }
}
