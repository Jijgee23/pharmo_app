import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/main/seller/customers.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/views/product/add_basket_sheet.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

import '../../../widgets/loader/order_status.dart';

class SellerOrderDetail extends StatefulWidget {
  final String oId;
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

  Map<String, dynamic> det = {};

  @override
  void initState() {
    super.initState();
    p = Provider.of<PharmProvider>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 100), () {
      setFetching(true);
      fetchInit();
    });
  }

  fetchInit() async {
    final data = await p.getSellerOrderDetail(widget.oId, context);
    if (!mounted) return;
    setState(() {
      det = data;
      felching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataScreen(
      loading: felching,
      empty: !det.containsKey('items'),
      appbar: SideAppBar(text: maybeNull(det['orderNo'].toString())),
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: 7.5,
          children: [
            if (det['process'] != null)
              OrderStatusAnimation(
                  process: det['process'], status: det['status'], margin: const EdgeInsets.all(0)),
            informations(),
            const SizedBox(height: Sizes.mediumFontSize),
            products(),
            CustomButton(
              text: 'Захиалгын мэдээлэл засах',
              ontap: () {
                Get.bottomSheet(
                  EditSellerOrder(
                    note: maybeNull(det['note']),
                    pt: det['payType'],
                    oId: det['id'],
                  ),
                );
              },
            ),
            const SizedBox(height: kToolbarHeight + 20)
          ],
        ),
      ),
    );
  }

  Widget informations() {
    List<String> titles = [
      'Захиалын дугаар',
      'Харилцагч',
      'Нийн дүн',
      'Тоо ширхэг',
      'Төлбөрийн хэлбэр',
      'Тайлбар'
    ];
    List<String> datas = [
      maybeNull(det['orderNo'].toString()),
      maybeNull(det['customer'].toString()),
      maybeNull(toPrice(det['totalPrice'])),
      maybeNull(det['totalCount'].toString()),
      maybeNull(det['payType'].toString()),
      maybeNull(det['note']),
    ];
    if (datas.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Column(
          spacing: 7.5, children: titles.map((t) => myRow(t, datas[titles.indexOf(t)])).toList());
    }
  }

  Widget myRow(String tit, String? v) {
    if (v != null || v == '' || v == 'null') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$tit:',
            style: const TextStyle(color: Colors.black87, fontSize: Sizes.mediumFontSize)),
        Text(v!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: Sizes.mediumFontSize))
      ]);
    } else {
      return const SizedBox();
    }
  }

  products() {
    if (det.containsKey('items') == true) {
      final items = det['items'] as List;
      return SingleChildScrollView(
        child: Column(
          children: [
            ...items.map(
              (item) => prodBuilder(item),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Container prodBuilder(item) {
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
              text(item['itemName'], primary),
              text('${item['itemTotalPrice']} (нэгж)', secondary, align: TextAlign.end)
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            text("Анх захиалсан тоо ширхэг", black),
            text(maybeNull(item['iQty'].toString()), grey500, align: TextAlign.end)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            text("Тоо ширхэг", black),
            text(maybeNull(item['itemQty'].toString()), grey500, align: TextAlign.end)
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text("Нийт үнэ", black),
              text(toPrice(item['itemTotalPrice']), secondary, align: TextAlign.end)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              InkWell(
                  onTap: () => changeQty(det['id'], item),
                  child: text('Тоо ширхэг өөрчлөх', succesColor))
            ],
          )
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

  final TextEditingController qtyController = TextEditingController();

  changeQty(int oid, dynamic item) {
    setState(() {
      qtyController.text = item['itemQty'].toString();
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
                item['itemName'],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            input('Тоо ширхэг оруулна уу', qtyController, TextInputType.number),
            CustomButton(
              text: 'Хадгалах',
              ontap: () => _changeQty(det['id'], item),
            ),
          ],
        ),
      ),
    );
  }

  _changeQty(int oid, dynamic item) async {
    if (qtyController.text.isEmpty) {
      message('Тоон утга оруулна уу!');
    } else if (int.parse(qtyController.text) == 0) {
      message('Тоо ширхэг 0 байж болохгүй!');
    } else {
      int qty = int.parse(qtyController.text);
      dynamic res =
          await p.changeItemQty(context: context, oId: oid, itemId: item['productId'], qty: qty);
      print('update qty: ${res['errorType']}');
      message(res['message']);
      Get.back();
    }
  }
}

class EditSellerOrder extends StatefulWidget {
  final String note;
  final String pt;
  final int oId;
  const EditSellerOrder({super.key, required this.note, required this.pt, required this.oId});

  @override
  State<EditSellerOrder> createState() => _EditSellerOrderState();
}

class _EditSellerOrderState extends State<EditSellerOrder> {
  final nc = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    if (widget.note != null && widget.note != 'null') {
      setState(() {
        nc.text = widget.note;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: 15,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Захиалгын мэдээлэл засах', style: TextStyle(fontSize: 12)),
                PopSheet()
              ],
            ),
            input('Нэмэлт тайлбар', nc, null),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyChip(
                    title: 'Дансаар',
                    v: 'T',
                    selected: payType == 'T',
                    ontap: () => setPayType('T')),
                MyChip(
                    title: 'Бэлнээр',
                    v: 'C',
                    selected: payType == 'C',
                    ontap: () => setPayType('C')),
                MyChip(
                    title: 'Зээлээр',
                    v: 'L',
                    selected: payType == 'L',
                    ontap: () => setPayType('L')),
              ],
            ),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                final pharmProvider = Provider.of<PharmProvider>(context, listen: false);
                pharmProvider
                    .editSellerOrder(nc.text, payType, widget.oId, context)
                    .then((e) => Navigator.pop(context));
              },
            ),
          ],
        ),
      ),
    );
  }

  String payType = '';
  setPayType(String v) {
    setState(() {
      payType = v;
    });
  }
}
