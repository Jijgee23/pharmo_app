import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/cart/cart_info.dart';
import 'package:pharmo_app/views/main/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/main/cart/seller_order_sheet.dart';
import 'package:pharmo_app/views/main/cart/cart_item.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late BasketProvider basketProvider;
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  void initState() {
    super.initState();
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    init();
  }

  init() {
    WidgetsBinding.instance.addPostFrameCallback((cb) async {
      setLoading(true);
      await basketProvider.getBasket();
      await basketProvider.checkQTYs();
      setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BasketProvider>(
      builder: (context, provider, _) {
        final cartDatas = provider.shoppingCarts;
        final basket = provider.basket;
        final basketIsEmpty = (basket.totalCount == 0 || basket.items!.isEmpty);
        return DataScreen(
          loading: loading,
          empty: basketIsEmpty,
          customEmpty: const Center(child: EmptyBasket()),
          child: Container(
            margin: const EdgeInsets.only(bottom: kToolbarHeight),
            child: Column(
              children: [
                const SizedBox(height: Sizes.smallFontSize),
                // Сагсны мэдээлэл
                const CartInfo(),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartDatas.length,
                    itemBuilder: (context, index) {
                      return CartItem(detail: cartDatas[index] ?? {});
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CustomButton(
                    text: 'Захиалга үүсгэх',
                    ontap: () async => await placeOrder(context),
                  ),
                ),
                SizedBox(
                  height: (Platform.isIOS) ? 30 : 20,
                ),
              ],
            ),
          ),
        );

        //  Scaffold(
        //   body: basketIsEmpty
        //       ? const Center(
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               EmptyBasket(),
        //             ],
        //           ),
        //         )
        //       : Container(
        //           margin: const EdgeInsets.only(bottom: kToolbarHeight),
        //           child: Column(
        //             children: [
        //               const SizedBox(height: Sizes.smallFontSize),
        //               // Сагсны мэдээлэл
        //               const CartInfo(),
        //               Expanded(
        //                 child: ListView.builder(
        //                   itemCount: cartDatas.length,
        //                   itemBuilder: (context, index) {
        //                     return CartItem(detail: cartDatas[index] ?? {});
        //                   },
        //                 ),
        //               ),
        //               Container(
        //                 margin: const EdgeInsets.only(bottom: 10),
        //                 child: CustomButton(
        //                   text: 'Захиалга үүсгэх',
        //                   ontap: () async => await placeOrder(context),
        //                 ),
        //               ),
        //               SizedBox(
        //                 height: (Platform.isIOS) ? 30 : 20,
        //               ),
        //             ],
        //           ),
        //         ),
        // );
      },
    );
  }

  placeOrder(BuildContext c) async {
    await basketProvider.checkQTYs();
    if (basketProvider.qtys.isNotEmpty) {
      message('Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!');
    } else {
      if (double.parse(basketProvider.basket.totalPrice.toString()) < 10) {
        message('Үнийн дүн 10₮-с бага байж болохгүй!');
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
