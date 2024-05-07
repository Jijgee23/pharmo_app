import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/screens/shopping_cart/seller_select_branch.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerShoppingCart extends StatefulWidget {
  const SellerShoppingCart({super.key});

  @override
  State<SellerShoppingCart> createState() => _SellerShoppingCartState();
}

class _SellerShoppingCartState extends State<SellerShoppingCart> {
  int pharmId = 0;
  @override
  void initState() {
    getcustomerId();
    super.initState();
  }

  getcustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? customerId = prefs.getInt('pharmId');
    setState(() {
      pharmId = customerId!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);

    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
      goto(const SellerHomePage(), context);
    }

    void purchase(int basketId) {
      goto(const SelectSellerBranchPage(), context);
    }

    return Scaffold(
      body: Consumer<BasketProvider>(
        builder: (context, provider, _) {
          final cartDatas = provider.shoppingCarts;
          final basket = provider.basket;
          return Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 0),
                      child: Row(
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
                                      text: '${basket.totalCount}',
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
                                      text: '${basket.totalPrice} ₮',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.red)),
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
                            'Захиалах',
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
    );
  }
}
