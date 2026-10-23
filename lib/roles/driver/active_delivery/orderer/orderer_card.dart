import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/customer_payment_sheet.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/orderer_orders.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';

/// A stop on the delivery: who, how many of their orders are done, and the
/// ways to take a payment or get directions. Tapping it lists the orders.
class OrdererCard extends StatelessWidget {
  final DeliveryStop stop;
  const OrdererCard({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    final name = stop.name;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final coordinates = stop.coordinates;
    final customerId = stop.customerId;
    final done = stop.isDone;
    return Material(
      color: white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => goto(OrdererOrders(stopKey: stop.key)),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: done ? Colors.green.withValues(alpha: 0.35) : grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? Colors.green : primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded, color: white)
                        : Text(
                            initial,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: primary.shade700,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          '${stop.orders.length} захиалга · ${toPrice(_total)}',
                          style: TextStyle(fontSize: 12.5, color: grey500),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: grey400),
                ],
              ),
              const SizedBox(height: 12),
              HandledProgress(handled: stop.handledCount, total: stop.orders.length),
              if (customerId != null || coordinates != null) ...[
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  children: [
                    if (customerId != null)
                      Expanded(
                        child: CardAction(
                          icon: Icons.payments_outlined,
                          label: 'Төлбөр',
                          onPressed: () => showCustomerPaymentSheet(customerId, name),
                        ),
                      ),
                    if (coordinates != null)
                      Expanded(
                        child: CardAction(
                          icon: Icons.directions_outlined,
                          label: 'Чиглэл',
                          color: Colors.blue,
                          onPressed: () => openDirections(coordinates),
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

  double get _total => stop.orders.fold(0, (sum, o) => sum + o.totalPrice);
}
