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
  late MyOrderProvider orderProvider;
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
          body: ListView.builder(
            itemCount: provider.sellerOrders.length,
            itemBuilder: (context, index) {
              String? process = provider.sellerOrders[index].process;
              String? status = provider.sellerOrders[index].status;
              return Card(
                child: ListTile(
                  onTap: () {
                    showBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                             const Align(
                                child: Text('Дэлгэрэнгүй'),
                              ),
                              Text(
                                  'Захиалагч: ${provider.sellerOrders[index].user}'),
                              Text(
                                  'Захиалгын дугаар: ${provider.sellerOrders[index].orderNo}'),
                              Text(
                                  'Нийт барааны тоо ширхэг: ${provider.sellerOrders[index].totalCount.toString()}'),
                              Text(
                                  'Нийт үнийн дүн: ${provider.sellerOrders[index].totalPrice.toString()}'),
                              Text(
                                  'Хаяг: ${provider.sellerOrders[index].branch?.address != null ? provider.sellerOrders[index].branch!.address : 'Үндсэн салбар'},'),
                              Text(
                                  'Qpay-ээр төлсөн эсэх: ${provider.sellerOrders[index].qp == true ? 'Тийм' : 'Үгүй'}'),
                              Text(
                                  'Захиалга үүссэн огноо: ${provider.sellerOrders[index].createdOn}'),
                              Text(
                                  'Захиалга дууссан огноо: ${provider.sellerOrders[index].endedOn ?? 'Дуусаагүй'}'),
                              Text(
                                  'Тайлбартай эсэх: ${provider.sellerOrders[index].note == true ? 'Тийм' : 'Үгүй'}'),
                              Text(
                                  'Борлуулагч: ${provider.sellerOrders[index].seller ?? 'Байхгүй'}'),
                              Text(
                                  'Хүргэлтийн ажилтан: ${provider.sellerOrders[index].delman ?? 'Байхгүй'}'),
                              Text(
                                  'Бэлтгэгч: ${provider.sellerOrders[index].packer ?? 'Байхгүй'}'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  title: Text('${provider.sellerOrders[index].user}'),
                  subtitle: Text(
                      'Захиалгын № : ${provider.sellerOrders[index].id.toString()}'),
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
                  ),
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
}
