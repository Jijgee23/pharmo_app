import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_detail.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:provider/provider.dart';

class DeliveryWidget extends StatefulWidget {
  final Order order;
  final int delId;
  const DeliveryWidget({super.key, required this.order, required this.delId});

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    List<String> expandedFields = ['Нийт үнэ', 'Тоо ширхэг', 'Явц', 'Төлөв', 'Төлбөрийн хэлбэр'];
    List<String> expandedValues = [
      toPrice(widget.order.totalPrice),
      widget.order.totalCount.toString(),
      process(widget.order.process),
      status(widget.order.status),
      getPayType(widget.order.payType)
    ];

    String getName() {
      final order = widget.order;
      if (order.orderer != null && order.orderer!.name != null) {
        return order.orderer!.name!;
      } else if (order.customer != null && order.customer!.name != null) {
        return order.customer!.name!;
      } else {
        return order.user!.name!;
      }
    }

    return InkWell(
      onTap: () => goto(DeliveryDetail(order: widget.order, delId: widget.delId)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: padding15,
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: getOrderProcessColor(widget.order.process), borderRadius: border20),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                colored(getName(), Icons.person, neonBlue.withOpacity(.8)),
                colored(widget.order.orderNo.toString(), Icons.numbers,
                    const Color.fromARGB(255, 66, 241, 145),
                    main: MainAxisAlignment.end),
              ],
            ),
            Column(
              children: expandedFields
                  .map(
                    (v) => infoRow(v, expandedValues[expandedFields.indexOf(v)],
                        color1: white, color2: white),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
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
          const Icon(Icons.shopping_bag, color: Colors.blueAccent, size: 30), // Product icon
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

  Widget colored(String text, IconData icon, Color color, {MainAxisAlignment? main}) {
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

Widget statusButton(BuildContext context, int delId, int orderId) {
  List<String> statuses = ['Хүргэгдсэн', 'Хаалттай', 'Буцаагдсан', 'Түгээлтэнд гарсан'];
  final provider = Provider.of<JaggerProvider>(context, listen: false);

  return CustomButton(
    text: 'Төлөв өөрчлөх',
    ontap: () {
      Get.bottomSheet(
        SheetContainer(
          children: [
            ...statuses.map(
              (status) => InkWell(
                onTap: () async {
                  final data = {
                    "delivery_id": delId,
                    "order_id": orderId,
                    "process": getOrderProcess(status)
                  };
                  final response = await apiPatch('delivery/order/', jsonEncode(data));
                  if (response.statusCode == 200 || response.statusCode == 201) {
                    message('Төлөв өөрчлөгдлөө');
                    await provider.getDeliveries();
                  } else {
                    message(wait);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide(color: atnessGrey))),
                  child: Row(
                    spacing: 15,
                    children: [
                      // const Icon(Icons.circle_rounded),
                      Text(status),
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
      return Colors.green;
    case "C":
      return neonBlue;
    case "R":
      return Colors.redAccent;
    case "O":
      return Colors.amber;
    default:
      Colors.white;
  }
}
