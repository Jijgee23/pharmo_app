// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/ship.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class JaggerHomeDetail extends StatefulWidget {
  final int shipId;
  final ShipOrders order;
  const JaggerHomeDetail({super.key, required this.order, required this.shipId});

  @override
  State<JaggerHomeDetail> createState() => _JaggerHomeDetailState();
}

class _JaggerHomeDetailState extends State<JaggerHomeDetail> {
  final TextEditingController qty = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: theme.primaryColor,
          body: DefaultBox(
            title: 'Захиалгын дэлгэрэнгүй',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.order.user != null)
                            Col(t1: 'Захиалагч', t2: widget.order.user!),
                          if (widget.order.branch != null)
                            Col(t1: 'Салбар', t2: widget.order.branch!),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Col(t1: 'Захиалгын дугаар', t2: widget.order.orderNo!),
                          Col(t1: 'Явц', t2: getOrderProcess(widget.order.process ?? ''))
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: widget.order.items.isNotEmpty
                          ? widget.order.items.map((ord) {
                              return item(ord: ord, provider: provider, context: context);
                            }).toList()
                          : [const NoResult()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container item(
      {required ShipOrderItem ord,
      required JaggerProvider provider,
      required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
          color: card,
          boxShadow: [Constants.defaultShadow],
          borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Col(t1: 'Нэр', t2: ord.itemName.toString()),
            Col(t1: 'Үнэ', t2: toPrice(ord.itemPrice!)),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Col(t1: 'Тоо ширхэг', t2: ord.itemQTy.toString()),
              Col(t1: 'Нийт дүн', t2: toPrice(ord.itemTotalPrice!)),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                qty.text = ord.iQty.toString();
              });
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: qty,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: 'Хадгалах',
                              ontap: () {
                                if (ord.itemQTy != int.parse(qty.text) && qty.text.isNotEmpty) {
                                  provider.updateQTY(ord.itemId, int.parse(qty.text));
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text(
              'Тоо ширхэг өөрчлөх',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
