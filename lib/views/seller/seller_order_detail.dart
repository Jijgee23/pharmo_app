import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/views/product/add_basket_sheet.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

class SellerOrderDetail extends StatefulWidget {
  final int oId;
  const SellerOrderDetail({super.key, required this.oId});

  @override
  State<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends State<SellerOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyOrderModel>(
      stream: context.read<PharmProvider>().getSellerOrderDetail(widget.oId),
      builder: (context, stream) {
        return DataScreen(
          loading: stream.connectionState == ConnectionState.waiting,
          empty: !stream.hasData,
          bg: primary,
          pad: EdgeInsets.all(0),
          appbar: SideAppBar(
            text: maybeNull(stream.data?.orderNo.toString()),
            hasRect: false,
            action: Ibtn(
                onTap: () {
                  final order = stream.data!;
                  Get.bottomSheet(
                    EditSellerOrder(
                      note: maybeNull(order.note),
                      pt: order.payType ?? '',
                      oId: order.id,
                    ),
                  );
                },
                icon: Icons.edit),
          ),
          child: information(stream),
        );
      },
    );
  }

  information(AsyncSnapshot<MyOrderModel> stream) {
    if (stream.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stream.hasError) {
      return Center(
        child: Text('Алдаа: ${stream.error}'),
      );
    }
    if (!stream.hasData) {
      return const Center(child: Text('Захиалгын мэдээлэл олдсонгүй'));
    } else {
      final order = stream.data!;
      final params = {
        'Захиалгын дугаар': order.orderNo,
        'Нийт үнэ': order.totalPrice,
        'Тоо ширхэг': order.totalCount,
        'Төлөв': order.status,
        'Явц': order.process,
        'Захиалагч': order.customer,
        'Нийлүүлэгч': order.supplier,
        'Хаяг': order.address,
      };
      return Container(
        height: double.maxFinite,
        width: double.maxFinite,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  t('Огноо', order.createdOn.toString().substring(0, 10)),
                  t(
                    'Цаг/мин',
                    order.createdOn.toString().substring(10, 16),
                    cxs: CrossAxisAlignment.end,
                  ),
                ],
              ),
              ...params.entries
                  .map((e) => dataBuilder(e.key, e.value?.toString()))
                  .whereType<Widget>(),
              Divider(color: grey500),
              t('', 'Бараанууд'),
              if (order.products != null && order.products!.isEmpty) const Text('Бараа байхгүй'),
              if (order.products != null && order.products!.isNotEmpty)
                ...order.products!.map(
                  (item) => ListTile(
                    onTap: () => changeQty(order.id, item),
                    tileColor: Colors.grey.withAlpha(20),
                    dense: true,
                    title: Text(
                      '${item['itemName']} x ${item['itemQty']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Анх захиалсан: ${item['iQty']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      toPrice(item['itemTotalPrice']),
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Widget dataBuilder(String title, String? value, {CrossAxisAlignment? cxs}) {
    if (value == null || value.isEmpty || value == 'null') {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: cxs ?? CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black54,
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          (value != null && value.isNotEmpty && value != 'null') ? value : '---',
          style: TextStyle(
            color: Colors.black,
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget t(String v, String v2, {CrossAxisAlignment? cxs}) {
    return Column(
      crossAxisAlignment: cxs ?? CrossAxisAlignment.start,
      children: [
        Text(
          v,
          style: TextStyle(
            color: Colors.black54,
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          v2,
          style: TextStyle(
            color: Colors.black,
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  final TextEditingController qtyController = TextEditingController();

  Future<void> changeQty(int oid, dynamic item) async {
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
              ontap: () => _changeQty(oid, item),
            ),
          ],
        ),
      ),
    );
  }

  _changeQty(int oid, dynamic item) async {
    final p = context.read<PharmProvider>();
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

Widget myRow(String tit, String? v) {
  if (v != null || v == '' || v == 'null') {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('$tit:', style: const TextStyle(color: Colors.black87, fontSize: Sizes.mediumFontSize)),
      Text(v!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: Sizes.mediumFontSize))
    ]);
  } else {
    return const SizedBox();
  }
}
