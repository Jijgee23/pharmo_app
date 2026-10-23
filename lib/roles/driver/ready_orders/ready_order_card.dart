import 'package:pharmo_app/application/app_lite.dart';

/// A ready order in the allocation list; tapping it selects it.
class ReadyOrderCard extends StatelessWidget {
  final bool selected;
  final void Function()? onTap;
  final DeliveryOrder ord;
  const ReadyOrderCard({
    super.key,
    required this.selected,
    this.onTap,
    required this.ord,
  });

  @override
  Widget build(BuildContext context) {
    final name = ord.recipientName;
    final pay = ord.paymentType;
    final zone = ord.zone.name.trim();
    // allocation/ sends the quantity; items only come with some suppliers.
    final count = ord.totalCount > 0 ? ord.totalCount : ord.items.length;
    final createdAt = parseDateTime(ord.createdOn);
    final created = createdAt == null ? null : friendlyDateTime(createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: Durations.short4,
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? primary.withValues(alpha: 0.06) : white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? primary : grey200,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: selected ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(name: name, selected: selected),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          Text(
                            [
                              '#${ord.orderNo}',
                              if (created != null) created,
                            ].join('  ·  '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      toPrice(ord.totalPrice),
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color:
                            selected ? primary.shade700 : Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (pay != PayType.unknown)
                      _Tag(
                        icon: Icons.payments_outlined,
                        label: pay.name,
                        color: pay.color,
                      ),
                    if (count > 0)
                      _Tag(
                        icon: Icons.inventory_2_outlined,
                        label: '${_number(count)} ширхэг',
                      ),
                    if (zone.isNotEmpty && zone != 'null')
                      _Tag(icon: Icons.place_outlined, label: zone),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _number(num n) =>
      n % 1 == 0 ? '${n.toInt()}' : n.toStringAsFixed(1);
}

/// The name's initial, turning into a check once selected.
class _Avatar extends StatelessWidget {
  final String name;
  final bool selected;
  const _Avatar({required this.name, required this.selected});

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return AnimatedContainer(
      duration: Durations.short4,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? primary : primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: Durations.short4,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: selected
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey(true),
                color: white,
                size: 24,
              )
            : Text(
                initial,
                key: const ValueKey(false),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: primary.shade700,
                ),
              ),
      ),
    );
  }
}

/// A small fact about the order: payment type, quantity, zone.
class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Tints the tag; plain grey without it.
  final Color? color;
  const _Tag({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color;
    final foreground =
        tint == null ? grey600 : Color.lerp(tint, Colors.black, 0.25)!;
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint == null ? grey100 : tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 13, color: foreground),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
