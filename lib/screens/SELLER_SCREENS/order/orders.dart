import 'package:flutter/material.dart';
import 'package:pharmo_app/models/order.dart';

class SellerOrders extends StatelessWidget {
  List<Order> order = [];
  SellerOrders({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListView.builder(itemBuilder: ((context, index) {
              return Card(
                child: ListTile(
                  title: Text(order[index].orderNo.toString()),
                  subtitle: Text(order[index].createdOn),
                ),
              );
            }))
          ],
        ),
      ),
    );
  }
}
