import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/customer_payment_sheet.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/delivery_order_card.dart';
import 'package:pharmo_app/roles/driver/active_delivery/pass_drops.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_skeletons.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';

/// The orders of one stop ([stopKey], the recipient's id) on the active
/// delivery. Refreshes the delivery on opening and follows it, and says so
/// when the delivery has ended or the stop is gone from it.
class OrdererOrders extends StatefulWidget {
  final String stopKey;
  const OrdererOrders({super.key, required this.stopKey});

  @override
  State<OrdererOrders> createState() => _OrdererOrdersState();
}

class _OrdererOrdersState extends State<OrdererOrders> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<JaggerProvider>().refreshDeliveries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final stop = jagger.delivery?.stop(widget.stopKey);
        final coordinates = stop?.coordinates;
        final customerId = stop?.customerId;
        final loading = !jagger.deliveriesLoaded || jagger.deliveriesRefreshing;
        return Scaffold(
          backgroundColor: grey50,
          appBar: ModernAppBar(
            title: stop?.name ?? 'Захиалагч',
            subtitle: stop == null ? null : '${stop.orders.length} захиалга',
            showCart: false,
            actions: [
              if (stop?.orders.any((o) => !o.isHandled) ?? false) ...[
                const SizedBox(width: 8),
                AppBarButton(
                  icon: Icons.swap_horiz_rounded,
                  tooltip: 'Өөр түгээгчид шилжүүлэх',
                  onTap: () => goto(PassDropsPage(stopKey: widget.stopKey)),
                ),
              ],
              if (stop != null && customerId != null) ...[
                const SizedBox(width: 8),
                AppBarButton(
                  icon: Icons.payments_outlined,
                  tooltip: 'Төлбөр бүртгэх',
                  onTap: () => showCustomerPaymentSheet(customerId, stop.name),
                ),
              ],
              if (coordinates != null) ...[
                const SizedBox(width: 8),
                AppBarButton(
                  icon: Icons.directions_outlined,
                  tooltip: 'Чиглэл',
                  onTap: () => openDirections(coordinates),
                ),
              ],
            ],
          ),
          body: Column(
            children: [
              RefreshLine(active: stop != null && jagger.deliveriesRefreshing),
              Expanded(child: _body(context, jagger, stop, loading)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, JaggerProvider jagger, DeliveryStop? stop, bool loading) {
    if (stop == null) {
      // Not "gone" until the delivery has come back without it.
      if (loading) return const StopOrdersSkeleton();
      return EmptyState(
        icon: Icons.local_shipping_outlined,
        title: jagger.delivery == null ? 'Түгээлт дууссан' : 'Захиалга алга',
        message: jagger.delivery == null
            ? 'Идэвхтэй түгээлт байхгүй байна.'
            : 'Энэ захиалагчийн захиалга түгээлтэд үлдээгүй байна.',
        actionLabel: 'Буцах',
        onAction: () => Navigator.maybePop(context),
      );
    }
    return RefreshIndicator(
      onRefresh: jagger.getDeliveries,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: grey200),
            ),
            child: HandledProgress(handled: stop.handledCount, total: stop.orders.length),
          ),
          const SizedBox(height: 12),
          for (final order in stop.orders)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DeliveryOrderCard(orderId: order.id),
            ),
        ],
      ),
    );
  }
}
