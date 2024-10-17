import 'package:flutter/material.dart';

class EmptyBasket extends StatelessWidget {
  const EmptyBasket({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          const Text(
            "Сагс хоосон байна ...",
          ),
          const SizedBox(height: 50),
          Image.asset(
            'assets/empty.png',
            fit: BoxFit.contain,
            height: 150,
          )
        ],
      ),
    );
  }
}
