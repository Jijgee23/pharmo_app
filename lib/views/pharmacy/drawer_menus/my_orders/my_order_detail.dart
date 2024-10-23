import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/box.dart';

class MyOrderDetail extends StatefulWidget {
  final int id;
  final MyOrderModel order;
  final String orderNo;
  final int? process;
  const MyOrderDetail(
      {super.key,
      required this.id,
      required this.order,
      required this.orderNo,
      this.process});

  @override
  State<MyOrderDetail> createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail> {
  late MyOrderProvider orderProvider;
  @override
  void initState() {
    orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    orderProvider.getMyorderDetail(widget.id);
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
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          extendBody: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.chevron_left),
                      ),
                      Constants.boxH10,
                      Text('Захиалгын дугаар: ${widget.orderNo}',
                          style: const TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cleanWhite,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Box(
                          child: EasyStepper(
                            activeStep: widget.process!,
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
                              ...processes.map((p) =>
                                  step(title: p, idx: processes.indexOf(p)))
                            ],
                          ),
                        ),
                        Box(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              col(
                                  t1: 'Дүн',
                                  t2: '${widget.order.totalPrice.toString()} ₮'),
                              col(
                                  t1: 'Тоо ширхэг',
                                  t2: widget.order.totalCount.toString()),
                              col(
                                  t1: 'Нийлүүлэгч',
                                  t2: widget.order.supplier.toString()),
                            ],
                          ),
                        ),
                        Box(
                          child: Scrollbar(
                            thickness: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...provider.orderDetails.map(
                                    (o) => productBuilder(o),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  col({required String t1, required String t2, Color? t2Color}) {
    return Column(
      children: [
        Text(
          t1,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Text(
          t2,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: t2Color),
        ),
      ],
    );
  }

  EasyStep step({required String title, required int idx}) {
    bool reached = (widget.process == idx || widget.process! >= idx);
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

  Container productBuilder(MyOrderDetailModel o) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 5)],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                o.itemName.toString(),
                softWrap: true,
                maxLines: 2,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              col(t1: 'Тоо ширхэг', t2: o.iQty.toString()),
              col(
                  t1: 'Нэгж үнэ',
                  t2: '${o.itemPrice}₮',
                  t2Color: AppColors.primary),
              col(
                  t1: 'Нийт үнэ',
                  t2: '${o.itemTotalPrice.toString()}₮',
                  t2Color: AppColors.primary),
            ],
          )
        ],
      ),
    );
  }
}
