import 'package:pharmo_app/application/application.dart';

/// The next step for [delivery]: start it, resume sending location, or end
/// it. Spins while one is under way (each waits for a GPS fix first).
class DeliveryTrackButton extends StatelessWidget {
  final Delivery delivery;

  /// Full width with a taller target, for the delivery page; compact for
  /// the map's panel.
  final bool expanded;

  const DeliveryTrackButton({super.key, required this.delivery, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, _) {
        final (label, icon, color, action) = switch ((delivery.isStarted, jagger.isTracking)) {
          (false, _) => (
              'Эхлүүлэх',
              Icons.play_arrow_rounded,
              primary as Color,
              () => jagger.startDelivery(delivery.id),
            ),
          (true, false) => (
              'Үргэлжлүүлэх',
              Icons.play_arrow_rounded,
              Colors.orange.shade700,
              jagger.resumeTracking,
            ),
          (true, true) => (
              'Дуусгах',
              Icons.stop_rounded,
              Colors.red.shade600,
              jagger.endTrack,
            ),
        };
        return FilledButton.icon(
          onPressed: jagger.busy ? null : action,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.6),
            disabledForegroundColor: white,
            minimumSize: expanded ? const Size.fromHeight(50) : const Size(0, 42),
            padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: context.theme.textTheme.labelLarge?.copyWith(
              fontSize: expanded ? 15 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: jagger.busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: white),
                )
              : Icon(icon, size: 20),
          label: Text(label),
        );
      },
    );
  }
}
