import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/myorder_provider.dart';
import 'package:pharmo_app/controller/models/my_order.dart';
import 'package:pharmo_app/controller/models/my_order_detail.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

class MyOrderDetail extends StatefulWidget {
  final MyOrderModel order;
  const MyOrderDetail({super.key, required this.order});

  @override
  State<MyOrderDetail> createState() => _MyOrderDetailState();
}

class _MyOrderDetailState extends State<MyOrderDetail> {
  bool fetching = false;
  setFetching(bool n) {
    setState(() {
      fetching = n;
    });
  }

  @override
  void initState() {
    super.initState();
    setFetching(true);
    getDetails();
  }

  getDetails() async {
    final res = await api(Api.get, 'pharmacy/orders/${widget.order.id}/items/');
    final data = convertData(res!);
    if (res.statusCode == 200) {
      setState(() {
        products =
            (data as List).map((e) => MyOrderDetailModel.fromJson(e)).toList();
      });
    }
    if (mounted) setFetching(false);
  }

  List<MyOrderDetailModel> products = [];

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Consumer<MyOrderProvider>(
      builder: (context, provider, child) {
        return DataScreen(
          onRefresh: () => getDetails(),
          appbar: SideAppBar(text: 'Захиалгын дэлгэрэнгүй', hasRect: false),
          loading: fetching,
          empty: false,
          bg: primary,
          pad: EdgeInsets.all(0),
          child: Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
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
                  Divider(color: grey500),
                  t('', 'Бараанууд'),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      minHeight: 100,
                    ),
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, idx) {
                          var order = products[idx];
                          return ListTile(
                            leading: Text(
                              (idx + 1).toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                            tileColor: Colors.grey.withAlpha(20),
                            dense: true,
                            title: Text(
                              '${order.itemName!} x ${order.itemQty}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Divider(color: grey500),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      t('Нийт ширхэг', order.totalCount.toString()),
                      t('Нийт дүн', toPrice(order.totalPrice)),
                    ],
                  ),
                  SizedBox(height: Sizes.height * .3)
                ],
              ),
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
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          v2,
          style: TextStyle(
            color: Colors.black,
            fontSize: Sizes.mediumFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget col({required String t1, required String t2, Color? t2Color}) {
    return Column(
      children: [
        Text(t1,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(t2,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: t2Color)),
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
