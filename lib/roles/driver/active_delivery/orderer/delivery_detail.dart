import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/orderer/delivery_order_location.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_skeletons.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';
import 'package:pharmo_app/roles/driver/widgets/status_changer.dart';
import 'package:pharmo_app/views/printer/print_previev.dart';

/// One order of a delivery: its details, its items, and where it goes.
/// The active delivery's orders are refreshed on opening and can have
/// their state changed here; with [readOnly] (a past delivery's) neither.
class DeliveryDetail extends StatefulWidget {
  final int orderId;
  final bool readOnly;
  const DeliveryDetail({super.key, required this.orderId, this.readOnly = false});

  @override
  State<DeliveryDetail> createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    if (!widget.readOnly) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<JaggerProvider>().refreshDeliveries(),
      );
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // The active delivery first: its copy is the one being kept up to date.
  (DeliveryOrder, bool)? _find(JaggerProvider jagger) {
    final active = jagger.delivery?.orders.where((o) => o.id == widget.orderId).firstOrNull;
    if (active != null) return (active, true);
    for (final delivery in context.read<DriverProvider>().history) {
      final past = delivery.orders.where((o) => o.id == widget.orderId).firstOrNull;
      if (past != null) return (past, false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final found = _find(jagger);
        final loading = !jagger.deliveriesLoaded || jagger.deliveriesRefreshing;
        if (found == null) {
          return Scaffold(
            backgroundColor: grey50,
            appBar: const ModernAppBar(title: 'Захиалга', showCart: false),
            // Not "not found" until the delivery has come back without it.
            body: !widget.readOnly && loading
                ? const OrderDetailSkeleton()
                : EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Захиалга олдсонгүй',
                    message: 'Түгээлтээс хасагдсан байж магадгүй.',
                    actionLabel: 'Буцах',
                    onAction: () => Navigator.maybePop(context),
                  ),
          );
        }
        final (order, onActive) = found;
        final editable = onActive && !widget.readOnly;
        return Scaffold(
          backgroundColor: grey50,
          appBar: ModernAppBar(
            title: '#${order.orderNo}',
            subtitle: order.recipientName,
            showCart: false,
            actions: [
              const SizedBox(width: 8),
              AppBarButton(
                icon: Icons.print_outlined,
                tooltip: 'Баримт хэвлэх',
                onTap: () => goto(PrintPreviev(order: order)),
              ),
            ],
          ),
          body: Column(
            children: [
              RefreshLine(active: onActive && jagger.deliveriesRefreshing),
              PillTabBar(controller: _tabs, tabs: const ['Ерөнхий', 'Бараа', 'Байршил']),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _Overview(order: order, editable: editable),
                    _Items(order: order),
                    _Location(order: order),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Overview extends StatelessWidget {
  final DeliveryOrder order;
  final bool editable;
  const _Overview({required this.order, required this.editable});

  @override
  Widget build(BuildContext context) {
    final createdAt = parseDateTime(order.createdOn);
    final count = order.totalCount;
    final pay = order.paymentType;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.of(context).padding.bottom),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProcessChip(order.orderProcess),
                  const Spacer(),
                  Text(
                    toPrice(order.totalPrice),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ModernDetailRow('Захиалагч', order.recipientName),
              ModernDetailRow('Тоо ширхэг', '${count % 1 == 0 ? count.toInt() : count} ширхэг'),
              ModernDetailRow('Төлбөрийн хэлбэр', pay == PayType.unknown ? '—' : pay.name),
              ModernDetailRow('Төлбөрийн төлөв', order.orderStatus.name),
              ModernDetailRow(
                'Огноо',
                createdAt == null ? order.createdOn : friendlyDateTime(createdAt),
              ),
            ],
          ),
        ),
        if (editable) ...[
          const SizedBox(height: 14),
          if (!order.isHandled) ...[
            SheetButton(
              label: 'Хүргэсэн',
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green.shade600,
              onPressed: () => LoadingService.run(
                () => context.read<JaggerProvider>().setOrderProcess(order, OrderProcess.delivered),
              ),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: () => showOrderStatusSheet(order),
            icon: const Icon(Icons.tune_rounded, size: 20),
            label: const Text('Төлөв солих'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: context.theme.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Items extends StatelessWidget {
  final DeliveryOrder order;
  const _Items({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.items.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Барааны мэдээлэл алга',
        message: 'Энэ захиалгын бараа ирээгүй байна.',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + MediaQuery.of(context).padding.bottom),
      itemCount: order.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = order.items[i];
        final qty = item.qty % 1 == 0 ? item.qty.toInt() : item.qty;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: grey200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text(
                      '$qty ш × ${toPrice(item.price)}',
                      style: TextStyle(fontSize: 12.5, color: grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                toPrice(item.totalPrice),
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Location extends StatelessWidget {
  final DeliveryOrder order;
  const _Location({required this.order});

  @override
  Widget build(BuildContext context) {
    final coordinates = order.recipientCoordinates;
    if (coordinates == null) {
      return const EmptyState(
        icon: Icons.location_off_outlined,
        title: 'Байршил тодорхойгүй',
        message: 'Захиалагчийн байршил бүртгэгдээгүй байна.',
      );
    }
    return Stack(
      children: [
        DeliveryOrderLocation(coordinates: coordinates, title: order.recipientName),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          child: SheetButton(
            label: 'Чиглэл авах',
            icon: Icons.directions_rounded,
            onPressed: () => openDirections(coordinates),
          ),
        ),
      ],
    );
  }
}
