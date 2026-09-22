import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/delivery_order_card.dart';
import 'package:pharmo_app/roles/driver/delivery_history/delivery_summary_card.dart';

class ShipmentHistoryDetail extends StatelessWidget {
  final Delivery delivery;
  const ShipmentHistoryDetail({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey50,
      appBar: SideAppBar(text: 'Түгээлтийн дугаар: ${delivery.id}'),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          DeliverySummaryCard(
            delivery: delivery,
            thirdInfoLabel: 'Түгээгч',
            thirdInfoValue: delivery.delman.name,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Захиалгууд (${delivery.orders.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          if (delivery.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: NoResult(),
            )
          else
            ...delivery.orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DeliveryOrderCard(orderId: order.id, order: order),
              ),
            ),
        ],
      ),
    );
  }
}
