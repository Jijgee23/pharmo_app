import 'package:flutter/material.dart';

class NoResult extends StatelessWidget {
  const NoResult({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Үр дүн олдсонгүй'),
            const SizedBox(height: 15),
            Image.asset(
              'assets/icons/not-found.png',
              width: 100,
            ),
          ],
        ),
      );
  }
}
