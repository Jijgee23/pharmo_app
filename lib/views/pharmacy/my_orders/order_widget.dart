import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/myorder_provider.dart';
import 'package:pharmo_app/controller/models/my_order.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/constants.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/my_orders/my_order_detail.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:provider/provider.dart';

class OrderWidget extends StatelessWidget {
  final MyOrderModel order;
  const OrderWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, op, child) {
      return InkWell(
        onTap: () => goto(MyOrderDetail(order: order)),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: border10,
            border: Border.all(color: grey300),
          ),
          padding: padding15,
          child: Column(
            spacing: 7.5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: primary.withOpacity(.3),
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.home, color: primary),
                        const SizedBox(width: 5),
                        Text(order.supplier!,
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  TitleContainer(
                    child: Col(
                        t1: toPrice(order.totalPrice.toString()),
                        t2: '#${order.orderNo.toString()}'),
                  ),
                ],
              ),
              Container(
                height: 1.8,
                width: double.maxFinite,
                color: grey300,
              ),
              infoText(order.status),
              infoText(order.process),
              infoText(order.createdOn.toString().substring(0, 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (order.process == 'Бэлэн болсон' ||
                          order.process == 'Түгээлтэнд гарсан')
                      ? acceptButton(order, context)
                      : const SizedBox(),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  confirmOrder(int orderId, BuildContext context) async {
    final orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    dynamic res = await orderProvider.confirmOrder(orderId);
    message(res['message']);
  }

  Widget acceptButton(MyOrderModel order, BuildContext context) {
    return ElevatedButton(
      onPressed: () => confirmOrder(order.id, context),
      style: ElevatedButton.styleFrom(
        backgroundColor: succesColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Center(
        child: Text(
          'Хүлээн авах',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  infoText(String? v) {
    if (v == null) {
      return const SizedBox.shrink();
    } else {
      return Text(v, style: const TextStyle(fontSize: 14, color: Colors.black));
    }
  }
}
