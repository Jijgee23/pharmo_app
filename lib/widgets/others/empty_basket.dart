import 'package:flutter/material.dart';

class EmptyBasket extends StatelessWidget {
  const EmptyBasket({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: [
        Text(
          "Сагс хоосон байна",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Image.asset(
          'assets/empty.png',
          fit: BoxFit.contain,
          height: 150,
        )
      ],
    );
  }
}
