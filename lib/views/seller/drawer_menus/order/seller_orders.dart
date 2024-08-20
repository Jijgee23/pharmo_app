import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
          backgroundColor: AppColors.cleanWhite,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.primary,
              ),
            ),
            title: Column(
              children: [
                const Text(
                  'Захиалгууд',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mtext(AppColors.failedColor, 'Төлбөр хүлээгдэж буй'),
                        mtext(AppColors.succesColor, ' Төлбөр төлөгдсөн'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mtext(AppColors.secondary, 'Цуцлагдсан'),
                        mtext(AppColors.primary, 'Биелсэн'),
                      ],
                    )
                  ],
                )
              ],
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              child: Text(
                                  selectedDate.toString().substring(0, 10),
                                  style: const TextStyle(
                                      color: AppColors.primary))),
                          const Icon(Icons.arrow_right_alt),
                          TextButton(
                              onPressed: () {
                                _selectDate2(context);
                              },
                              child: Text(
                                  selectedDate2.toString().substring(0, 10),
                                  style: const TextStyle(
                                      color: AppColors.primary))),
                          OutlinedButton(
                            onPressed: () {
                              if (selectedDate == selectedDate2) {
                                orderProvider.getSellerOrdersByDateSingle(
                                    selectedDate.toString().substring(0, 10));
                              } else {
                                orderProvider.getSellerOrdersByDateRanged(
                                    selectedDate.toString().substring(0, 10),
                                    selectedDate2.toString().substring(0, 10));
                              }
                            },
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    AppColors.primary)),
                            child: const Text(
                              'Шүүх',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 9,
                  child: provider.sellerOrders.isNotEmpty
                      ? ListView.builder(
                          itemCount: provider.sellerOrders.length,
                          itemBuilder: (context, index) {
                            final order = provider.sellerOrders[index];
                            String? process =
                                provider.sellerOrders[index].process;
                            String? status =
                                provider.sellerOrders[index].status;
                            return Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.only(right: 10),
                                    childrenPadding: const EdgeInsets.all(5),
                                    iconColor: AppColors.primary,
                                    title: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 16,
                                            color: status == 'W'
                                                ? AppColors.failedColor
                                                : status == 'P'
                                                    ? AppColors.succesColor
                                                    : status == 'S'
                                                        ? AppColors.secondary
                                                        : AppColors.primary,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${order.user}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text('${order.createdOn}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Column(
                                          children: [
                                            _infoRow(
                                              'Явц:',
                                              process == 'M'
                                                  ? 'Бэлтгэж эхэлсэн'
                                                  : process == 'N'
                                                      ? 'Шинэ'
                                                      : process == 'P'
                                                          ? 'Бэлэн болсон'
                                                          : process == 'A'
                                                              ? 'Хүлээн авсан'
                                                              : process == 'C'
                                                                  ? 'Хааллтай'
                                                                  : 'Буцаагдсан',
                                            ),
                                            _infoRow('Нийт барааны тоо ширхэг:',
                                                    order.totalCount.toString()) ??
                                                '-',
                                            _infoRow('Нийт үнийн дүн:',
                                                    order.totalPrice.toString()) ??
                                                '-',
                                            _infoRow('Qpay-ээр төлсөн эсэх:',
                                                order.qp == true ? 'Тийм' : 'Үгүй'),
                                            _infoRow('Хаяг:',
                                                order.branch?.address ?? '-'),
                                            _infoRow('Дууссан огноо:',
                                                    order.endedOn ?? 'Дуусаагүй') ??
                                                '-',
                                            _infoRow('Дугаар:',
                                                    order.id.toString()) ??
                                                '-',
                                            _infoRow(
                                                    'Тайлбартай:',
                                                    order.note == true
                                                        ? 'Тийм'
                                                        : 'Үгүй') ??
                                                '-',
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Divider(color: Colors.grey.shade700,),
                                )
                              ],
                            );
                          },
                        )
                      : const NoResult()),
            ],
          ),
        );
      },
    );
  }

  _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        wtxt(title),
        wtxt(value),
      ],
    );
  }

  Widget mtext(Color color, String text) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: 10,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        )
      ],
    );
  }

  Widget wtxt(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
      ),
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
