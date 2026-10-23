import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/deliveries.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_action_button.dart';
import 'package:pharmo_app/roles/driver/ready_orders/ready_orders.dart';

/// The active delivery at the foot of the map (D/VS): its state, how far
/// along it is, and the next thing to do. Tapping it opens the delivery.
class DeliveryPanel extends StatelessWidget {
  const DeliveryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, _) {
        final delivery = jagger.delivery;
        if (delivery != null) return _ActiveDelivery(delivery: delivery, jagger: jagger);
        if (!jagger.deliveriesLoaded || jagger.deliveriesRefreshing) {
          return const _PanelCard(
            icon: Icons.local_shipping_outlined,
            tint: Colors.grey,
            title: 'Түгээлт',
            subtitle: 'Ачаалж байна…',
            trailing: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }
        if (jagger.deliveriesFailed) {
          return _PanelCard(
            icon: Icons.cloud_off_rounded,
            tint: Colors.red,
            title: 'Түгээлтийг ачаалж чадсангүй',
            subtitle: 'Сүлжээгээ шалгаад дахин оролдоно уу.',
            footer: _TonalButton(label: 'Дахин оролдох', onPressed: jagger.refreshDeliveries),
          );
        }
        return _PanelCard(
          icon: Icons.inventory_2_outlined,
          tint: Colors.grey,
          title: 'Идэвхтэй түгээлт алга',
          subtitle: 'Бэлэн захиалгуудаас түгээлтэд нэмнэ үү.',
          onTap: () => goto(const Deliveries()),
          footer: _TonalButton(
            label: 'Бэлэн захиалга харах',
            onPressed: () async => _openReadyOrders(context),
          ),
        );
      },
    );
  }

  // D has them as a tab; VS as a page of their own.
  static void _openReadyOrders(BuildContext context) {
    if (Authenticator.security?.isVanSales ?? false) {
      goto(const ReadyOrdersPage());
    } else {
      context.read<HomeProvider>().changeIndex(1);
    }
  }
}

class _ActiveDelivery extends StatelessWidget {
  final Delivery delivery;
  final JaggerProvider jagger;
  const _ActiveDelivery({required this.delivery, required this.jagger});

  @override
  Widget build(BuildContext context) {
    final total = delivery.orders.length;
    final handled = delivery.handledCount;
    final startedAt = delivery.startedAt;
    final paused = delivery.isStarted && !jagger.isTracking;

    final String subtitle;
    if (startedAt == null) {
      subtitle = '$total захиалга · ${delivery.stops.length} цэг';
    } else if (paused) {
      subtitle = 'Байршил дамжуулалт зогссон байна';
    } else {
      subtitle = '${hourMinute(startedAt)}-с · $handled / $total хүргэсэн';
    }

    return _PanelCard(
      icon: Icons.local_shipping_rounded,
      tint: paused ? Colors.orange : primary,
      title: 'Түгээлт #${delivery.id}',
      live: jagger.isTracking,
      subtitle: subtitle,
      subtitleColor: paused ? Colors.orange.shade800 : null,
      progress: delivery.isStarted ? delivery.doneRatio : null,
      onTap: () => goto(const Deliveries()),
      trailing: DeliveryTrackButton(delivery: delivery),
    );
  }
}

/// The panel's card: an icon, a title and a line under it, an action on
/// the right or (when it needs the width) a [footer] under them, and
/// optionally a progress bar along the bottom.
class _PanelCard extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final bool live;
  final double? progress;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;

  const _PanelCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.live = false,
    this.progress,
    this.trailing,
    this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shade = tint is MaterialColor ? (tint as MaterialColor).shade700 : tint;
    return Material(
      color: white,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: shade, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ),
                            if (live) ...[
                              const SizedBox(width: 8),
                              const LiveDot(),
                            ],
                          ],
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: subtitleColor == null ? FontWeight.w500 : FontWeight.w600,
                            color: subtitleColor ?? grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 10),
                    trailing!,
                  ],
                ],
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(width: double.infinity, child: footer),
              ),
            if (progress != null)
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: grey100,
                color: progress == 1 ? Colors.green : primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _TonalButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;
  const _TonalButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: primary.withValues(alpha: 0.1),
        foregroundColor: primary.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: context.theme.textTheme.labelLarge
            ?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
