import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_widget.dart';
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
      Future.microtask(() => context.read<JaggerProvider>().getDeliveries());
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

  @override
  Widget build(BuildContext context) {
    Order order = widget.order;
    List<String> data = [
      order.orderer!.name,
      toPrice(order.totalPrice),
      maybeNull(order.totalCount.toString()),
      getPayType(widget.order.payType),
      order.createdOn.substring(0, 10)
    ];
    List<String> titles = ['Захиалагч', 'Нийт үнэ', 'Тоо ширхэг', 'Төлбөрийн хэлбэр', "Огноо"];

    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => DataScreen(
        loading: false,
        empty: false,
        appbar: SideAppBar(
          text: widget.order.orderNo.toString(),
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              title('Төлөв, явц'),
              OrderStatusAnimation(process: process(order.process), status: status(order.status)),
              title('Үндсэн мэдээллүүд'),
              ...titles.map((title) => infoRow(title, data[titles.indexOf(title)])),
              title('Захиалгын бараанууд'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                height: order.items.length <= 2 ? 180 : 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: order.items.length,
                  itemBuilder: (context, idx) => _product(order.items[idx]),
                ),
              ),
              // if (order.payments!.isNotEmpty) title('Төлбөрүүд'),
              // if (order.payments!.isNotEmpty) ...order.payments!.map((pay) => paymentWidget(pay)),
              // title('Төлбөр нэмэх'),
              // field('Бэлнээр', cash),
              // field('Дансаар', account),
              // field('Зээлээр', lend),
              // CustomButton(text: 'Хадгалах', ontap: () => saveValues(jagger)),
              statusButton(context, widget.delId, order.id),
              const SizedBox(height: 100)
            ],
          ),
        ),
      ),
    );
  }

  title(String s) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(s,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  paymentWidget(OrderPayment pay) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(getPayType(pay.payType)),
          Text(toPrice(pay.amount)),
        ],
      ),
    );
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

  _product(Item item) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(10),
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
