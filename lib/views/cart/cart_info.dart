import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/ui_help/container.dart';
import 'package:provider/provider.dart';

class CartInfo extends StatefulWidget {
  const CartInfo({super.key});

  @override
  State<CartInfo> createState() => _CartInfoState();
}

class _CartInfoState extends State<CartInfo> {
  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // theme
    void clearBasket() async {
      await basketProvider.clearBasket();
      await basketProvider.getBasket();
    }

    return Ctnr(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              info(
                  title: 'Нийт дүн',
                  text: toPrice(basketProvider.basket.totalPrice))
            ],
          ),
          info(
              title: 'Нийт тоо ширхэг',
              text: '${basketProvider.basket.totalCount ?? 0}'),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => clearBasket(),
            child: const Icon(Icons.delete, color: Colors.red, size: 30),
          ),
        ],
      ),
    );
  }

  Widget info({required String title, required String text}) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    // theme
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: black,
            fontSize: fs,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: black.withOpacity(.7),
            fontSize: fs,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
