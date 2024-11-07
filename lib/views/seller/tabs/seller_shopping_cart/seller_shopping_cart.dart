import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/basket_info.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_qr_code.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_select_branch.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
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
                                    onTap: () => placeOrder(homeprovider),
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

  placeOrder(HomeProvider homeProvider) {
    Get.bottomSheet(const OrderPlacer());
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

class OrderPlacer extends StatefulWidget {
  const OrderPlacer({
    super.key,
  });

  @override
  State<OrderPlacer> createState() => _OrderPlacerState();
}

class _OrderPlacerState extends State<OrderPlacer> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
  }

  String payType = '';
  setPayType(String v) {
    setState(() {
      payType = v;
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
      } else if (homeProvider.selectedCustomerId == 0) {
        message(message: 'Захиалагч сонгоно уу!', context: context);
        homeProvider.changeIndex(0);
      } else {
        goto(const SelectSellerBranchPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final basket = basketProvider.basket;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Wrap(
        runSpacing: 15,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Сагсны мэдээлэл:'),
          ),
          const BasketInfo(),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Заавал биш:'),
          ),
          CustomTextField(
            controller: noteController,
            hintText: 'Тайлбар',
            onChanged: (v) => homeProvider.setNote(v!),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Төлбөрийн хэлбэр сонгоно уу : '),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: .8),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    myRadio('T', 'Дансаар'),
                    myRadio('C', 'Бэлнээр'),
                    myRadio('L', 'Зээлээр'),
                  ],
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Захиалах',
            ontap: () async {
              if (basketProvider.basket.totalCount == 0) {
                message(message: 'Сагс хоосон байна!', context: context);
              } else if (double.parse(
                      basketProvider.basket.totalPrice.toString()) <
                  10) {
                message(
                    message: 'Үнийн дүн 10₮-с бага байж болохгүй!',
                    context: context);
              } else if (homeProvider.selectedCustomerId == 0) {
                message(message: 'Захиалагч сонгоно уу!', context: context);
                homeProvider.changeIndex(0);
              } else {
                await basketProvider.checkQTYs();
                if (payType == '') {
                  message(
                      message: 'Төлбөрийн хэлбэр сонгоно уу!',
                      context: context);
                } else if (payType == 'A') {
                  goto(const SellerQRCode());
                } else {
                  homeProvider.createSellerOrder(context, payType);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget myRadio(String val, String title) {
    return Row(
      children: [
        Radio(
          value: val,
          groupValue: payType,
          onChanged: (String? value) {
            setPayType(value!);
          },
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14.0),
        )
      ],
    );
  }

  Widget info({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
