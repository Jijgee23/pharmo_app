import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/additional_delivery.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/orderer_card.dart';
import 'package:pharmo_app/roles/driver/active_delivery/pass_drops.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_action_button.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_skeletons.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_stat_card.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';

/// The driver's active delivery (GET delivery/delman_active/): where it
/// stands and what to do next, its stops, and the extra stops logged on
/// the way.
class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  // Shown as loading: a line under the tabs, or the skeleton when there
  // is nothing to show yet. Pull-to-refresh has its own spinner.
  Future<void> _refresh() => context.read<JaggerProvider>().refreshDeliveries();

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final delivery = jagger.delivery;
        return Scaffold(
          backgroundColor: grey50,
          appBar: ModernAppBar(
            title: delivery == null ? 'Түгээлт' : 'Түгээлт #${delivery.id}',
            subtitle: delivery == null ? null : _status(delivery, jagger),
            showCart: false,
            actions: [
              if (delivery?.orders.any((o) => !o.isHandled) ?? false) ...[
                const SizedBox(width: 8),
                AppBarButton(
                  icon: Icons.swap_horiz_rounded,
                  tooltip: 'Өөр түгээгчид шилжүүлэх',
                  onTap: () => goto(const PassDropsPage()),
                ),
              ],
              const SizedBox(width: 8),
              _RefreshButton(busy: jagger.deliveriesRefreshing, onTap: _refresh),
            ],
          ),
          body: _body(delivery, jagger),
        );
      },
    );
  }

  String _status(Delivery delivery, JaggerProvider jagger) {
    final startedAt = delivery.startedAt;
    if (startedAt == null) return 'Эхлээгүй';
    if (!jagger.isTracking) return 'Байршил дамжуулалт зогссон';
    return '${hourMinute(startedAt)}-с явж байна';
  }

  Widget _body(Delivery? delivery, JaggerProvider jagger) {
    if (delivery != null) {
      final items = delivery.items ?? [];
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            RefreshLine(active: jagger.deliveriesRefreshing),
            PillTabBar(
              tabs: [
                'Захиалагчид',
                items.isEmpty ? 'Нэмэлт хүргэлт' : 'Нэмэлт хүргэлт (${items.length})',
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StopsTab(delivery: delivery, jagger: jagger),
                  AdditionalDeliveries(items: items),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (!jagger.deliveriesLoaded || jagger.deliveriesRefreshing) return const DeliverySkeleton();
    if (jagger.deliveriesFailed) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Түгээлтийг ачаалж чадсангүй',
        message: 'Сүлжээгээ шалгаад дахин оролдоно уу.',
        actionLabel: 'Дахин оролдох',
        actionIcon: Icons.refresh_rounded,
        onAction: _refresh,
        color: Colors.red,
      );
    }
    return EmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'Идэвхтэй түгээлт алга',
      message: 'Бэлэн захиалгуудаас түгээлтэд нэмэхэд энд харагдана.',
      actionLabel: 'Шинэчлэх',
      actionIcon: Icons.refresh_rounded,
      onAction: _refresh,
    );
  }
}

class _StopsTab extends StatelessWidget {
  final Delivery delivery;
  final JaggerProvider jagger;
  const _StopsTab({required this.delivery, required this.jagger});

  @override
  Widget build(BuildContext context) {
    // Stops still to visit first; the order among each kept.
    final stops = [
      ...delivery.stops.where((s) => !s.isDone),
      ...delivery.stops.where((s) => s.isDone)
    ];
    final total = delivery.orders.length;
    final onRoute = delivery.countOf(OrderProcess.onDelivery);
    final delivered = delivery.countOf(OrderProcess.delivered);
    // Closed ones count with the returned: neither got delivered.
    final returned =
        delivery.countOf(OrderProcess.returned) + delivery.countOf(OrderProcess.closed);
    return RefreshIndicator(
      onRefresh: jagger.getDeliveries,
      child: ListView(
        key: const PageStorageKey('stops'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.of(context).padding.bottom),
        children: [
          _SummaryCard(delivery: delivery, jagger: jagger),
          const SizedBox(height: 12),
          Row(
            spacing: 8,
            children: [
              DeliveryStatCard(
                  label: 'Бэлэн',
                  value: total - onRoute - delivered - returned,
                  color: Colors.teal),
              DeliveryStatCard(label: 'Замд', value: onRoute, color: Colors.purple),
              DeliveryStatCard(label: 'Хүргэсэн', value: delivered, color: Colors.green),
              DeliveryStatCard(label: 'Буцаасан', value: returned, color: Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Захиалагчид',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.grey.shade900),
              ),
              const SizedBox(width: 8),
              Text('${stops.length}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: grey500)),
            ],
          ),
          const SizedBox(height: 10),
          if (stops.isEmpty)
            const SheetNote(Icons.inbox_outlined, 'Энэ түгээлтэд захиалга алга.')
          else
            for (final stop in stops)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OrdererCard(stop: stop),
              ),
        ],
      ),
    );
  }
}

/// How far the delivery is, since when, and its next step.
class _SummaryCard extends StatelessWidget {
  final Delivery delivery;
  final JaggerProvider jagger;
  const _SummaryCard({required this.delivery, required this.jagger});

  @override
  Widget build(BuildContext context) {
    final ratio = delivery.doneRatio;
    final done = delivery.orders.isNotEmpty && ratio == 1;
    final startedAt = delivery.startedAt;
    final paused = delivery.isStarted && !jagger.isTracking;
    final total = delivery.orders.fold<double>(0, (sum, o) => sum + o.totalPrice);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: grey100,
                      color: done ? Colors.green : primary,
                    ),
                    Center(
                      child: Text(
                        '${(ratio * 100).round()}%',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: done ? Colors.green.shade700 : primary.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      '${delivery.handledCount} / ${delivery.orders.length} хүргэсэн',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text(
                      '${delivery.stops.length} цэг · ${toPrice(total)}',
                      style: TextStyle(fontSize: 13, color: grey600),
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        if (jagger.isTracking) const LiveDot(size: 7),
                        Flexible(
                          child: Text(
                            startedAt == null
                                ? 'Эхлээгүй'
                                : '${friendlyDateTime(startedAt)}-с эхэлсэн',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: grey500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (paused) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.location_off_outlined, size: 20, color: Colors.orange.shade800),
                  Expanded(
                    child: Text(
                      'Байршил дамжуулалт зогссон байна. Үргэлжлүүлнэ үү.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          DeliveryTrackButton(delivery: delivery, expanded: true),
          // While paused the main button resumes; ending stays possible.
          if (paused)
            TextButton(
              onPressed: jagger.busy ? null : jagger.endTrack,
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
              child: const Text('Түгээлт дуусгах'),
            ),
        ],
      ),
    );
  }
}

/// The refresh button, spinning while a refresh is under way.
class _RefreshButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _RefreshButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!busy) return AppBarButton(icon: Icons.refresh_rounded, tooltip: 'Шинэчлэх', onTap: onTap);
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
