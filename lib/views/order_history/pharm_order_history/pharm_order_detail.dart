import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_general_builder.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_items_builder.dart';

class PharmOrderDetail extends StatefulWidget {
  final OrderModel order;
  const PharmOrderDetail({super.key, required this.order});

  @override
  State<PharmOrderDetail> createState() => _PharmOrderDetailState();
}

class _PharmOrderDetailState extends State<PharmOrderDetail>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await getDetails(),
    );
  }

  Future getDetails() async {
    await LoadingService.run(
      () async {
        print(widget.order.orderNo);
        final r =
            await api(Api.get, 'pharmacy/orders/${widget.order.id}/items/');
        if (r == null) return;
        final data = convertData(r);
        print(data);
        if (r.statusCode == 200) {
          products = (data as List).toList();
          setState(() {});
        }
      },
    );
  }

  List<dynamic> products = [];
  late TabController controller;
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Consumer<OrderProvider>(
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
          body: TabBarView(
            controller: controller,
            children: [
              OrderGeneralBuilder(order: order),
              OrderItemsTab(products: products, orderId: order.id),
            ],
          ),
        );
      },
    );
  }
}
