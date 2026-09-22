import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/repman/visit_card.dart';

/// Top-of-screen summary for the Rep's current open visiting session —
/// mirrors DeliverySummaryCard's two-tone shape (stat header band + a
/// grey.shade50 footer band for actions) already used on Driver's
/// delivery-history screens, so Repman reads as part of the same design
/// system instead of a bespoke one-off.
class RepSessionCard extends StatelessWidget {
  final Visiting visiting;
  final bool isTracking;
  final VoidCallback onStart;
  final VoidCallback onShareLocation;
  final VoidCallback onEnd;

  const RepSessionCard({
    super.key,
    required this.visiting,
    required this.isTracking,
    required this.onStart,
    required this.onShareLocation,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final started = visiting.outOn != null;
    final visitCount = visiting.visits?.length ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${visiting.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 14),
                      ),
                    ),
                    if (isTracking) const _TrackingIndicator(),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statInfo('Эхэлсэн', started ? formatTime(visiting.outOn!) : '—'),
                    _divider(),
                    _statInfo('Идэвхтэй уулзалт', '$visitCount', isLast: true),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: started
                ? Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: _FooterButton(
                          label: isTracking ? 'Дамжуулж байна' : 'Байршил дамжуулах',
                          icon: isTracking ? Icons.sensors : Icons.location_on_outlined,
                          color: isTracking ? Colors.teal : primary,
                          onTap: onShareLocation,
                        ),
                      ),
                      Expanded(
                        child: _FooterButton(
                          label: 'Уулзалт дуусгах',
                          icon: Icons.flag_outlined,
                          color: Colors.red.shade400,
                          onTap: onEnd,
                        ),
                      ),
                    ],
                  )
                : _FooterButton(
                    label: 'Уулзалтанд гарах',
                    icon: Icons.play_arrow_rounded,
                    color: primary,
                    onTap: onStart,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statInfo(String label, String value, {bool isLast = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isLast ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey.shade300,
    );
  }
}

class _TrackingIndicator extends StatelessWidget {
  const _TrackingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
        ),
        Text(
          'Байршил дамжуулж байна',
          style: TextStyle(fontSize: 11, color: Colors.teal.shade700, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FooterButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: white),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
