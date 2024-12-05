import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/public_uses/cart/basket_info.dart';
import 'package:pharmo_app/views/public_uses/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/public_uses/cart/seller_order_sheet.dart';
import 'package:pharmo_app/views/public_uses/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
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
      basketProvider.clearBasket(basketId: basketId);
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
                    // Сагсны мэдээлэл
                    basketIsEmpty ? const SizedBox() : const BasketInfo(),
                    // Сагсанд байгаа бараанууд
                    cartDatas.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: cartDatas.length,
                              itemBuilder: (context, index) {
                                return CartItem(detail: cartDatas[index] ?? {});
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
        final home = Provider.of<HomeProvider>(context, listen: false);
        if (home.userRole == 'PA') {
          Get.bottomSheet(const PharmOrderSheet());
        } else {
          Get.bottomSheet(const SellerOrderSheet());
        }
      }
    }
  }
}
