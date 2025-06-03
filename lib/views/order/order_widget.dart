import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/pharmacy/my_orders/my_order_detail.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/views/main/seller/seller_order_detail.dart';
import 'package:pharmo_app/widgets/text/small_text.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:provider/provider.dart' show Consumer;
import 'package:rflutter_alert/rflutter_alert.dart';

class OrderWidget extends StatelessWidget {
  final SellerOrderModel order;
  const OrderWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) => Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              flex: 2,
              onPressed: (context) =>
                  askDeletetion(context, provider, order.orderNo.toString()),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Устгах',
              borderRadius: BorderRadius.circular(8),
            )
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: white,
            borderRadius: border10,
            border: Border.all(color: grey300),
          ),
          child: InkWell(
            onTap: () => goto(SellerOrderDetail(oId: parseInt(order.id))),
            child: Wrap(
              runSpacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: primary.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: primary),
                          const SizedBox(width: 5),
                          Text(maybeNull(order.customer),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold))
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
                Divider(color: Colors.grey.shade300, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tx(order.status),
                        tx(order.process),
                        tx(order.createdOn.toString().substring(0, 10))
                      ],
                    ),
                    const SizedBox()
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  tx(String? s) {
    return Text(maybeNull(s),
        style: const TextStyle(fontSize: 14, color: Colors.black));
  }

  askDeletetion(BuildContext context, MyOrderProvider op, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.bigFontSize),
            child: Column(
              children: [
                text('Та $name дугаартай захиалгыг устгамаар байна уу?',
                    color: black, align: TextAlign.center),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    btn(true, context, op),
                    btn(false, context, op),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  btn(bool isPop, BuildContext context, MyOrderProvider op) {
    return DialogButton(
      width: Sizes.width * 0.3,
      color: theme.primaryColor,
      child: SmallText(isPop ? 'Үгүй' : 'Тийм', color: white),
      onPressed: () => isPop
          ? Navigator.pop(context)
          : deleteOrder(op).then(
              (e) => Navigator.pop(context),
            ),
    );
  }

  Future deleteOrder(MyOrderProvider op) async {
    await op.deleteSellerOrders(orderId: order.id);
  }
}
