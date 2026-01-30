import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_order_card.dart';

class OrdererOrders extends StatelessWidget {
  final String ordererName;
  final List<DeliveryOrder> orders;
  final int delId;
  const OrdererOrders({
    super.key,
    required this.ordererName,
    required this.orders,
    required this.delId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey100,
      appBar: AppBar(
        title: Text(ordererName),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, idx) {
          final order = orders[idx];
          return DeliveryOrderCard(order: order, delId: delId);
        },
      ).paddingAll(14),
    );
  }
}
