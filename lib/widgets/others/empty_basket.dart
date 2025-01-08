import 'package:flutter/material.dart';

class EmptyBasket extends StatelessWidget {
  const EmptyBasket({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Сагс хоосон байна ...",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
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
