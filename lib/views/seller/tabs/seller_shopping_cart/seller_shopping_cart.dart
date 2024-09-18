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
   // final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
      gotoRemoveUntil(const SellerHomePage(), context);
    }

    return Consumer<BasketProvider>(builder: (context, provider, _) {
      final orientaion = MediaQuery.of(context).orientation;
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
              decoration: BoxDecoration(
                  color: AppColors.cleanWhite,
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: orientaion == Orientation.landscape ? 100 : 100,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Сагсанд ${provider.shoppingCarts.length} төрлийн бараа байна.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                                text: 'Нийт тоо ширхэг: ',
                                style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 13.0),
                                children: [
                                  TextSpan(
                                      text: '${basket.totalCount ?? 0}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0)),
                                ]),
                          ),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                                text: 'Нийт төлөх дүн: ',
                                style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 13.0),
                                children: [
                                  TextSpan(
                                      text: '${basket.totalPrice ?? 0} ₮',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.red)),
                                ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button(
                        text: 'Сагс хоослох',
                        onTap: () => clearBasket(basket.id),
                      ),
                      Button(
                        text: 'Захиалах',
                        onTap: () => goto(
                          const SelectSellerBranchPage(),
                          context,
                        ),
                        color: Colors.green.shade700,
                      )
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 10, horizontal: 20),
                      //   decoration: BoxDecoration(
                      //       color: AppColors.main,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.white)),
                      //   child: InkWell(
                      //     onTap: () {
                      //       clearBasket(basket.id);
                      //     },
                      //     child: const Center(
                      //       child: Text('Сагс хоослох',
                      //           style: TextStyle(color: Colors.white)),
                      //     ),
                      //   ),
                      // ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 10, horizontal: 20),
                      //   decoration: BoxDecoration(
                      //       color: AppColors.secondary,
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(color: Colors.white)),
                      //   child: InkWell(
                      //     onTap: () =>
                      //         goto(const SelectSellerBranchPage(), context),
                      //     child: const Center(
                      //       child: Text('Захиалах',
                      //           style: TextStyle(color: Colors.white)),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
