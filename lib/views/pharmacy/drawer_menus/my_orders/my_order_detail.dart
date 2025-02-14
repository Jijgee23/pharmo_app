import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/order_status.dart';
import 'package:provider/provider.dart';

class MyOrderDetail extends StatefulWidget {
  final int id;
  final MyOrderModel order;
  const MyOrderDetail({super.key, required this.id, required this.order});

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
    List<String> titles = ['Дүн', 'Тоо ширхэг', 'Нийлүүлэгч'];
    List<dynamic> data = [
      toPrice(widget.order.totalPrice),
      widget.order.totalCount.toString(),
      widget.order.supplier.toString()
    ];
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: SideAppBar(hasBasket: true, text: 'Захиалгын дугаар: ${widget.order.orderNo}'),
          body: Column(
            children: [
              const SizedBox(height: Sizes.mediumFontSize),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: titles.map((e) => col(t1: e, t2: data[titles.indexOf(e)])).toList(),
              ),
              const SizedBox(height: Sizes.smallFontSize),
              OrderStatusAnimation(process: widget.order.process!, status: widget.order.status!),
              const SizedBox(height: Sizes.smallFontSize),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                    itemCount: provider.orderDetails.length,
                    itemBuilder: (context, idx) {
                      var order = provider.orderDetails[idx];
                      return productBuilder(order);
                    }),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget col({required String t1, required String t2, Color? t2Color}) {
    return Column(
      children: [
        Text(t1,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(t2, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t2Color)),
      ],
    );
  }

  productBuilder(MyOrderDetailModel o) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration:
          BoxDecoration(color: white, borderRadius: border10, border: Border.all(color: grey300)),
      child: Wrap(
        runSpacing: 7.5,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(o.itemName.toString(), primary),
              text('${toPrice(o.itemPrice)} (нэгж)', secondary, align: TextAlign.end)
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            text("Тоо ширхэг", black),
            text(o.itemQty.toString(), grey500, align: TextAlign.end)
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text("Анх захиалсан тоо ширхэг", black),
              text(o.iQty.toString(), grey500, align: TextAlign.end)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text("Нийт үнэ", black),
              text(toPrice(o.itemTotalPrice), secondary, align: TextAlign.end)
            ],
          ),
        ],
      ),
    );
  }

  text(String value, Color color, {TextAlign? align}) {
    return SizedBox(
      width: Sizes.width * .38,
      child: Text(
        value,
        maxLines: 2,
        textAlign: align ?? TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget detailColumn({
    required String label,
    required String value,
    Color valueColor = Colors.black,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Row(children: [Text(label, style: TextStyle(fontSize: 14, color: black.withOpacity(.5)))]),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      )
    ]);
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
