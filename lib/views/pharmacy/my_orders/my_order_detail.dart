import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/myorder_provider.dart';
import 'package:pharmo_app/controller/models/my_order.dart';
import 'package:pharmo_app/controller/models/my_order_detail.dart';
import 'package:pharmo_app/views/cart/cart_item.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class MyOrderDetail extends StatefulWidget {
  final MyOrderModel order;
  const MyOrderDetail({super.key, required this.order});

  @override
  State<MyOrderDetail> createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => getDetails(),
    );
  }

  Future getDetails() async {
    LoadingService.run(
      () async {
        final res =
            await api(Api.get, 'pharmacy/orders/${widget.order.id}/items/');
        if (res == null) return;
        final data = convertData(res);
        if (res.statusCode == 200) {
          products = (data as List)
              .map((e) => MyOrderDetailModel.fromJson(e))
              .toList();
          setState(() {});
        }
      },
    );
  }

  List<MyOrderDetailModel> products = [];
  late TabController controller;
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Захиалгын дэлгэрэнгүй',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            bottom: TabBar(
              indicatorColor: Colors.teal,
              indicatorSize: TabBarIndicatorSize.tab,
              controller: controller,
              tabs: [
                Tab(text: 'Ерөнхий'),
                Tab(text: 'Бараа'),
              ],
              overlayColor: WidgetStatePropertyAll(
                Colors.purple.withAlpha(50),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(14),
            child: TabBarView(
              controller: controller,
              children: [
                SingleChildScrollView(
                  child: Column(
                    spacing: 15,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          t('Огноо', order.createdOn!.substring(0, 10)),
                          t(
                            'Цаг/мин',
                            order.createdOn!.substring(10, 16),
                            cxs: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                      t('Захиалгын дугаар', '#${widget.order.orderNo}'),
                      if (order.process != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            t('Явц', order.process!),
                          ],
                        ),
                      if (order.status != null) t('Төлөв', order.status!),
                      if (order.supplier != null)
                        t('Нийлүүлэгч', widget.order.supplier!),
                      if (order.payType != null)
                        t('Төлбөрийн хэлбэр', order.payType!),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        if (products.isEmpty) {
                          return Column(
                            children: [NoResult()],
                          );
                        }
                        return ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, idx) {
                            var order = products[idx];
                            return ListTile(
                              leading: Text((idx + 1).toString()),
                              dense: true,
                              title: Text(
                                '${order.itemName!} x ${order.itemQty}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Анх захиалсан: ${order.iQty}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Text(
                                toPrice(order.itemTotalPrice),
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    Divider(color: grey500),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        t('Нийт ширхэг', order.totalCount.toString()),
                        t('Нийт дүн', toPrice(order.totalPrice)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
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
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          v2,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget col({required String t1, required String t2, Color? t2Color}) {
    return Column(
      children: [
        Text(
          t1,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          t2,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: t2Color,
          ),
        ),
      ],
    );
  }
}

class TitleContainer extends StatelessWidget {
  final Widget child;
  const TitleContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
