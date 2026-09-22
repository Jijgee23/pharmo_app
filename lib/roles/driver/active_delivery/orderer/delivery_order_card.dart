import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/delivery_detail.dart';
import 'package:pharmo_app/roles/driver/widgets/status_changer.dart';

class DeliveryOrderCard extends StatelessWidget {
  final int orderId;
  final DeliveryOrder? order;

  const DeliveryOrderCard({super.key, required this.orderId, this.order});

  @override
  Widget build(BuildContext context) {
    if (order != null) return _buildOrderCard(context, order!);
    return Consumer<JaggerProvider>(
      builder: (context, provider, child) {
        final found = provider.delivery?.orders.where((e) => e.id == orderId).firstOrNull;
        if (found == null) return const SizedBox();
        return _buildOrderCard(context, found);
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    DeliveryOrder order,
  ) {
    return OrderSummaryCard(
      name: getName(order),
      price: order.totalPrice.toString(),
      orderNo: order.orderNo,
      status: order.orderStatus,
      processText: order.orderProcess.name,
      processColor: Colors.blue,
      createdOn: order.createdOn,
      onTap: () => goto(DeliveryDetail(orderId: order.id)),
      actionLabel: 'Төлөв өөрчлөх',
      onAction: () async => await Get.bottomSheet(StatusChanger(order: order)),
    );
  }

  String getName(DeliveryOrder order) {
    if (order.orderer != null && order.orderer!.name != 'null') {
      return order.orderer!.name;
    } else if (order.customer != null && order.customer!.name != 'null') {
      return order.customer!.name;
    } else {
      return order.user?.name ?? '';
    }
  }
}
