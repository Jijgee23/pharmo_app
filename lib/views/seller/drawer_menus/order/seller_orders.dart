import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/pharmacy_list.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/ui_help/defaultBox.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders> {
  late MyOrderProvider orderProvider;
  final TextEditingController search = TextEditingController();

  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    orderProvider.getSellerOrders();
  }

  String selectedFilter = 'Харилцагчийн нэрээр';
  String filter = 'customer__name__icontains';
  TextInputType selectedType = TextInputType.name;
  void setFilter(v) {
    setState(() {
      selectedFilter = v;
      if (v == 'Харилцагчийн нэрээр') {
        filter = 'customer__name__icontains';
        selectedType = TextInputType.text;
      } else if (v == 'Захиалгын дугаараар') {
        filter = 'orderNo';
        selectedType = TextInputType.number;
      }
    });
  }

  List<String> filters = ['Харилцагчийн нэрээр', 'Захиалгын дугаараар'];
  bool isEnd = false;
  String dateType = 'start';
  String dateTypeName = 'хойш';

  setDateType(String n) {
    setState(() {
      dateType = n;
    });
    if (dateType == 'start') {
      dateTypeName = 'хойш';
    } else {
      dateTypeName = 'өмнөх';
    }
  }

  @override
  Widget build(BuildContext context) {
    var ts = const TextStyle(color: AppColors.primary);
    return Consumer2<MyOrderProvider, PharmProvider>(
      builder: (_, provider, pp, child) {
        return DefaultBox(
          title: 'Захиалгууд',
          child: Column(
            children: [
              Box(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton(
                                onPressed: () => _selectDate(context),
                                child: Text(
                                    selectedDate.toString().substring(0, 10),
                                    style: ts)),
                            InkWell(
                              onTap: () {
                                setDateType(
                                    dateType == 'start' ? 'end' : 'start');
                              },
                              child: Text('-с $dateTypeName', style: ts),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 7.5, horizontal: 20),
                          child: InkWell(
                            onTap: () => orderProvider.filterOrder(
                                dateType == 'end' ? 'end' : 'start',
                                selectedDate.toString().substring(0, 10)),
                            child: const Text(
                              'Шүүх',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: search,
                        cursorColor: Colors.black,
                        cursorHeight: 20,
                        cursorWidth: .8,
                        keyboardType: selectedType,
                        onChanged: (value) {
                          print([search.text, filter]);
                          WidgetsBinding.instance
                              .addPostFrameCallback((cb) async {
                            if (value.isEmpty) {
                              await orderProvider.getSellerOrders();
                            } else {
                              await orderProvider.filterOrder(
                                  filter, search.text);
                            }
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          hintText: '$selectedFilter хайх',
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showMenu(
                          color: Colors.white,
                          context: context,
                          shadowColor: Colors.grey.shade500,
                          position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                          items: [
                            ...filters.map(
                              (f) => PopupMenuItem(
                                child: Text(f),
                                onTap: () => setFilter(f),
                              ),
                            )
                          ],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Box(
                    child: provider.sellerOrders.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: provider.sellerOrders
                                  .map(
                                    (e) => OrderWidget(
                                      order: provider.sellerOrders[
                                          provider.sellerOrders.indexOf(e)],
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                        : const NoResult()),
              )
            ],
          ),
        );
      },
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Огноо сонгох',
      cancelText: 'Буцах',
      confirmText: "Сонгох",
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}

class OrderWidget extends StatelessWidget {
  final SellerOrderModel order;
  const OrderWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    var cxs = CrossAxisAlignment.center;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 3)]),
      child: InkWell(
        onTap: () => goto(SellerOrderDetail(
          oId: order.id,
        )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Col(
                  t1: 'Харилцагч',
                  t2: order.customer ?? '',
                  cxs: cxs,
                ),
                Col(
                  t1: 'Дугаар',
                  t2: order.orderNo!.toString(),
                  cxs: cxs,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Col(t1: 'Нийт үнэ', t2: toPrice(order.totalPrice), cxs: cxs),
                Col(
                  t1: 'Тоо ширхэг',
                  t2: order.totalCount!.toString(),
                  cxs: cxs,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Col(
                    t1: 'Үүссэн огноо',
                    t2: order.createdOn!.substring(0, 10),
                    cxs: cxs),
                Col(
                  t1: 'Төлөв',
                  t2: getStatus(order.status!),
                  cxs: cxs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    setPayType(widget.pt);
    setState(() {
      nc.text = widget.note;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Wrap(
          runSpacing: 15,
          children: [
            const Text('Захиалгын мэдээлэл засах'),
            input('Нэмэлт тайлбар', nc, null, null),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: .8),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      myRadio('T', 'Дансаар'),
                      myRadio('C', 'Бэлнээр'),
                      myRadio('L', 'Зээлээр'),
                    ],
                  ),
                ],
              ),
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

  Widget myRadio(String val, String title) {
    return Row(
      children: [
        Radio(
          value: val,
          groupValue: payType,
          onChanged: (String? value) {
            setPayType(value!);
          },
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14.0),
        )
      ],
    );
  }
}

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

  List<String> processes = [
    'Шинэ',
    'Бэлтгэж эхэлсэн',
    'Бэлэн болсон',
    'Түгээлтэнд гарсан',
    'Хүргэгдсэн'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmProvider>(
      builder: (context, pp, child) {
        var cxs = CrossAxisAlignment.center;
        final order = pp.orderDets[0];
        return (felching == true)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                body: DefaultBox(
                  title: 'Захиалгын дэлгэрэнгүй',
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: [
                        Box(
                          child: EasyStepper(
                            activeStep: getProcessNumber(order.process),
                            showLoadingAnimation: false,
                            activeStepBorderColor: Colors.green,
                            activeStepBorderType: BorderType.normal,
                            lineStyle: const LineStyle(
                                lineType: LineType.normal,
                                finishedLineColor: Colors.green),
                            unreachedStepBackgroundColor: Colors.transparent,
                            unreachedStepBorderColor: Colors.transparent,
                            finishedStepBackgroundColor: Colors.transparent,
                            borderThickness: 2,
                            steps: [
                              ...processes.map((p) => step(
                                  title: p,
                                  idx: processes.indexOf(p),
                                  process: order.process))
                            ],
                          ),
                        ),
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
                        (order.note == 'null')
                            ? const SizedBox()
                            : Box(
                                child: SelectableText(
                                  'Тайлбар: ${order.note}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12),
                                ),
                              ),
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
                        CustomButton(
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
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }

  EasyStep step(
      {required String title, required int idx, required String process}) {
    bool reached =
        (getProcessNumber(process) == idx || getProcessNumber(process) >= idx);
    return EasyStep(
      customStep: Image.asset(
        reached ? 'assets/icons/check.png' : 'assets/icons/circle.png',
        height: 30,
      ),
      customTitle: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
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
                    color: AppColors.primary),
              ),
            ),
            input('Тоо ширхэг оруулна уу', qtyController, null,
                TextInputType.number),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (int.parse(qtyController.text) == 0) {
                  message(
                      message: 'Тоо ширхэг 0 байж болохгүй!', context: context);
                } else {
                  p
                      .changeItemQty(
                        oId: oid,
                        itemId: item.productId,
                        qty: int.parse(
                          qtyController.text,
                        ),
                        context: context,
                      )
                      .then((e) => Navigator.pop(context));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
