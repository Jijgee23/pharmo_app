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
                                : Colors.blue,
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
