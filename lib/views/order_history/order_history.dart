import 'package:flutter/material.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/ORDERER/my_orders/my_orders.dart';
import 'package:pharmo_app/views/seller/order/seller_orders.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    final user = LocalBase.security;
    if (user == null) {
      return Center(
        child: Text('Хэрэглэгч олдсонгүй'),
      );
    }
    if (user.role == 'PA') {
      return MyOrder();
    }
    return SellerOrders();
  }
}
