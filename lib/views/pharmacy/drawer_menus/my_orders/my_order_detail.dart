import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/icon/cart_icon.dart';
import 'package:pharmo_app/widgets/order_widgets/order_status.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/ui_help/box.dart';

class MyOrderDetail extends StatefulWidget {
  final int id;
  final MyOrderModel order;
  final String orderNo;
  final int? process;
  const MyOrderDetail(
      {super.key,
      required this.id,
      required this.order,
      required this.orderNo,
      this.process});

  @override
  State<MyOrderDetail> createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail> {
  late MyOrderProvider orderProvider;
  @override
  void initState() {
    orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    orderProvider.getMyorderDetail(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        return DefaultBox(
          title: 'Захиалгын дугаар: ${widget.orderNo}',
          action: const CartIcon(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                OrderStatus(process: widget.order.process!),
                Box(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      col(
                          t1: 'Дүн',
                          t2: '${widget.order.totalPrice.toString()} ₮'),
                      col(
                          t1: 'Тоо ширхэг',
                          t2: widget.order.totalCount.toString()),
                      col(
                          t1: 'Нийлүүлэгч',
                          t2: widget.order.supplier.toString()),
                    ],
                  ),
                ),
                Box(
                  child: Scrollbar(
                    thickness: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...provider.orderDetails.map(
                            (o) => productBuilder(o),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  col({required String t1, required String t2, Color? t2Color}) {
    return Column(
      children: [
        Text(
          t1,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Text(
          t2,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: t2Color),
        ),
      ],
    );
  }

  Container productBuilder(MyOrderDetailModel o) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            o.itemName.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              detailColumn(
                label: 'Тоо ширхэг',
                value: o.iQty.toString(),
              ),
              detailColumn(
                label: 'Нэгж үнэ',
                value: toPrice(o.itemPrice),
                valueColor: AppColors.primary,
              ),
              detailColumn(
                label: 'Нийт үнэ',
                value: '${o.itemTotalPrice}₮',
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget detailColumn({
    required String label,
    required String value,
    Color valueColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
