import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/views/main/delivery_man/home/delivery_home.dart';
import 'package:pharmo_app/views/main/delivery_man/home/delivery_widget.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class OrdererOrders extends StatefulWidget {
  final User? user;
  final Delivery del;
  const OrdererOrders({super.key, required this.user, required this.del});

  @override
  State<OrdererOrders> createState() => _OrdererOrdersState();
}

class _OrdererOrdersState extends State<OrdererOrders> {
  String selected = 'e';
  String pType = 'E';
  setSelected(String s, String p) {
    setState(() {
      selected = s;
      pType = p;
    });
  }

  bool expanded = false;

  TextEditingController amountCr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedSize(
        duration: duration,
        child: Container(
          padding: const EdgeInsets.all(7.5),
          decoration: BoxDecoration(
            color: primary.withAlpha(100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(),
              if (expanded)
                AspectRatio(
                  aspectRatio: 3.5 / 2,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: orders().toList())),
                ),
              if (!widget.user!.id.contains('p')) addPay(context),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector addPay(BuildContext context) {
    return GestureDetector(
      onTap: () => registerSheet(context.read<JaggerProvider>(), widget.user!),
      child: Container(
        margin: const EdgeInsets.only(top: 7.5),
        padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
        decoration: BoxDecoration(
            color: neonBlue, borderRadius: BorderRadius.circular(10)),
        child: CustomTextButton(
          color: white,
          text: 'Төлбөр бүртгэх',
          onTap: () => registerSheet(
            context.read<JaggerProvider>(),
            widget.user!,
          ),
        ),
      ),
    );
  }

  Iterable<Widget> orders() {
    return widget.del.orders.map(
      (order) => getUser(order)!.id == widget.user!.id
          ? DeliveryWidget(order: order, delId: widget.del.id)
          : const SizedBox(),
    );
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: white),
            const SizedBox(width: 5),
            Text(
              (widget.user == null || widget.user!.name == 'null')
                  ? 'Харилцагч (${widget.user!.id})'
                  : widget.user!.name,
              // maybeNull(widget.user!.name),
              maxLines: 3,
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        Container(
            padding: EdgeInsets.all(7.5),
            decoration: BoxDecoration(
              border: Border.all(color: white),
              shape: BoxShape.circle,
            ),
            child: Text(
                widget.del.orders
                    .where((t) => getUser(t)!.id == widget.user!.id)
                    .length
                    .toString(),
                style: TextStyle(color: black, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget picker(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    return InkWell(
      onTap: () => setModalState(() {
        selected = n;
        pType = v;
      }),
      child: AnimatedContainer(
        duration: duration,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: sel ? 20 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sel ? succesColor.withOpacity(.3) : white,
          border: Border.all(
            color: sel ? succesColor : grey300,
          ),
        ),
        child: Text(n),
      ),
    );
  }

  Future registerSheet(JaggerProvider jagger, User user) async {
    String? name = user.name;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: name != null ? '$name харилцагч дээр төлбөр бүртгэх' : '',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                picker('Бэлнээр', 'C', setModalState),
                picker('Дансаар', 'T', setModalState),
              ],
            ),
            CustomTextField(controller: amountCr, hintText: 'Дүн оруулах'),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (amountCr.text.isEmpty) {
                  message('Дүн оруулна уу!');
                } else {
                  registerPayment(jagger, pType, amountCr.text, user.id)
                      .then((v) {});
                }
              },
            ),
            SizedBox()
          ],
        ),
      ),
    );
  }

  Future registerPayment(JaggerProvider jagger, String type, String amount,
      String customerId) async {
    if (amount.isEmpty) {
      message('Дүн оруулна уу!');
    } else if (type == 'E') {
      message('Төлбөрийн хэлбэр сонгоно уу!');
    } else {
      await jagger.addCustomerPayment(type, amount, customerId);
      setSelected('E', 'e');
      amountCr.clear();
      Navigator.pop(context);
    }
  }
}
