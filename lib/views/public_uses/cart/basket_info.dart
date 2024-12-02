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
  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          info(
              title: 'Нийт дүн',
              text: toPrice(basketProvider.basket.totalPrice)),
          info(
              title: 'Нийт тоо ширхэг',
              text: '${basketProvider.basket.totalCount ?? 0}')
        ],
      ),
    );
  }

  Widget info({required String title, required String text}) {
    final height = MediaQuery.of(context).size.height;
    final fs = height * .013;
    return Column(
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
    );
  }
}
