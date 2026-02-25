import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_order_location.dart';
import 'package:pharmo_app/views/DRIVER/widgets/status_changer.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/order_items_builder.dart';

class DeliveryDetail extends StatefulWidget {
  final int orderId;
  const DeliveryDetail({super.key, required this.orderId});

  @override
  State<DeliveryDetail> createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  DeliveryOrder findOrder() {
    final jagger = context.read<JaggerProvider>();
    return jagger.delivery!.orders.firstWhere((e) => e.id == widget.orderId);
  }

  String getName() {
    final order = findOrder();
    return order.orderer?.name ??
        order.customer?.name ??
        order.user?.name ??
        'Тодорхойгүй';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        DeliveryOrder order = findOrder();
        bool hasLoc =
            (order.orderer?.lat != null && order.orderer?.lat != 'null');
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text('Захиалга: ${order.orderNo}'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: controller,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'Ерөнхий'),
                    Tab(text: 'Бараа'),
                    Tab(text: 'Байршил'),
                  ],
                  overlayColor: WidgetStateProperty.all(
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SectionCard(
                      title: 'Үндсэн мэдээлэл',
                      child: Column(
                        children: [
                          ModernDetailRow(' Захиалагч', getName()),
                          DividerBuidler(),
                          ModernDetailRow(
                            'Нийт үнэ',
                            toPrice(order.totalPrice),
                            valueColor: Colors.green.shade700,
                          ),
                          DividerBuidler(),
                          ModernDetailRow(
                            'Тоо ширхэг',
                            '${order.totalCount} ширхэг',
                          ),
                          DividerBuidler(),
                          ModernDetailRow(
                              'Төлбөрийн хэлбэр', order.paymentType.name),
                          DividerBuidler(),
                          ModernDetailRow('Төлөв', status(order.status)),
                          DividerBuidler(),
                          ModernDetailRow('Явц', order.orderProcess.name),
                          DividerBuidler(),
                          ModernDetailRow(
                            'Огноо',
                            order.createdOn.substring(0, 10),
                          ),
                        ],
                      ),
                    ),

                    // 4. Үйлдлийн товчнууд
                    SectionCard(
                      title: '',
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: ModernActionButton(
                              label: 'Төлөв өөрчлөх',
                              icon: Icons.edit_note,
                              color: primary,
                              onTap: () async => await Get.bottomSheet(
                                StatusChanger(order: findOrder()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ).paddingAll(10),
              ),
              OrderItemsTab(products: order.items, orderId: order.id),
              Builder(
                builder: (context) {
                  if (hasLoc) {
                    return SizedBox(
                      height: 150,
                      child: DeliveryOrderLocation(
                        order: order,
                      ),
                    );
                  }
                  return Center(child: Text('Захиалагчын байршил тодорхойгүй'));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
