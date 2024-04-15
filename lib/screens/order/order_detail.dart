import 'package:flutter/material.dart';

class SellerOrderDetail extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final int quantity;
  const SellerOrderDetail(
      {super.key,
      required this.orderId,
      required this.totalAmount,
      required this.quantity});

  @override
  State<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends State<SellerOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Захиалгын дугаар: ${widget.orderId}'),
            Text('Захиалгын дүн: ${widget.totalAmount}'),
            Text('Нийт захиалсан барааны тоо: ${widget.quantity}'),
          ],
        ),
      ),
    );
  }
}
