import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/myorder_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders> {
  bool scrolling = false;
  late MyOrderProvider orderProvider;
  List<SellerOrderModel> displayProducts = <SellerOrderModel>[];
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
    final size = MediaQuery.of(context).size;
    return Consumer<MyOrderProvider>(
      builder: (_, provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Column(
              children: [
                const Text(
                  'Захиалгууд',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    mtext(AppColors.succesColor, ' Төлбөр төлөгдсөн'),
                    mtext(AppColors.failedColor, 'Төлбөр хүлээгдэж буй'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    mtext(AppColors.secondary, 'Цуцлагдсан'),
                    mtext(AppColors.primary, 'Биелсэн'),
                  ],
                )
              ],
            ),
            centerTitle: true,
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                if (notification.metrics.atEdge) {
                  setState(() {
                    scrolling = false;
                  });
                } else {
                  setState(() {
                    scrolling = true;
                  });
                }
              }
              if (notification is ScrollUpdateNotification &&
                  notification.scrollDelta! < 0) {
                setState(() {
                  scrolling = false;
                });
              }
              if (notification is ScrollUpdateNotification &&
                  notification.scrollDelta! > 0) {
                setState(() {
                  scrolling = true;
                });
              }
              return true;
            },
            child: Column(
              children: [
                scrolling
                    ? const SizedBox(
                        height: 0,
                      )
                    : Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _selectDate(context);
                                    },
                                    child: Text(
                                      selectedDate.toString().substring(0, 10),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_right_alt),
                                  TextButton(
                                    onPressed: () {
                                      _selectDate2(context);
                                    },
                                    child: Text(
                                      selectedDate2.toString().substring(0, 10),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      if (selectedDate == selectedDate2) {
                                        orderProvider
                                            .getSellerOrdersByDateSingle(
                                                selectedDate
                                                    .toString()
                                                    .substring(0, 10));
                                      } else {
                                        orderProvider
                                            .getSellerOrdersByDateRanged(
                                                selectedDate
                                                    .toString()
                                                    .substring(0, 10),
                                                selectedDate2
                                                    .toString()
                                                    .substring(0, 10));
                                      }
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
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
                  child: ListView.builder(
                    itemCount: provider.sellerOrders.length,
                    itemBuilder: (context, index) {
                      String? process = provider.sellerOrders[index].process;
                      String? status = provider.sellerOrders[index].status;
                      return Card(
                        color: AppColors.primary,
                        child: ListTile(
                          onTap: () {
                            showBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadiusDirectional.only(
                                      topEnd: Radius.circular(
                                        size.width * 0.1,
                                      ),
                                      topStart: Radius.circular(
                                        size.width * 0.1,
                                      ),
                                    ),
                                  ),
                                  height: size.height * 0.7,
                                  width: size.width,
                                  padding: EdgeInsets.all(
                                    size.width * 0.08,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Align(
                                        child: Text(
                                          'Дэлгэрэнгүй',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                      wtxt(
                                          'Захиалагч: ${provider.sellerOrders[index].user}'),
                                      wtxt(
                                          'Нийт барааны тоо ширхэг: ${provider.sellerOrders[index].totalCount.toString()}'),
                                      wtxt(
                                          'Нийт үнийн дүн: ${provider.sellerOrders[index].totalPrice.toString()}'),
                                      wtxt(
                                          'Хаяг: ${provider.sellerOrders[index].branch?.address != null ? provider.sellerOrders[index].branch!.address : 'Үндсэн салбар'},'),
                                      wtxt(
                                          'Qpay-ээр төлсөн эсэх: ${provider.sellerOrders[index].qp == true ? 'Тийм' : 'Үгүй'}'),
                                      wtxt(
                                          'Захиалга үүссэн огноо: ${provider.sellerOrders[index].createdOn}'),
                                      wtxt(
                                          'Захиалга дууссан огноо: ${provider.sellerOrders[index].endedOn ?? 'Дуусаагүй'}'),
                                      wtxt(
                                          'Тайлбартай эсэх: ${provider.sellerOrders[index].note == true ? 'Тийм' : 'Үгүй'}'),
                                      Align(
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.arrow_downward,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          title: Text('${provider.sellerOrders[index].user}',
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                              'Хаяг: ${provider.sellerOrders[index].branch?.address}',
                              style: const TextStyle(color: Colors.white)),
                          trailing: Text(
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
                              style: const TextStyle(color: Colors.white)),
                          leading: Icon(
                            Icons.circle,
                            color: status == 'W'
                                ? AppColors.failedColor
                                : status == 'P'
                                    ? AppColors.succesColor
                                    : status == 'S'
                                        ? AppColors.secondary
                                        : AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      style: const TextStyle(color: Colors.white),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
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
