import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/views/ORDERER/my_orders/my_order_detail.dart';
import 'package:pharmo_app/views/ORDERER/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/views/SELLER/order/seller_order_detail.dart';
import 'package:pharmo_app/application/application.dart';

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
      bColor: theme.primaryColor,
      title: isPop ? 'Үгүй' : 'Тийм',
      onTap: () => isPop
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
