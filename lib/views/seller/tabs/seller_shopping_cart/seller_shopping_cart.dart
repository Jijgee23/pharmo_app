import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_select_branch.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: cartDatas.isNotEmpty
                  ? Padding(
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
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
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
                            color:AppColors.primary),
                        Button(
                            text: 'Захиалга үүсгэх',
                            onTap: () =>
                                goto(const SelectSellerBranchPage(), context),
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
