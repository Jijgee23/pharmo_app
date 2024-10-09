import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/select_branch.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart_view.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
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
                              color: AppColors.primary),
                          Button(
                              text: 'Захиалга үүсгэх',
                              onTap: () => gotoBranch(context),
                              color: AppColors.primary),
                        ],
                      ),
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

  gotoBranch(BuildContext c) {
    if (basketProvider.basket.totalCount == 0) {
      message(message: 'Сагс хоосон байна!', context: c);
    } else if (double.parse(basketProvider.basket.totalPrice.toString()) < 10) {
      message(
          message: 'Үнийн дүн 10₮-с бага байж болохгүй!', context: c);
    } else {
      goto(const SelectBranchPage(), c);
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
