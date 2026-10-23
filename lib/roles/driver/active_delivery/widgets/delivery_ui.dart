import 'package:pharmo_app/application/application.dart';
import 'package:url_launcher/url_launcher.dart';

// Small pieces shared by the active delivery screens.

/// Opens turn-by-turn directions to [to] in the maps app.
Future<void> openDirections((double, double) to) async {
  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${to.$1},${to.$2}');
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) messageWarning('Газрын зургийн апп нээж чадсангүй');
}

/// The icon of a delivery state.
IconData processIcon(OrderProcess process) => switch (process) {
      OrderProcess.packed => Icons.inventory_2_outlined,
      OrderProcess.onDelivery => Icons.local_shipping_outlined,
      OrderProcess.delivered => Icons.check_circle_outline_rounded,
      OrderProcess.returned => Icons.undo_rounded,
      OrderProcess.closed => Icons.lock_outline_rounded,
      _ => Icons.help_outline_rounded,
    };

/// A darker shade of [color] for text on its own tint.
Color strongShade(Color color) =>
    color is MaterialColor ? color.shade700 : Color.lerp(color, Colors.black, 0.25)!;

/// An order's delivery state as a coloured chip.
class ProcessChip extends StatelessWidget {
  final OrderProcess process;
  const ProcessChip(this.process, {super.key});

  @override
  Widget build(BuildContext context) {
    final strong = strongShade(process.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: process.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(processIcon(process), size: 13, color: strong),
          Text(
            process.name,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: strong),
          ),
        ],
      ),
    );
  }
}

/// A progress bar with "x / y хүргэсэн" and the percentage above it.
class HandledProgress extends StatelessWidget {
  final int handled;
  final int total;
  const HandledProgress({super.key, required this.handled, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : handled / total;
    final done = total > 0 && handled == total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          children: [
            Text(
              '$handled / $total хүргэсэн',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: grey600),
            ),
            const Spacer(),
            Text(
              '${(ratio * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: done ? Colors.green.shade700 : primary.shade700,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: grey100,
            color: done ? Colors.green : primary,
          ),
        ),
      ],
    );
  }
}

/// A small tonal button with an icon, for card actions.
class CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const CardAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? primary;
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: tint.withValues(alpha: 0.1),
        foregroundColor: strongShade(tint),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: context.theme.textTheme.labelLarge?.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Tabs as a segmented pill, for the delivery screens.
class PillTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  const PillTabBar({super.key, required this.tabs, this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: grey200.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        labelColor: Colors.grey.shade900,
        unselectedLabelColor: grey600,
        labelStyle: context.theme.textTheme.labelLarge
            ?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: context.theme.textTheme.labelLarge
            ?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [for (final t in tabs) Tab(text: t)],
      ),
    );
  }
}
