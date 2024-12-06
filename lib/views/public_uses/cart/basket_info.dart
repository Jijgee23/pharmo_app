import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:provider/provider.dart';

class BasketInfo extends StatefulWidget {
  const BasketInfo({super.key});

  @override
  State<BasketInfo> createState() => _BasketInfoState();
}

class _BasketInfoState extends State<BasketInfo> {
  var decoration = BoxDecoration(
    boxShadow: shadow(),
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
  );
  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);

    void clearBasket() async {
      await basketProvider.clearBasket();
      await basketProvider.getBasket();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              info(
                  title: 'Нийт дүн',
                  text: toPrice(basketProvider.basket.totalPrice)),
            ],
          ),
          info(
              title: 'Нийт тоо ширхэг',
              text: '${basketProvider.basket.totalCount ?? 0}'),
          Container(
            decoration: decoration,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () => clearBasket(),
              child: const Icon(
                Icons.delete,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget info({required String title, required String text}) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: fs,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: fs,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
