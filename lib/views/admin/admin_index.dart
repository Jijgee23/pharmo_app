import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class AdminIndex extends StatefulWidget {
  const AdminIndex({super.key});

  @override
  State<AdminIndex> createState() => _AdminIndexState();
}

class _AdminIndexState extends State<AdminIndex> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Админ'),
      ),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: 2,
        itemBuilder: (context, idx) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary,
            ),
            child: Text(idx.toString()),
          );
        },
      ),
    );
  }
}
