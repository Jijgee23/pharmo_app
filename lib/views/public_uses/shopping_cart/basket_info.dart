import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:provider/provider.dart';

class BasketInfo extends StatelessWidget {
  const BasketInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: false);
    final basket = basketProvider.basket;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        info(title: 'Төлөх дүн', text: toPrice(basket.totalPrice)),
        info(title: 'Тоо ширхэг', text: '${basket.totalCount ?? 0}')
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
