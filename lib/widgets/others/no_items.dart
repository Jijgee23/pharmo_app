import 'package:flutter/material.dart';

class NoItems extends StatelessWidget {
  const NoItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Үр дүн олдсонгүй...',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/6134/6134093.png',
            height: 100,
          )
        ],
      ),
    );
  }
}
