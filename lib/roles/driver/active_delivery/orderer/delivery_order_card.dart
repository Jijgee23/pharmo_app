import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/delivery_detail.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';
import 'package:pharmo_app/roles/driver/widgets/status_changer.dart';

/// An order on a delivery: who, which, how much, and its delivery state.
/// On the active delivery it can be marked delivered or have its state
/// changed; given an [order] (a past delivery) it is read-only.
class DeliveryOrderCard extends StatelessWidget {
  final int orderId;
  final DeliveryOrder? order;

  const DeliveryOrderCard({super.key, required this.orderId, this.order});

  @override
  Widget build(BuildContext context) {
    if (order != null) return _card(context, order!, editable: false);
    return Consumer<JaggerProvider>(
      builder: (context, provider, child) {
        final found = provider.delivery?.orders.where((e) => e.id == orderId).firstOrNull;
        if (found == null) return const SizedBox();
        return _card(context, found, editable: true);
      },
    );
  }

  Widget _card(BuildContext context, DeliveryOrder order, {required bool editable}) {
    final createdAt = parseDateTime(order.createdOn);
    final pay = order.paymentType;
    final count = order.totalCount;
    return Material(
      color: white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => goto(DeliveryDetail(orderId: order.id, readOnly: !editable)),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          order.recipientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          [
                            '#${order.orderNo}',
                            if (createdAt != null) friendlyDateTime(createdAt),
                          ].join('  ·  '),
                          style: TextStyle(fontSize: 12.5, color: grey500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    toPrice(order.totalPrice),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ProcessChip(order.orderProcess),
                  if (pay != PayType.unknown) _tag(Icons.payments_outlined, pay.name),
                  if (count > 0)
                    _tag(
                      Icons.inventory_2_outlined,
                      '${count % 1 == 0 ? count.toInt() : count} ширхэг',
                    ),
                ],
              ),
              if (editable) ...[
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [
                    if (!order.isHandled)
                      Expanded(
                        child: CardAction(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Хүргэсэн',
                          color: Colors.green,
                          onPressed: () => _markDelivered(context, order),
                        ),
                      ),
                    Expanded(
                      child: CardAction(
                        icon: Icons.tune_rounded,
                        label: 'Төлөв солих',
                        color: Colors.blueGrey,
                        onPressed: () => showOrderStatusSheet(order),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: grey100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 13, color: grey600),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: grey600),
          ),
        ],
      ),
    );
  }

  // The usual outcome, one tap away; the sheet has the rest.
  Future<void> _markDelivered(BuildContext context, DeliveryOrder order) async {
    final jagger = context.read<JaggerProvider>();
    await LoadingService.run(() => jagger.setOrderProcess(order, OrderProcess.delivered));
  }
}
