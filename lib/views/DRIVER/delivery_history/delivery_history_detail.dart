import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_order_card.dart';

class ShipmentHistoryDetail extends StatelessWidget {
  final Delivery delivery;
  const ShipmentHistoryDetail({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideAppBar(text: 'Түгээлтийн дугаар: ${delivery.id}'),
      body: ListView.builder(
        itemCount: delivery.orders.length,
        itemBuilder: (context, index) {
          final order = delivery.orders[index];
          return DeliveryOrderCard(
            order: order,
            delId: delivery.id,
          );
        },
      ).paddingAll(10),
    );
  }
}
