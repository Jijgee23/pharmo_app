import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_skeletons.dart';
import 'package:pharmo_app/roles/driver/ready_orders/delivery_assign_sheet.dart';
import 'package:pharmo_app/roles/driver/ready_orders/ready_order_card.dart';
import 'package:pharmo_app/roles/driver/widgets/selection_bar.dart';

class ReadyOrders extends StatefulWidget {
  final bool showHeader;

  /// Shown as a tab under the floating bottom bar, which the add button has
  /// to clear; false on a page of its own.
  final bool aboveBottomBar;
  const ReadyOrders({super.key, this.showHeader = true, this.aboveBottomBar = true});

  @override
  State<ReadyOrders> createState() => _ReadyOrdersState();
}

class _ReadyOrdersState extends State<ReadyOrders> {
  List<int> selecteds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // Shown as loading: the skeleton until there are orders to show, then a
  // line over them. Pull-to-refresh ([fetch]) has its own spinner.
  Future<void> _load() async {
    final driver = context.read<DriverProvider>();
    await driver.refreshOrders();
    _pruneSelection();
    if (driver.delmans.isEmpty) await driver.getDelmans();
  }

  Future fetch() async {
    final driver = context.read<DriverProvider>();
    await driver.getOrders();
    if (driver.delmans.isEmpty) await driver.getDelmans();
    _pruneSelection();
  }

  // Orders taken meanwhile (by another deliveryman) leave the list; they
  // can't stay selected.
  void _pruneSelection() {
    if (!mounted) return;
    final ids = context.read<DriverProvider>().orders.map((o) => o.id).toSet();
    setState(() => selecteds.removeWhere((id) => !ids.contains(id)));
  }

  void _toggleAll(List<DeliveryOrder> orders) {
    setState(() {
      if (selecteds.length == orders.length) {
        selecteds.clear();
      } else {
        selecteds
          ..clear()
          ..addAll(orders.map((o) => o.id));
      }
    });
  }

  void onTapOrder(DeliveryOrder order) {
    setState(() {
      selecteds.contains(order.id) ? selecteds.remove(order.id) : selecteds.add(order.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonBottom = widget.aboveBottomBar ? 100.0 : 20.0;
    return Consumer<DriverProvider>(
      builder: (context, jagger, child) {
        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  if (widget.showHeader) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Бэлэн захиалгууд',
                            style: context.theme.appBarTheme.titleTextStyle,
                          ),
                        ),
                        if (jagger.ordersRefreshing)
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _load,
                            tooltip: 'Шинэчлэх',
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                      ],
                    ).paddingAll(10),
                    const Divider(height: 1),
                  ],
                  RefreshLine(active: jagger.ordersRefreshing && jagger.orders.isNotEmpty),
                  if (jagger.orders.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 4, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selecteds.isEmpty
                                  ? '${jagger.orders.length} захиалга'
                                  : '${selecteds.length} / ${jagger.orders.length} сонгосон',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: grey600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _toggleAll(jagger.orders),
                            child: Text(
                              selecteds.length == jagger.orders.length
                                  ? 'Сонголт цуцлах'
                                  : 'Бүгдийг сонгох',
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetch,
                      child: Builder(
                        builder: (context) {
                          if (jagger.orders.isEmpty) {
                            final padding = widget.aboveBottomBar
                                ? const EdgeInsets.only(bottom: 100)
                                : EdgeInsets.zero;
                            // Not "none" until the list has come back empty.
                            if (!jagger.ordersLoaded || jagger.ordersRefreshing) {
                              return const ReadyOrdersSkeleton();
                            }
                            if (jagger.ordersFailed) {
                              return EmptyState(
                                icon: Icons.cloud_off_rounded,
                                title: 'Захиалга ачаалж чадсангүй',
                                message: 'Сүлжээгээ шалгаад дахин оролдоно уу.',
                                actionLabel: 'Дахин оролдох',
                                actionIcon: Icons.refresh_rounded,
                                onAction: _load,
                                color: Colors.red,
                                padding: padding,
                              );
                            }
                            return EmptyState(
                              icon: Icons.inventory_rounded,
                              title: 'Бэлэн захиалга алга',
                              message: 'Савлагдаж бэлэн болсон захиалга энд харагдана.',
                              padding: padding,
                            );
                          }
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Room for the last card to scroll out from under the button.
                            padding: EdgeInsets.fromLTRB(10, 4, 10, buttonBottom + 80),
                            itemCount: jagger.orders.length,
                            itemBuilder: (context, index) {
                              final order = jagger.orders[index];
                              return ReadyOrderCard(
                                onTap: () => onTapOrder(order),
                                selected: selecteds.contains(order.id),
                                ord: order,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: buttonBottom,
              child: SafeArea(
                top: false,
                child: SelectionBar(
                  count: selecteds.length,
                  total: jagger.orders
                      .where((o) => selecteds.contains(o.id))
                      .fold(0.0, (sum, o) => sum + o.totalPrice),
                  onClear: () => setState(selecteds.clear),
                  actionLabel: 'Түгээлтэд нэмэх',
                  actionIcon: Icons.local_shipping_rounded,
                  onAction: _assign,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assign() async {
    final done = await showDeliveryAssignSheet(List.of(selecteds));
    if (!mounted) return;
    if (done) {
      setState(() => selecteds.clear());
    } else {
      // Orders taken meanwhile can't stay selected.
      _pruneSelection();
    }
  }
}

/// The ready orders as a page of their own, for VS (whose bottom bar has no
/// tab for them).
class ReadyOrdersPage extends StatelessWidget {
  const ReadyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SideAppBar(text: 'Бэлэн захиалгууд'),
      body: ReadyOrders(showHeader: false, aboveBottomBar: false),
    );
  }
}
