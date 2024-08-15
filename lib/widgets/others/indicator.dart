import 'package:flutter/material.dart';

class MyIndicator extends StatelessWidget {
  const MyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }
}
