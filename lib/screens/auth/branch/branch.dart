import 'package:flutter/material.dart';

class CustomerBranchInfo extends StatelessWidget {
  final int id;
  final String name;
  const CustomerBranchInfo({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Салбарийн дугаар: $id'),
            Text('Салбарийн нэр: $name'),
          ],
        ),
      ),
    );
  }
}
