import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders> {
  late MyOrderProvider orderProvider;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  @override
  void initState() {
    super.initState();
    orderProvider = Provider.of<MyOrderProvider>(context, listen: false);
    orderProvider.getSellerOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyOrderProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            leading: const ChevronBack(),
            title: const Text(
              'Захиалгууд',
              style: TextStyle(fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(selectedDate.toString().substring(0, 10),
                            style: const TextStyle(color: AppColors.primary))),
                    const Icon(Icons.arrow_right_alt),
                    TextButton(
                        onPressed: () => _selectDate2(context),
                        child: Text(selectedDate2.toString().substring(0, 10),
                            style: const TextStyle(color: AppColors.primary))),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade800,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 7.5, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          if (selectedDate == selectedDate2) {
                            orderProvider.getSellerOrdersByDateSingle(
                                selectedDate.toString().substring(0, 10));
                          } else {
                            orderProvider.getSellerOrdersByDateRanged(
                                selectedDate.toString().substring(0, 10),
                                selectedDate2.toString().substring(0, 10));
                          }
                        },
                        child: const Text(
                          'Шүүх',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 14,
                  child: provider.sellerOrders.isNotEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            children: provider.sellerOrders
                                .map((e) => OrderWidget(
                                    order: provider.sellerOrders[
                                        provider.sellerOrders.indexOf(e)]))
                                .toList(),
                          ),
                        )
                      : const NoResult()),
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

  _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: 'Огноо сонгох',
      cancelText: 'Буцах',
      confirmText: "Сонгох",
      initialDate: selectedDate2,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
      });
    }
  }
}

class OrderWidget extends StatefulWidget {
  final SellerOrderModel order;
  const OrderWidget({super.key, required this.order});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: InkWell(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row('Захиалагч:', widget.order.user!),
            row('Дугаар:', widget.order.orderNo!.toString()),
            isExpanded
                ? Column(
                    children: [
                      row('Нийт үнэ:', '${widget.order.totalPrice!}₮'),
                      row('Тоо ширхэг:', widget.order.totalCount!.toString()),
                      row('Төлөв:', getStatus(widget.order.status!)),
                      row('Явц:', getProcess(widget.order.process!)),
                      row('Төлбөрийн хэлбэр:',
                          getPayType(widget.order.payType!)),
                      row('Үүссэн огноо:',
                          widget.order.createdOn!.substring(0, 10)),
                      row(
                          'Дууссан огноо:',
                          widget.order.endedOn != null
                              ? widget.order.endedOn!
                              : '-'),
                      row('QPay:', (widget.order.qp != null) ? 'Тийм' : 'Үгүй'),
                      row('Тайлбар:',
                          (widget.order.note != null) ? 'Тийм' : 'Үгүй'),
                      // row(
                      //     'Борлуулагч:',
                      //     (widget.order.seller != null)
                      //         ? '${widget.order.seller!}'
                      //         : 'Үгүй'),
                      // row(
                      //     'Түгээгч:',
                      //     (widget.order.delman != null)
                      //         ? '${widget.order.delman!}'
                      //         : 'Үгүй'),
                      // row(
                      //     'Бэлтгэгч:',
                      //     (widget.order.packer != null)
                      //         ? '${widget.order.packer!}'
                      //         : 'Үгүй'),
                    ],
                  )
                : const SizedBox(),
            !isExpanded
                ? const Center(child: Icon(Icons.arrow_drop_down_rounded))
                : const Center(child: Icon(Icons.arrow_drop_up_rounded))
          ],
        ),
      ),
    );
  }

  row(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade800)),
        Text(value,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis))
      ],
    );
  }

  getProcess(String process) {
    if (process == 'M') {
      return 'Бэлтгэж эхэлсэн';
    } else if (process == 'N') {
      return 'Шинэ';
    } else if (process == 'P') {
      return 'Бэлэн болсон';
    } else if (process == 'A') {
      return 'Хүлээн авсан';
    } else if (process == 'C') {
      return 'Хааллтай';
    } else {
      return 'Буцаагдсан';
    }
  }

  getStatus(String status) {
    if (status == 'W') {
      return 'Төлбөр хүлээгдэж буй';
    } else if (status == 'P') {
      return 'Төлбөр төлөгдсөн';
    } else if (status == 'S') {
      return 'Цуцлагдсан';
    } else if (status == 'C') {
      return 'Биелсэн';
    } else {
      return 'Тодорхой биш';
    }
  }

  getPayType(String payType) {
    if (payType == 'L') {
      return 'Зээлээр';
    } else if (payType == 'C') {
      return 'Бэлнээр';
    } else {
      return 'Дансаар';
    }
  }
}
