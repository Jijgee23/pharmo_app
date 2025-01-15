import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/icon/cart_icon.dart';
import 'package:pharmo_app/widgets/order_widgets/order_status.dart';
import 'package:pharmo_app/widgets/ui_help/container.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:provider/provider.dart';

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
          child: Column(
            children: [
              OrderStatus(process: widget.order.process!),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  col(t1: 'Дүн', t2: '${widget.order.totalPrice.toString()} ₮'),
                  col(t1: 'Тоо ширхэг', t2: widget.order.totalCount.toString()),
                  col(t1: 'Нийлүүлэгч', t2: widget.order.supplier.toString()),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  thickness: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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

  productBuilder(MyOrderDetailModel o) {
    return Ctnr(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleContainer(
            child: Text(
              o.itemName.toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 16,
              ),
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
                valueColor: theme.primaryColor,
              ),
              detailColumn(
                label: 'Нийт үнэ',
                value: '${o.itemTotalPrice}₮',
                valueColor: theme.primaryColor,
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
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}

class TitleContainer extends StatelessWidget {
  final Widget child;
  const TitleContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
