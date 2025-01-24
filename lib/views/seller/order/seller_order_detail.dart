import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/cart/pharm_order_sheet.dart';
import 'package:pharmo_app/views/seller/customer/customers.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/order_widgets/order_status.dart';
import 'package:pharmo_app/views/product/add_basket_sheet.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
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

  Map<String, dynamic> det = {};

  @override
  void initState() {
    super.initState();
    p = Provider.of<PharmProvider>(context, listen: false);
    fetchInit();
  }

  fetchInit() async {
    setFetching(true);
    final data = await p.getSellerOrderDetail(widget.oId, context);
    print(data);
    setState(() {
      det = data;
    });
    // await p.getSellerOrderDetail(widget.oId, context);
    setFetching(false);
  }

  List<String> titles = [
    'Захиалын дугаар',
    'Харилцагч',
    'Явц',
    'Нийн дүн',
    'Тоо ширхэг',
    'Төлбөрийн хэлбэр',
    'Тайлбар'
  ];

  @override
  Widget build(BuildContext context) {
    List<String> datas = [
      det['orderNo'].toString(),
      det['customer'].toString(),
      det['process'].toString(),
      toPrice(det['totalPrice']),
      det['totalCount'].toString(),
      det['payType'].toString(),
      det['note'].toString(),
    ];
    return (felching == true)
        ? const Center(
            child: SizedBox(width: 50, height: 50, child: PharmoIndicator()),
          )
        : Scaffold(
            appBar: SideAppBar(text: maybeNull(det['orderNo'].toString())),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: Sizes.bigFontSize,
                  left: Sizes.smallFontSize,
                  right: Sizes.smallFontSize),
              child: Wrap(
                runSpacing: Sizes.smallFontSize,
                children: [
                  ...titles.map((t) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$t:',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: Sizes.mediumFontSize),
                          ),
                          Text(
                            maybeNull(datas[titles.indexOf(t)]),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Sizes.mediumFontSize,
                            ),
                          )
                        ],
                      )),
                  const SizedBox(height: Sizes.mediumFontSize),
                  OrderStatus(process: det['process']),
                  products(),
                  CustomButton(
                    text: 'Захиалгын мэдээлэл засах',
                    ontap: () {
                      Get.bottomSheet(
                        EditSellerOrder(
                          note: det['note'],
                          pt: det['payType'],
                          oId: det['id'],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  products() {
    if (det.containsKey('items') == true) {
      final items = det['items'] as List;
      return SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Захиалгын бараанууд',
              style: TextStyle(
                  color: Colors.black87, fontSize: Sizes.mediumFontSize),
            ),
            const SizedBox(height: Sizes.mediumFontSize),
            ...items.map(
              (item) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    boxShadow: shadow(),
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Col(t1: 'Нэр', t2: item['itemName']),
                        Col(
                          t1: 'Нийт дүн',
                          t2: toPrice(item['itemTotalPrice']),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Col(
                            t1: 'Тоо ширхэг',
                            t2: maybeNull(item['iQty'].toString())),
                        InkWell(
                          onTap: () => changeQty(det['id'], item),
                          child: const Text(
                            'Тоо ширхэг өөрчлөх',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.succesColor,
                                fontWeight: FontWeight.bold),
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
      );
    } else {
      return const SizedBox();
    }
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
      dynamic res = await p.changeItemQty(
          context: context, oId: oid, itemId: item['productId'], qty: qty);
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
  const EditSellerOrder(
      {super.key, required this.note, required this.pt, required this.oId});

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
                Text('Захиалгын мэдээлэл засах',
                    style: TextStyle(fontSize: 12)),
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
                final pharmProvider =
                    Provider.of<PharmProvider>(context, listen: false);
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
