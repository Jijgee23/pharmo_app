import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/shopping_cart/select_branch.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);

    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
      Navigator.pop(context);
    }

    void purchase(int basketId) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectBranchPage()));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 850.0;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: AppColors.primary),
          centerTitle: true,
          title: const Text(
            'Миний сагс',
            style: TextStyle(fontSize: 16),
          ),
        actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
                },
                child: badges.Badge(
                  badgeContent: Text(
                    "${basketProvider.count}",
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.shopping_basket,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SizedBox(
            width: double.infinity,
            child: Center(
                child: SizedBox(
              width: screenWidth <= maxWidth ? screenWidth : maxWidth,
              child: Consumer<BasketProvider>(
                builder: (context, provider, _) {
                  final cartDatas = provider.shoppingCarts;
                  final basket = provider.basket;
                  return Column(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          cartDatas.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: cartDatas.length,
                                    itemBuilder: (context, index) {
                                      //item-ийг дамжуулж cartview үүсгэх
                                      return ShoppingCartView(detail: cartDatas[index] ?? {});
                                    },
                                  ),
                                )
                              : const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Text(
                                      "Сагс хоосон байна ...",
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Сагсанд ${provider.shoppingCarts.length} төрлийн бараа байна.',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(text: 'Нийт тоо ширхэг: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                    TextSpan(text: '${basket.totalCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                  ]),
                                ),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(text: 'Нийт төлөх дүн: ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                    TextSpan(text: '${basket.totalPrice} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.red)),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  clearBasket(basket.id);
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                ),
                                label: const Text('Сагс хоослох'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  purchase(basket.id);
                                },
                                icon: const Icon(
                                  Icons.paid_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Төлбөр төлөх',
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
                );
                },
              ),
          ),
        ),
      ),
    );
  }
}
