import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/auth/login.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/views/seller/drawer_menus/order/seller_orders.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/order_widgets/order_status.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/ui_help/default_box.dart';
import 'package:provider/provider.dart';

class SellerOrderDetail extends StatefulWidget {
  final int oId;
  const SellerOrderDetail({super.key, required this.oId});

  @override
  State<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends State<SellerOrderDetail> {
  late PharmProvider p;
  bool felching = false;
  setFetching(bool n) {
    setState(() {
      felching = n;
    });
  }

  @override
  void initState() {
    setFetching(true);
    p = Provider.of<PharmProvider>(context, listen: false);
    p.getSellerOrderDetail(widget.oId, context);
    setFetching(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pp, child) {
        var cxs = CrossAxisAlignment.center;
        final order = pp.orderDets[0];
        return (felching == true)
            ? const PharmoIndicator()
            : Scaffold(
                body: DefaultBox(
                  title: 'Захиалгын дэлгэрэнгүй',
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: [
                        OrderStatus(process: order.process),
                        Box(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Col(
                                      t1: 'Захиалын дугаар',
                                      t2: order.orderNo,
                                      cxs: cxs),
                                  Col(
                                      t1: 'Харилцагч',
                                      t2: order.customer,
                                      cxs: cxs),
                                  Col(t1: 'Төлөв', t2: order.status, cxs: cxs)
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Col(
                                      t1: 'Нийн дүн',
                                      t2: toPrice(order.totalPrice),
                                      cxs: cxs),
                                  Col(
                                      t1: 'Тоо ширхэг',
                                      t2: order.totalCount.toString(),
                                      cxs: cxs),
                                  Col(
                                      t1: 'Төлбөрийн хэлбэр',
                                      t2: order.payType,
                                      cxs: cxs)
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (order.note == 'null')
                          Box(
                            child: SelectableText(
                              'Тайлбар: ${order.note}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        if (pp.orderDets[0].items.isNotEmpty)
                          Box(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...pp.orderDets[0].items.map(
                                    (item) => Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          boxShadow: shadow(),
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Col(
                                                  t1: 'Нэр',
                                                  t2: item.itemName,
                                                  cxs: cxs),
                                              Col(
                                                  t1: 'Нийт дүн',
                                                  t2: toPrice(
                                                      item.itemTotalPrice),
                                                  cxs: cxs),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Col(
                                                  t1: 'Тоо ширхэг',
                                                  t2: item.iQty.toString(),
                                                  cxs: cxs),
                                              InkWell(
                                                onTap: () =>
                                                    changeQty(order.id, item),
                                                child: const Text(
                                                  'Тоо ширхэг өөрчлөх',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.succesColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: CustomButton(
                            text: 'Захиалын мэдээлэл засах',
                            ontap: () {
                              Get.bottomSheet(
                                EditSellerOrder(
                                  note: order.note,
                                  pt: order.payType,
                                  oId: order.id,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }

  final TextEditingController qtyController = TextEditingController();

  changeQty(int oid, OrderItem item) {
    setState(() {
      qtyController.text = item.itemQty.toString();
    });
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 15,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                item.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            input('Тоо ширхэг оруулна уу', qtyController, null,
                TextInputType.number),
            CustomButton(
              text: 'Хадгалах',
              ontap: () => _changeQty(oid, item),
            ),
          ],
        ),
      ),
    );
  }

  _changeQty(int oid, OrderItem item) async {
    if (qtyController.text.isEmpty) {
      message(message: 'Тоон утга оруулна уу!', context: context);
    } else if (int.parse(qtyController.text) == 0) {
      message(message: 'Тоо ширхэг 0 байж болохгүй!', context: context);
    } else {
      int qty = int.parse(qtyController.text);
      dynamic res = await p.changeItemQty(
          oId: oid, itemId: item.productId, qty: qty, context: context);
      print('update qty: ${res['errorType']}');
      message(message: res['message'], context: context);
      Get.back();
    }
  }
}
