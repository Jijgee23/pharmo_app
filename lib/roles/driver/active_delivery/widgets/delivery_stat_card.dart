import 'package:pharmo_app/application/app_lite.dart';

/// One count in the delivery's row of stats, e.g. how many were delivered.
class DeliveryStatCard extends StatelessWidget {
  const DeliveryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final strong = color is MaterialColor ? (color as MaterialColor).shade700 : color;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: value == 0 ? white : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value == 0 ? grey200 : color.withValues(alpha: 0.25)),
        ),
        child: Column(
          spacing: 2,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: value == 0 ? grey400 : strong,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: grey600),
            ),
          ],
        ),
      ),
    );
  }
}
