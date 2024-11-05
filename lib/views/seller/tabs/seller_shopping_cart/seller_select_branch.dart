// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_qr_code.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/order_done.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
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
  bool isDelivery = false;
  bool invisible = false;
  // String radioValue = '';
  String orderType = 'NODELIVERY';
  String? note;
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();
  final radioColor = const WidgetStatePropertyAll(AppColors.primary);

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
    var bd = BoxDecoration(
      border: Border.all(
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.circular(10),
    );
    return Consumer<HomeProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          appBar: const SideMenuAppbar(title: 'Захиалга үүсгэх'),
          body: Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: bd,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'NODELIVERY',
                        groupValue: orderType,
                        fillColor: radioColor,
                        onChanged: (value) {
                          setState(() {
                            isDelivery == false;
                            invisible = false;
                            orderType = value!;
                          });
                        },
                      ),
                      const Text(
                        'Очиж авах',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Radio(
                        value: 'DELIVERY',
                        fillColor: radioColor,
                        groupValue: orderType,
                        onChanged: (value) {
                          setState(() {
                            isDelivery = true;
                            orderType = value!;
                            invisible = true;
                            homeProvider.getCustomerBranch();
                          });
                        },
                      ),
                      const Text(
                        'Хүргэлтээр',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
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
                                  goto(const SellerHomePage());
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
                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    splashColor: Colors.green.shade300,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;
                                        homeProvider.selectedBranchId =
                                            provider.branchList[index].id;
                                      });
                                    },
                                    child: Container(
                                      decoration: bd,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.home,
                                              color: _selectedIndex == index
                                                  ? AppColors.secondary
                                                  : AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              provider.branchList[index].name
                                                  .toString(),
                                              style: TextStyle(
                                                color: _selectedIndex == index
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Заавал биш'),
                      ),
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
                      Container(
                        decoration: bd,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  value: 'NOW',
                                  fillColor: radioColor,
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
                                  fillColor: radioColor,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Button(
                              text: 'Захиалга үүсгэх',
                              color: AppColors.primary,
                              onTap: () {
                                if (payType == 'NOW' && orderType == 'DELIVERY') {
                                  if (_selectedIndex == -1) {
                                    message(
                                        message: 'Салбар сонгоно уу!',
                                        context: context);
                                  } else {
                                    goto(const SellerQRCode());
                                  }
                                } else if (payType == 'LATER') {
                                  createSellerOrder();
                                }
                                // if (payType == 'NOW' &&
                                //     homeProvider.orderType == 'DELIVERY') {
                                //   if (_selectedIndex == -1) {
                                //     message(
                                //         message: 'Салбар сонгоно уу!',
                                //         context: context);
                                //   } else {
                                //     goto(const SellerQRCode());
                                //   }
                                // }
                                // if (payType == 'LATER') {
                                //   createSellerOrder();
                                // }
                              })
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
    print([
      'ЗАХИАЛАГЧИЙН ID:',
      homeProvider.selectedCustomerId,
      'САЛБАРЫН ID:',
      homeProvider.selectedBranchId,
      'САГСНЫ ID',
      homeProvider.basketId,
      'ТАЙЛБАР:',
      homeProvider.note
    ]);
    try {
      final token = await getAccessToken();
      if (_selectedIndex == -1) {
        message(message: 'Салбар сонгоно уу!', context: context);
        return;
      } else {
        final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
          headers: getHeader(token),
          body: jsonEncode(
            {
              'userId': homeProvider.selectedCustomerId,
              'branchId':
                  (orderType == 'DELIVERY' && _selectedIndex != -1)
                      ? homeProvider.selectedBranchId
                      : null,
              'basket': homeProvider.basketId,
              "note": (homeProvider.note != null) ? homeProvider.note : null
            },
          ),
        );
        getApiInformation('CREATE ORDER', response);
        if (response.statusCode == 200) {
          final res = jsonDecode(utf8.decode(response.bodyBytes));
          final orderNumber = res['orderNo'];
          goto(OrderDone(orderNo: orderNumber.toString()));
          await basketProvider.clearBasket(basket_id: basketProvider.basket.id);
          setState(() {
            homeProvider.note = null;
          });
        } else {
          message(message: 'Алдаа гарлаа', context: context);
        }
      }

      // else {
      //   final response = await http.post(
      //     Uri.parse('${dotenv.env['SERVER_URL']}seller/order/'),
      //     headers: getHeader(token!),
      //     body: homeProvider.note == null
      //         ? jsonEncode(
      //             {
      //               'userId': homeProvider.selectedCustomerId,
      //             },
      //           )
      //         : jsonEncode(
      //             {
      //               'userId': homeProvider.selectedCustomerId,
      //               'note': homeProvider.note,
      //             },
      //           ),
      //   );
      //   if (response.statusCode == 200) {
      //     final res = jsonDecode(utf8.decode(response.bodyBytes));
      //     final orderNumber = res['orderNo'];
      //     await basketProvider.clearBasket(basket_id: basketProvider.basket.id);
      //     goto(OrderDone(orderNo: orderNumber.toString()));
      //   } else {
      //     message(message: 'Сагс хоосон байна', context: context);
      //   }
      // }
    } catch (e) {
      message(message: 'Захиалга үүсгэхэд алдаа гарлаа.', context: context);
    }
  }
}
