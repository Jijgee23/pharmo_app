import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/models/my_order_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class MyOrderDetail extends StatefulWidget {
  final int id;
  final String orderNo;
  final int? process;
  const MyOrderDetail(
      {super.key, required this.id, required this.orderNo, this.process});

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

  custom(String text, int index) {
    bool selected = widget.process == index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: (selected) ? Colors.tealAccent : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Icon(
          (index == 4) ? null : Icons.arrow_downward,
          color: Colors.black,
        )
      ],
    );
  }

  List<String> processes = [
    'Шинэ',
    'Бэлтгэж эхэлсэн',
    'Бэлэн болсон',
    'Түгээлтэнд гарсан',
    'Хүргэгдсэн'
  ];
  bool isList = false;
  btn(String t, bool v) {
    bool selected = (isList == v);
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => setState(() {
        isList = v;
      }),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.primary,
          ),
        ),
        child: Center(
          child: Text(
            t,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(builder: (context, provider, child) {
      return Scaffold(
        extendBody: true,
        appBar: AppBar(),
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [btn('Бараанууд', false), btn('Явц', true)],
                // ),
                ...processes.map((p) => custom(p, processes.indexOf(p))),
                Expanded(
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
                ),
              ],
            )),
      );
    });
  }

  Container productBuilder(MyOrderDetailModel o) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade500, blurRadius: 5)],
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Нэр: ${o.itemName.toString()}'),
          Text('Үнэ: ${o.itemPrice.toString()}₮'),
          Text('Тоо ширхэг ${o.iQty.toString()}'),
          Text('Нийт үнэ: ${o.itemTotalPrice.toString()}₮'),
        ],
      ),
    );
  }
}
