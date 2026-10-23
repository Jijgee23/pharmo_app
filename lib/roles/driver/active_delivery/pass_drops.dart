import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';
import 'package:pharmo_app/roles/driver/widgets/delman_picker.dart';
import 'package:pharmo_app/roles/driver/widgets/selection_bar.dart';

// Handing orders on the caller's active delivery to another deliveryman
// (PATCH delivery/pass_drops/): pick the orders, then whom to give them.

/// Orders on the active delivery that can still be passed on: not yet
/// delivered, returned or closed.
bool _passable(DeliveryOrder order) => !order.isHandled;

/// Picks orders of the active delivery to pass on, grouped by stop; with
/// [stopKey], that stop's orders start out selected.
class PassDropsPage extends StatefulWidget {
  final String? stopKey;
  const PassDropsPage({super.key, this.stopKey});

  @override
  State<PassDropsPage> createState() => _PassDropsPageState();
}

class _PassDropsPageState extends State<PassDropsPage> {
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    final stop = widget.stopKey == null
        ? null
        : context.read<JaggerProvider>().delivery?.stop(widget.stopKey!);
    if (stop != null) _selected.addAll(stop.orders.where(_passable).map((o) => o.id));
  }

  void _toggle(Iterable<int> ids) {
    HapticFeedback.selectionClick();
    setState(() {
      if (ids.every(_selected.contains)) {
        _selected.removeAll(ids);
      } else {
        _selected.addAll(ids);
      }
    });
  }

  Future<void> _pass(List<DeliveryOrder> orders) async {
    final passed = await showPassDropsSheet(orders);
    if (passed && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, _) {
        final groups = [
          for (final stop in jagger.delivery?.stops ?? const <DeliveryStop>[])
            if (stop.orders.where(_passable).toList() case final orders when orders.isNotEmpty)
              (stop, orders),
        ];
        final available = {for (final (_, orders) in groups) ...orders.map((o) => o.id)};
        // Orders delivered or passed meanwhile drop out of the selection.
        final chosen = [
          for (final (_, orders) in groups) ...orders.where((o) => _selected.contains(o.id)),
        ];
        final bottom = MediaQuery.of(context).padding.bottom;
        return Scaffold(
          backgroundColor: grey50,
          appBar: ModernAppBar(
            title: 'Захиалга шилжүүлэх',
            subtitle: 'Өөр түгээгчид өгөх захиалгаа сонгоно уу',
            showCart: false,
            actions: [
              if (available.isNotEmpty) ...[
                const SizedBox(width: 8),
                AppBarButton(
                  icon: chosen.length == available.length
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                  tooltip: chosen.length == available.length ? 'Сонголт цуцлах' : 'Бүгдийг сонгох',
                  onTap: () => _toggle(available),
                ),
              ],
            ],
          ),
          body: groups.isEmpty
              ? EmptyState(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Шилжүүлэх захиалга алга',
                  message: 'Хүргэгдээгүй захиалга л өөр түгээгчид шилжинэ.',
                  actionLabel: 'Буцах',
                  onAction: () => Navigator.maybePop(context),
                )
              : Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 110 + bottom),
                      children: [
                        for (final (stop, orders) in groups)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StopGroup(
                              stop: stop,
                              orders: orders,
                              selected: _selected,
                              onToggleStop: () => _toggle(orders.map((o) => o.id)),
                              onToggleOrder: (o) => _toggle([o.id]),
                            ),
                          ),
                      ],
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 16 + bottom,
                      child: SelectionBar(
                        count: chosen.length,
                        total: chosen.fold(0.0, (sum, o) => sum + o.totalPrice),
                        onClear: () => setState(_selected.clear),
                        actionLabel: 'Шилжүүлэх',
                        actionIcon: Icons.swap_horiz_rounded,
                        onAction: () => _pass(chosen),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// A stop's passable orders under a header that selects them all.
class _StopGroup extends StatelessWidget {
  final DeliveryStop stop;
  final List<DeliveryOrder> orders;
  final Set<int> selected;
  final VoidCallback onToggleStop;
  final ValueChanged<DeliveryOrder> onToggleOrder;

  const _StopGroup({
    required this.stop,
    required this.orders,
    required this.selected,
    required this.onToggleStop,
    required this.onToggleOrder,
  });

  @override
  Widget build(BuildContext context) {
    final picked = orders.where((o) => selected.contains(o.id)).length;
    final all = picked == orders.length;
    return Material(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: picked > 0 ? primary.withValues(alpha: 0.5) : grey200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggleStop,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  _Check(value: all ? true : (picked == 0 ? false : null)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          stop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          picked == 0
                              ? '${orders.length} захиалга'
                              : '$picked / ${orders.length} сонгосон',
                          style: TextStyle(fontSize: 12.5, color: grey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final order in orders) ...[
            Divider(height: 1, indent: 14, endIndent: 14, color: grey100),
            InkWell(
              onTap: () => onToggleOrder(order),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    _Check(value: selected.contains(order.id), small: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '#${order.orderNo}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          ProcessChip(order.orderProcess),
                        ],
                      ),
                    ),
                    Text(
                      toPrice(order.totalPrice),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A round check: ticked, empty, or (null) partly ticked.
class _Check extends StatelessWidget {
  final bool? value;
  final bool small;
  const _Check({required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    final size = small ? 20.0 : 24.0;
    final on = value != false;
    return AnimatedContainer(
      duration: Durations.short4,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? primary : Colors.transparent,
        border: Border.all(color: on ? primary : grey400, width: 2),
      ),
      child: on
          ? Icon(value == null ? Icons.remove_rounded : Icons.check_rounded,
              size: size - 8, color: white)
          : null,
    );
  }
}

/// Picks the deliveryman to take [orders]; true once they are passed.
Future<bool> showPassDropsSheet(List<DeliveryOrder> orders) async {
  final passed = await Get.bottomSheet<bool>(
    PassDropsSheet(orders: orders),
    isScrollControlled: true,
  );
  return passed ?? false;
}

class PassDropsSheet extends StatefulWidget {
  final List<DeliveryOrder> orders;
  const PassDropsSheet({super.key, required this.orders});

  @override
  State<PassDropsSheet> createState() => _PassDropsSheetState();
}

class _PassDropsSheetState extends State<PassDropsSheet> {
  int? _delmanId;
  bool _saving = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final driver = context.read<DriverProvider>();
    if (driver.delmans.isEmpty) {
      _loading = true;
      driver.getDelmans().whenComplete(() {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  Future<void> _submit(Delman target) async {
    setState(() => _saving = true);
    final ids = widget.orders.map((o) => o.id).toList();
    final passed = await context.read<DriverProvider>().passDrops(ids, target.id);
    if (!mounted) return;
    if (passed) {
      await context.read<JaggerProvider>().getDeliveries();
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders;
    final total = orders.fold(0.0, (sum, o) => sum + o.totalPrice);
    // Who they belong to, with how many each: "Азаар эмийн сан · 2".
    final byStop = <String, int>{};
    for (final o in orders) {
      byStop.update(o.recipientName, (n) => n + 1, ifAbsent: () => 1);
    }
    return Consumer<DriverProvider>(
      builder: (context, driver, _) {
        final others = driver.otherDelmans;
        final target = others.where((d) => d.id == _delmanId).firstOrNull;
        return AppSheet(
          title: 'Өөр түгээгчид шилжүүлэх',
          subtitle: '${orders.length} захиалга · ${toPrice(total)}',
          closable: !_saving,
          footer: SheetButton(
            label: target == null ? 'Түгээгч сонгоно уу' : '${target.name}-д шилжүүлэх',
            icon: Icons.swap_horiz_rounded,
            busy: _saving,
            onPressed: target == null ? null : () => _submit(target),
          ),
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final MapEntry(key: name, value: n) in byStop.entries)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: grey100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      n == 1 ? name : '$name · $n',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SheetLabel('Түгээгч сонгох',
                trailing: others.isEmpty ? null : '${others.length} түгээгч'),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              DelmanPicker(
                delmen: others,
                selectedId: _delmanId,
                onSelected: (d) => setState(() => _delmanId = d.id),
              ),
            const SizedBox(height: 4),
            const SheetNote(
              Icons.info_outline_rounded,
              'Захиалгууд сонгосон түгээгчийн идэвхтэй түгээлт рүү шилжинэ. Түүнд идэвхтэй '
              'түгээлт байх ёстой.',
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
