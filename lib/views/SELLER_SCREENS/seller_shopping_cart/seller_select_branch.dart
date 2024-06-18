// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/seller_shopping_cart/seller_qr_code.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
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
  String payType = 'LATER';
  bool invisible = false;
  String? note;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    homeProvider.getCustomerBranch();
    basketProvider.getBasket();
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
                      groupValue: homeProvider.orderType,
                      onChanged: (value) {
                        setState(() {
                          invisible = !invisible;
                          homeProvider.orderType = value!;
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
                      groupValue: homeProvider.orderType,
                      onChanged: (value) {
                        setState(() {
                          homeProvider.orderType = value!;
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
                  height: MediaQuery.of(context).size.height * 0.3,
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
                                    groupValue: payType,
                                    onChanged: (String? value) {
                                      setState(() {
                                        payType = value!;
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
                                    groupValue: payType,
                                    onChanged: (value) {
                                      setState(() {
                                        payType = value!;
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
                              if (payType == 'NOW' &&
                                  homeProvider.orderType == 'NODELIVERY') {
                                goto(const SellerQRCode(), context);
                              }
                              if (payType == 'NOW' &&
                                  homeProvider.orderType == 'DELIVERY') {
                                if (_selectedIndex == -1) {
                                  showFailedMessage(
                                      message: 'Салбар сонгоно уу!',
                                      context: context);
                                } else {
                                  goto(const SellerQRCode(), context);
                                }
                              }
                              if (payType == 'LATER') {
                                createSellerOrder();
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
      if (homeProvider.orderType == 'DELIVERY') {
        if (_selectedIndex == -1) {
          showFailedMessage(message: 'Салбар сонгоно уу!', context: context);
          return;
        } else {
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
                  ),
          );
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
      } else {
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
                  },
                )
              : jsonEncode(
                  {
                    'userId': homeProvider.selectedCustomerId,
                    'note': homeProvider.note,
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
