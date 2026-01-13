import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/active_delivery/delivery_widget.dart';
import 'package:pharmo_app/views/delivery_man/active_delivery/see_order_map.dart';
import 'package:pharmo_app/views/delivery_man/widgets/status_changer.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/order_status.dart';
import 'package:provider/provider.dart';

class DeliveryDetail extends StatefulWidget {
  final int delId;
  final Order order;
  const DeliveryDetail({super.key, required this.order, required this.delId});

  @override
  State<DeliveryDetail> createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail> {
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.microtask(() => context.read<JaggerProvider>().getDeliveryDetail(widget.order.id));
    });
  }

  var idecoration = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: primary.withOpacity(.5)),
  );
  var style = TextStyle(fontSize: 14, color: grey600);
  final TextEditingController cash = TextEditingController();
  final TextEditingController account = TextEditingController();
  final TextEditingController lend = TextEditingController();
  String getName() {
    final order = widget.order;
    if (order.orderer != null && order.orderer!.name != null) {
      return order.orderer!.name;
    } else if (order.customer != null && order.customer!.name != null) {
      return order.customer!.name;
    } else {
      return order.user!.name;
    }
  }

  getOrdereId() {
    final order = widget.order;
    if (order.orderer != null && order.orderer!.name != null) {
      return order.orderer!.id;
    } else if (order.customer != null && order.customer!.name != null) {
      return order.customer!.id;
    } else {
      return order.user!.id;
    }
  }

  bool trafficEnabled = false;
  toglleTraffic() {
    setState(() {
      trafficEnabled = !trafficEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    Order order = widget.order;
    List<String> data = [
      getName(),
      toPrice(order.totalPrice),
      maybeNull(order.totalCount.toString()),
      getPayType(widget.order.payType),
      order.createdOn.substring(0, 10)
    ];
    List<String> titles = ['Захиалагч', 'Нийт үнэ', 'Тоо ширхэг', 'Төлбөрийн хэлбэр', "Огноо"];

    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        bool hasLoc =
            (order.orderer != null && order.orderer!.lat != null && order.orderer!.lat != 'null');
        var boxDecoration = BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: white,
            boxShadow: [BoxShadow(color: frenchGrey, blurRadius: 5)]);
        return DataScreen(
          loading: false,
          empty: false,
          appbar: SideAppBar(
            text: widget.order.orderNo.toString(),
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title('Төлөв, явц'),
                OrderStatusAnimation(process: process(order.process), status: status(order.status)),
                title('Үндсэн мэдээллүүд'),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: boxDecoration,
                  child: Column(
                    children: [
                      ...titles.map((title) => infoRow(title, data[titles.indexOf(title)])),
                    ],
                  ),
                ),
                title('Захиалгын бараанууд'),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: boxDecoration,
                  padding: const EdgeInsets.all(10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double itemWidth = constraints.maxWidth * 0.4;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...order.items.map((item) => _product(item, itemWidth)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      text: 'Төлөв өөрчлөх',
                      ontap: () => Get.bottomSheet(StatusChanger(
                        delId: widget.delId,
                        orderId: widget.order.id,
                        status: widget.order.process,
                      )),
                    ),
                    if (hasLoc)
                      CustomButton(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          text: 'Байршил',
                          ontap: () => goto(SeeOrderMap(order: order))),
                  ],
                ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        );
      },
    );
  }

  title(String s) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(s,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  saveValues(JaggerProvider jagger) async {
    if (cash.text.isNotEmpty) {
      await jagger.addPaymentToDeliveryOrder(widget.order.id, 'C', cash.text);
      setState(() {
        cash.clear();
      });
    }
    if (account.text.isNotEmpty) {
      await jagger.addPaymentToDeliveryOrder(widget.order.id, 'T', account.text);
      setState(() {
        account.clear();
      });
    }
    if (lend.text.isNotEmpty) {
      await jagger.addPaymentToDeliveryOrder(widget.order.id, 'L', lend.text);
      setState(() {
        lend.clear();
      });
    }
  }

  Widget field(String hint, TextEditingController controller) {
    return SizedBox(
      height: 40,
      child: TextField(
        style: style,
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: idecoration,
          enabledBorder: idecoration,
          focusedBorder: idecoration,
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          hintStyle: style,
        ),
      ),
    );
  }

  Widget _product(Item item, double itemWidth) {
    return Container(
      width: itemWidth,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: grey200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            item.itemName,
            style: const TextStyle(color: primary, fontWeight: FontWeight.bold),
          ),
          Text('${item.itemQty.toString()} ширхэг'),
          Text(toPrice(item.itemPrice)),
          Text(toPrice(item.itemTotalPrice))
        ],
      ),
    );
  }
}
