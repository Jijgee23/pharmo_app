import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_select_branch.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
import 'package:provider/provider.dart';

class SellerShoppingCart extends StatefulWidget {
  const SellerShoppingCart({super.key});

  @override
  State<SellerShoppingCart> createState() => _SellerShoppingCartState();
}

class _SellerShoppingCartState extends State<SellerShoppingCart> {
  int pharmId = 0;
  late HomeProvider homeprovider;
  late BasketProvider basketProvider;
  @override
  void initState() {
    super.initState();
    homeprovider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    basketProvider.getBasket();
    basketProvider.checkQTYs();
  }

  @override
  Widget build(BuildContext context) {
    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
      gotoRemoveUntil(const SellerHomePage(), context);
    }

    return Consumer<BasketProvider>(builder: (context, provider, _) {
      final cartDatas = provider.shoppingCarts;
      final basket = provider.basket;
      return Scaffold(
        extendBody: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: cartDatas.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: cartDatas
                                .map((e) => ShoppingCartView(
                                    detail: cartDatas[cartDatas.indexOf(e)]))
                                .toList(),
                          ),
                        ),
                      )
                    : const SingleChildScrollView(child: EmptyBasket()),
              ),
              (cartDatas.isEmpty)
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15.0),
                      margin: const EdgeInsets.only(bottom: 10, top: 5),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              info(
                                  title: 'Төлөх дүн',
                                  text: '${basket.totalPrice ?? 0} ₮'),
                              info(
                                  title: 'Тоо ширхэг',
                                  text: '${basket.totalCount ?? 0}')
                            ],
                          ),
                          Container(
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
                                    onTap: () => gotoBranch(context),
                                    color: AppColors.primary),
                              ],
                            ),
                          ),
                          const SizedBox(height: kToolbarHeight)
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  gotoBranch(BuildContext context) async {
    await basketProvider.checkQTYs();
    if (basketProvider.qtys.isNotEmpty) {
      message(
          message: 'Үлдэгдэл хүрэлцэхгүй барааны тоог өөрчилнө үү!',
          context: context);
    } else {
      if (basketProvider.basket.totalCount == 0) {
        message(message: 'Сагс хоосон байна!', context: context);
      } else if (double.parse(basketProvider.basket.totalPrice.toString()) <
          10) {
        message(
            message: 'Үнийн дүн 10₮-с бага байж болохгүй!', context: context);
      } else if (homeprovider.selectedCustomerId == 0) {
        message(message: 'Захиалагч сонгоно уу!', context: context);
        homeprovider.changeIndex(0);
      } else {
        goto(const SelectSellerBranchPage(), context);
      }
    }
  }

  Widget info({required String title, required String text}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
