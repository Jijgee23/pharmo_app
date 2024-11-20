import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/basket_info.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
import 'package:pharmo_app/widgets/others/my_radio.dart';
import 'package:provider/provider.dart';

class ShoppingCartHome extends StatefulWidget {
  const ShoppingCartHome({super.key});

  @override
  State<ShoppingCartHome> createState() => _ShoppingCartHomeState();
}

class _ShoppingCartHomeState extends State<ShoppingCartHome> {
  late BasketProvider basketProvider;

  @override
  void initState() {
    super.initState();
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    basketProvider.getBasket();
    basketProvider.checkQTYs();
  }

  getBasket() async {
    await basketProvider.getBasket();
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);

    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
    }

    return Consumer<BasketProvider>(
      builder: (context, provider, _) {
        final cartDatas = provider.shoppingCarts;
        final basket = provider.basket;
        final basketIsEmpty = basketProvider.basket.totalCount == 0;
        return Container(
          margin: const EdgeInsets.only(bottom: kToolbarHeight),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    basketIsEmpty ? const SizedBox() : const BasketInfo(),
                    cartDatas.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: cartDatas.length,
                              itemBuilder: (context, index) {
                                return ShoppingCartView(
                                    detail: cartDatas[index] ?? {});
                              },
                            ),
                          )
                        : const Center(child: EmptyBasket())
                  ],
                ),
              ),
              (cartDatas.isEmpty)
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Button(
                                text: 'Сагс хоослох',
                                onTap: () => clearBasket(basket.id),
                                color: AppColors.primary),
                            Button(
                              text: 'Захиалга үүсгэх',
                              color: AppColors.primary,
                              onTap: () async => await placeOrder(context),
                            ),
                          ],
                        ),
                      ),
                    ),
              SizedBox(
                height: (Platform.isIOS) ? 30 : 20,
              ),
            ],
          ),
        );
      },
    );
  }

  placeOrder(BuildContext c) async {
    await basketProvider.checkQTYs();
    if (basketProvider.qtys.isNotEmpty) {
      message(
          message: 'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
          context: context);
    } else {
      if (double.parse(basketProvider.basket.totalPrice.toString()) < 10) {
        message(
            message: 'Үнийн дүн 10₮-с бага байж болохгүй!', context: context);
      } else {
        Get.bottomSheet(const OrderSheet());
      }
    }
  }
}

class OrderSheet extends StatefulWidget {
  const OrderSheet({super.key});

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
  }

  String deliveryType = '';
  String payType = '';
  int selectedBranchId = -1;
  setDeliverType(String v) {
    setState(() {
      deliveryType = v;
    });
  }

  setPayType(String v) {
    setState(() {
      payType = v;
    });
  }

  setBranch(String v, dynamic id) {
    setState(() {
      selectedBranch = v;
      selectedBranchId = id;
    });
  }

  String selectedBranch = 'Салбар сонгоно уу!';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Wrap(
        runSpacing: 15,
        children: [
          Container(
            decoration: bd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MyRadio(
                  value: 'N',
                  groupValue: deliveryType,
                  title: 'Очиж авах',
                  onChanged: (v) => setDeliverType(v!),
                ),
                MyRadio(
                  value: 'D',
                  groupValue: deliveryType,
                  title: 'Хүргэлтээр',
                  onChanged: (v) => setDeliverType(v!),
                )
              ],
            ),
          ),
          (deliveryType == 'D')
              ? InkWell(
                  onTap: selectBranch,
                  child: Container(
                      decoration: bd,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedBranch),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      )),
                )
              : const SizedBox(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Заавал биш:'),
          ),
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          Container(
            decoration: bd,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MyRadio(
                  value: 'C',
                  groupValue: payType,
                  title: 'Бэлнээр',
                  onChanged: (v) => setPayType(v!),
                ),
                MyRadio(
                  value: 'L',
                  groupValue: payType,
                  title: 'Зээлээр',
                  onChanged: (v) => setPayType(v!),
                )
              ],
            ),
          ),
          CustomButton(text: 'Захиалах', ontap: () => order())
        ],
      ),
    );
  }

  selectBranch() {
    showMenu(
      color: Colors.white,
      context: context,
      position: const RelativeRect.fromLTRB(0, 500, 0, 0),
      items: homeProvider.branches
          .map(
            (e) => PopupMenuItem(
              onTap: () => setBranch(e.name!, e.id),
              child: Row(
                children: [
                  Text(e.name!),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  order() async {
    await basketProvider.checkQTYs();
    if (basketProvider.qtys.isNotEmpty) {
      message(
          message: 'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
          context: context);
    } else {
      createOrder();
    }
  }

  createOrder() async {
    await basketProvider.checkQTYs();
    if (deliveryType == '') {
      message(message: 'Хүргэлтийн хэлбэр сонгоно уу!', context: context);
    } else if (deliveryType == 'D') {
      if (selectedBranchId == -1) {
        message(message: 'Салбар сонгоно уу!', context: context);
      } else {
        if (payType == '') {
          message(message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
        } else if (payType == 'C') {
          await basketProvider.createQR(
            basket_id: basketProvider.basket.id,
            branch_id: selectedBranchId,
            note: noteController.text,
            context: context,
          );
        } else if (payType == 'L') {
          await basketProvider.createOrder(
              basket_id: basketProvider.basket.id,
              branch_id: selectedBranchId,
              note: noteController.text,
              context: context);
        }
      }
    } else if (deliveryType == 'N') {
      if (payType == '') {
        message(message: 'Төлбөрийн хэлбэр сонгоно уу!', context: context);
      } else if (payType == 'C') {
        await basketProvider.createQR(
          basket_id: basketProvider.basket.id,
          branch_id: selectedBranchId,
          note: noteController.text,
          context: context,
        );
      } else if (payType == 'L') {
        await basketProvider.createOrder(
            basket_id: basketProvider.basket.id,
            branch_id: selectedBranchId,
            note: noteController.text,
            context: context);
      }
    }

    // if (payType == 'C') {
    //   if (selectedBranchId == -1 && deliveryType == 'D') {
    //     message(message: 'Салбар сонгоно уу!', context: context);
    //   } else {
    //     await basketProvider.createOrder(
    //         basket_id: basketProvider.basket.id,
    //         branch_id: selectedBranchId,
    //         note: noteController.text,
    //         context: context);
    //   }
    // } else {
    //   if (selectedBranchId == -1 && deliveryType == 'D') {
    //     message(message: 'Салбар сонгоно уу!', context: context);
    //   } else {
    //     await basketProvider.createQR(
    //       basket_id: basketProvider.basket.id,
    //       branch_id: selectedBranchId,
    //       note: noteController.text,
    //       context: context,
    //     );
    //   }
    // }
  }

  var bd = BoxDecoration(
    border: Border.all(color: AppColors.primary, width: .8),
    borderRadius: BorderRadius.circular(5),
  );
}
