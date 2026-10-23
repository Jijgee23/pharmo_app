import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/widgets/delman_picker.dart';

/// Sends the ready orders [orderIds] onto the caller's own delivery or to
/// another deliveryman. True once they have left the ready list.
Future<bool> showDeliveryAssignSheet(List<int> orderIds) async {
  final done = await Get.bottomSheet<bool>(
    DeliveryAssignSheet(orderIds: orderIds),
    isScrollControlled: true,
  );
  return done ?? false;
}

class DeliveryAssignSheet extends StatefulWidget {
  final List<int> orderIds;
  const DeliveryAssignSheet({super.key, required this.orderIds});

  @override
  State<DeliveryAssignSheet> createState() => _DeliveryAssignSheetState();
}

class _DeliveryAssignSheetState extends State<DeliveryAssignSheet> {
  late final Set<int> _ids = widget.orderIds.toSet();
  bool toOther = false;
  int? delmanId;
  bool saving = false;

  Future<void> _submit(DriverProvider driver, List<DeliveryOrder> orders, Delman? target) async {
    final ids = orders.map((o) => o.id).toList();
    setState(() => saving = true);
    final done = target == null
        ? await driver.addOrdersToDelivery(ids)
        : await driver.passOrdersToDelman(ids, target.id);
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, true);
    } else {
      // Kept open with the choice made; orders taken meanwhile drop out.
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, driver, _) {
        // Only what is still ready: a refresh after a failure may drop some.
        final orders = driver.orders.where((o) => _ids.contains(o.id)).toList();
        final others = driver.otherDelmans;
        final target = toOther ? others.where((d) => d.id == delmanId).firstOrNull : null;
        final ready = orders.isNotEmpty && (!toOther || target != null);

        return AppSheet(
          title: 'Түгээлтэд нэмэх',
          closable: !saving,
          footer: _submitButton(driver, orders, target, ready),
          children: [
            _OrdersSummary(orders: orders),
            const SizedBox(height: 22),
            const SheetLabel('Хэнд хүргүүлэх вэ?'),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _DestinationCard(
                    icon: Icons.person_rounded,
                    title: 'Өөртөө',
                    subtitle: 'Миний түгээлтэд нэмэх',
                    selected: !toOther,
                    onTap: () => setState(() => toOther = false),
                  ),
                ),
                Expanded(
                  child: _DestinationCard(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Бусдад',
                    subtitle: 'Өөр түгээгчид шилжүүлэх',
                    selected: toOther,
                    onTap: () => setState(() => toOther = true),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: Durations.medium2,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: toOther ? _delmanPicker(others) : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }

  Widget _delmanPicker(List<Delman> others) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetLabel('Түгээгч сонгох',
              trailing: others.isEmpty ? null : '${others.length} түгээгч'),
          DelmanPicker(
            delmen: others,
            selectedId: delmanId,
            onSelected: (d) => setState(() => delmanId = d.id),
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 4),
            // pass_drops/ moves orders off the caller's own delivery, so
            // they go there first; say so, as they stay there if the
            // deliveryman has no delivery to take them.
            const SheetNote(
              Icons.info_outline_rounded,
              'Захиалгууд эхлээд таны түгээлтэд нэмэгдээд, сонгосон түгээгчийн идэвхтэй '
              'түгээлт рүү шилжинэ. Түүнд идэвхтэй түгээлт байхгүй бол таны түгээлтэд үлдэнэ.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _submitButton(
    DriverProvider driver,
    List<DeliveryOrder> orders,
    Delman? target,
    bool ready,
  ) {
    final String label;
    if (orders.isEmpty) {
      label = 'Сонгосон захиалга үлдсэнгүй';
    } else if (!toOther) {
      label = 'Миний түгээлтэд нэмэх';
    } else if (target == null) {
      label = 'Түгээгч сонгоно уу';
    } else {
      label = '${target.name}-д шилжүүлэх';
    }
    return SheetButton(
      label: label,
      icon: toOther ? Icons.swap_horiz_rounded : Icons.local_shipping_rounded,
      busy: saving,
      onPressed: ready ? () => _submit(driver, orders, target) : null,
    );
  }
}

/// How many orders are going, their total, and whose they are.
class _OrdersSummary extends StatelessWidget {
  final List<DeliveryOrder> orders;
  const _OrdersSummary({required this.orders});

  // Customers named before the rest are counted.
  static const _named = 3;

  @override
  Widget build(BuildContext context) {
    final total = orders.fold<double>(0, (sum, o) => sum + o.totalPrice);
    final names = orders.map((o) => o.recipientName).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      '${orders.length} захиалга',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text('Сонгосон', style: TextStyle(fontSize: 12, color: grey600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text(
                    toPrice(total),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: primary.shade700,
                    ),
                  ),
                  Text('Нийт дүн', style: TextStyle(fontSize: 12, color: grey600)),
                ],
              ),
            ],
          ),
          if (names.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in names.take(_named)) _chip(name),
                if (names.length > _named) _chip('+${names.length - _named}', muted: true),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, {bool muted = false}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: grey200),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: muted ? grey500 : Colors.grey.shade800,
        ),
      ),
    );
  }
}

/// One of the two places the orders can go.
class _DestinationCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DestinationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!selected) HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: Durations.short4,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? primary : grey200, width: selected ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: Durations.short4,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? primary : grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: selected ? white : grey600),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: Durations.short4,
                  opacity: selected ? 1 : 0,
                  child: const Icon(Icons.check_circle_rounded, size: 20, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? primary.shade800 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              style: TextStyle(fontSize: 12, height: 1.3, color: grey600),
            ),
          ],
        ),
      ),
    );
  }
}
