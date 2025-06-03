import 'package:flutter/material.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/seller/seller_order_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/order_status.dart';

class ShipmentHistoryDetail extends StatelessWidget {
  final Delivery delivery;
  const ShipmentHistoryDetail({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              const SizedBox(),
              ...delivery.orders.map((order) => orderBuilder(order)),
              SizedBox(height: 50)
            ],
          ),
        ),
      ),
    );
  }

  SideAppBar appBar() => SideAppBar(text: 'Түгээлтийн дугаар: ${delivery.id}');

  orderBuilder(Order order) {
    List<String> data = [
      maybeNull(order.orderer!.name),
      maybeNull(order.orderNo),
      order.createdOn,
      order.totalCount.toString(),
      toPrice(order.totalPrice),
      getPayType(order.payType),
    ];
    List<String> titles = [
      'Захиалагч',
      'Дугаар',
      'Огноо',
      'Тоо ширхэг',
      'Дүн',
      'Төлбөрийн хэлбэр'
    ];
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.maxFinite,
      decoration: BoxDecoration(
          border: Border.all(color: grey200),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderStatusAnimation(
              process: process(order.process), status: status(order.status)),
          ...titles.map((t) => myRow(t, data[titles.indexOf(t)])),
        ],
      ),
    );
  }
}
