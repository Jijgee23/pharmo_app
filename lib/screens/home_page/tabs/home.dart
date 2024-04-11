import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const Text('Home Tab'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('BTn'),
          ),
        ],
      ),
    );
  }
}
