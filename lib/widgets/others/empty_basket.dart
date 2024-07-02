import 'package:flutter/material.dart';

class EmptyBasket extends StatelessWidget {
  const EmptyBasket({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Сагс хоосон байна ...",
          ),
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/10621/10621365.png',
            fit: BoxFit.contain,
            height: 150,
          )
        ],
      ),
    );
  }
}
