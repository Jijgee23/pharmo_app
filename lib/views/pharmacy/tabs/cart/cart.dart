import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/select_branch.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/others/empty_basket.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);

    void clearBasket(int basketId) {
      basketProvider.clearBasket(basket_id: basketId);
      basketProvider.getBasket();
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
                        : const EmptyBasket()
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      child: Text(
                        'Сагсанд ${provider.shoppingCarts.length} төрлийн бараа байна.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Button(
                          text: 'Сагс хоослох',
                          onTap: () => clearBasket(basket.id),
                          color: Colors.red.shade700
                        ),
                        Button(
                          text: 'Захиалга үүсгэх',
                          onTap: () => goto(const SelectBranchPage(), context),
                          color: Colors.green.shade700
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
