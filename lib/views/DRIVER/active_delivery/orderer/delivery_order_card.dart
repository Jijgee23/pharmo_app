import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_detail.dart';
import 'package:pharmo_app/views/DRIVER/widgets/status_changer.dart';
import 'package:pharmo_app/views/order_history/order_card/order_status_chip.dart';
import 'package:pharmo_app/views/order_history/order_card/user_tag.dart';

class DeliveryOrderCard extends StatelessWidget {
  final int orderId;

  const DeliveryOrderCard({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, provider, child) {
        DeliveryOrder order =
            provider.delivery!.orders.firstWhere((e) => e.id == orderId);

        return _buildOrderCard(context, provider, order);
      },
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    JaggerProvider jagger,
    DeliveryOrder order,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => goto(DeliveryDetail(orderId: order.id)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserTag(name: getName(order)),
                    const SizedBox(width: 12),
                    OrderCardPriceAndNo(
                      price: order.totalPrice.toString(),
                      orderNo: order.orderNo,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
              _buildBody(context, order),
            ],
          ),
        ),
      ),
    );
  }

  String getName(DeliveryOrder order) {
    if (order.orderer != null && order.orderer!.name != 'null') {
      return order.orderer!.name;
    } else if (order.customer != null && order.customer!.name != 'null') {
      return order.customer!.name;
    } else {
      return order.user!.name;
    }
  }

  Widget _buildBody(BuildContext context, DeliveryOrder order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderStatusChip(order.orderStatus),
                    const SizedBox(height: 8),
                    if (order.process != null)
                      IconedText(
                        icon: Icons.sync_outlined,
                        text: order.orderProcess.name,
                        color: Colors.blue,
                      ),
                    const SizedBox(height: 4),
                    if (order.createdOn != null)
                      IconedText(
                        icon: Icons.calendar_today_outlined,
                        text: order.createdOn.length > 10
                            ? order.createdOn.substring(0, 10)
                            : order.createdOn,
                        color: Colors.grey.shade600,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () async =>
                    await Get.bottomSheet(StatusChanger(order: order)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: succesColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Төлөв өөрчлөх',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class OrderCardPriceAndNo extends StatelessWidget {
  final String price, orderNo;
  const OrderCardPriceAndNo({
    super.key,
    required this.price,
    required this.orderNo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          toPrice(price),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          '#$orderNo',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
