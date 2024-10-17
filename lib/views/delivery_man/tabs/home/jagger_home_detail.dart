// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/ship.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class JaggerHomeDetail extends StatelessWidget {
  final int shipId;
  final ShipOrders order;
  const JaggerHomeDetail(
      {super.key, required this.order, required this.shipId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SideMenuAppbar(title: 'Түгээлтийн бараанууд'),
      body: Consumer<JaggerProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: SingleChildScrollView(
              child: Column(
                children: order.items.isNotEmpty
                    ? order.items.map((ord) {
                        return item(
                            ord: ord, provider: provider, context: context);
                      }).toList()
                    : [const NoResult()],
              ),
            ),
          );
        },
      ),
    );
  }

  Container item(
      {required ShipOrderItem ord,
      required JaggerProvider provider,
      required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(title: 'Нэр:', value: ord.itemName.toString()),
          row(title: 'Үнэ:', value: '${ord.itemPrice} ₮'),
          row(title: 'Нийт дүн:', value: '${ord.itemTotalPrice} ₮'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text('Тоо ширхэг',
                      style: TextStyle(color: Colors.grey.shade900))),
              Expanded(
                child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  textAlign: TextAlign.right,
                  onSubmitted: (value) {
                    if (ord.itemQTy != int.parse(value) && value.isNotEmpty) {
                      provider.updateQTY(ord.itemId, int.parse(value), context);
                    }
                  },
                  decoration: const InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                  ),
                  controller:
                      TextEditingController(text: ord.itemQTy.toString()),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  row({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade900),
          ),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
