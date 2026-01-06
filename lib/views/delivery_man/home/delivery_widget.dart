import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/constants.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/home/delivery_detail.dart';
import 'package:pharmo_app/views/delivery_man/widgets/status_changer.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class DeliveryWidget extends StatefulWidget {
  final Order order;
  final int delId;
  const DeliveryWidget({super.key, required this.order, required this.delId});

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget>
    with SingleTickerProviderStateMixin {
  String selected = 'e';
  String pType = 'E';
  setSelected(String s, String p) {
    setState(() {
      selected = s;
      pType = p;
    });
  }

  String getName() {
    final order = widget.order;
    if (order.orderer != null && order.orderer!.name != 'null') {
      return order.orderer!.name;
    } else if (order.customer != null && order.customer!.name != 'null') {
      return order.customer!.name;
    } else {
      return order.user!.name;
    }
  }

  String getId() {
    final order = widget.order;
    if (order.orderer != null && order.orderer!.id != null) {
      return order.orderer!.id.toString();
    } else if (order.customer != null && order.customer!.id != null) {
      return order.customer!.id.toString();
    } else {
      return order.user!.id.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> expandedFields = ['Нийт үнэ', 'Тоо ширхэг', 'Явц', 'Төлөв'];
    List<String> expandedValues = [
      toPrice(widget.order.totalPrice),
      widget.order.totalCount.toString(),
      process(widget.order.process),
      status(widget.order.status),
    ];

    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => InkWell(
        onTap: () =>
            goto(DeliveryDetail(order: widget.order, delId: widget.delId)),
        onLongPress: () => Get.bottomSheet(StatusChanger(
            delId: widget.delId,
            orderId: widget.order.id,
            status: widget.order.process)),
        child: AnimatedContainer(
          curve: Curves.slowMiddle,
          duration: const Duration(milliseconds: 300),
          padding: padding10,
          width: Sizes.width * .8,
          decoration: BoxDecoration(
            color: getOrderProcessColor(widget.order.process),
            borderRadius: border10,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  colored(
                    widget.order.orderNo.toString(),
                    Icons.numbers,
                    const Color.fromARGB(255, 66, 241, 145),
                  ),
                  if (!widget.order.orderer!.id.contains('p'))
                    CustomTextButton(
                      color: Colors.deepPurple,
                      text: 'Төлбөр бүртгэх',
                      onTap: () => registerSheet(jagger, getId()),
                    ),
                ],
              ),
              Column(
                children: expandedFields
                    .map((v) => infoRow(
                        v, expandedValues[expandedFields.indexOf(v)],
                        color1: white, color2: white))
                    .toList(),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text('Дэлгэрэнгүй >',
                      style: const TextStyle(color: white))),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController amountCr = TextEditingController();

  registerSheet(JaggerProvider jagger, String customerId) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: '${getName()} харилцагч дээр төлбөр бүртгэх',
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
                  registerPayment(jagger, pType, amountCr.text, customerId);
                }
              },
            ),
          ],
        ),
      ),
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

  registerPayment(JaggerProvider jagger, String type, String amount,
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

  Widget product(Item item, BuildContext context) {
    double itemWidth = Sizes.width * 0.4;
    double maxItemWidth = 180;
    double minItemWidth = 140;
    return Container(
      width: itemWidth.clamp(minItemWidth, maxItemWidth),
      constraints: const BoxConstraints(
        // minHeight: 200,
        // maxHeight: 250,
        minWidth: 130,
        maxWidth: 140,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: padding10,
      decoration: BoxDecoration(
        borderRadius: border20,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag,
              color: Colors.blueAccent, size: 30), // Product icon
          const SizedBox(height: 5),
          Text(
            '${item.itemName} (${item.itemQty})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${toPrice(item.itemPrice.toString())} (Нэгж)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${toPrice(item.itemTotalPrice.toString())} (Нийт)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget colored(String text, IconData icon, Color color,
      {MainAxisAlignment? main}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: main ?? MainAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 5),
          Text(
            text,
            softWrap: true,
            maxLines: 2,
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

Widget infoRow(String title, String value, {Color? color1, Color? color2}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: color1 ?? black),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color2 ?? black),
        )
      ],
    ),
  );
}

getOrderProcess(String status) {
  switch (status) {
    case "Хүргэгдсэн":
      return "D";
    case "Хаалттай":
      return "C";
    case "Буцаагдсан":
      return "R";
    case "Түгээлтэнд гарсан":
      return "O";
    default:
      message('Төлөв сонгоно уу!');
  }
}

getOrderProcessColor(String process) {
  print(process);
  switch (process) {
    case "D":
      return const Color.fromARGB(255, 17, 187, 23);
    case "C":
      return const Color.fromARGB(255, 100, 210, 250);
    case "R":
      return const Color.fromARGB(255, 240, 41, 41);
    case "O":
      return const Color.fromARGB(255, 241, 193, 48);
    case "P":
      return primary.withAlpha(200);
    default:
      primary.withAlpha(200);
  }
}

findCustId(Order order) {
  if (order.orderer != null) {
    return order.orderer!.id;
  } else if (order.customer != null) {
    return order.customer!.id;
  } else if (order.user != null) {
    return order.user!.id;
  }
}
