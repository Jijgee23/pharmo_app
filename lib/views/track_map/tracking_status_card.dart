import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/application/application.dart';

/// While location is being sent: a pill with the elapsed time and the
/// distance covered; tapping it opens the details (points sent, what the
/// line colours mean).
class TrackingPill extends StatefulWidget {
  const TrackingPill({super.key});

  @override
  State<TrackingPill> createState() => _TrackingPillState();
}

class _TrackingPillState extends State<TrackingPill> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final isSeller = Authenticator.security?.isSaler ?? false;
        final startedAt =
            isSeller ? parseDateTime(jagger.salerStartedOn) : jagger.delivery?.startedAt;
        final points = jagger.trackDatas;
        final sent = points.where((p) => p.sended).length;
        final distance = _distance(points);

        return Material(
          color: white,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(_expanded ? 18 : 24),
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(_expanded ? 18 : 24),
            child: AnimatedSize(
              duration: Durations.medium1,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LiveDot(),
                        const SizedBox(width: 8),
                        if (startedAt != null) ...[
                          _Elapsed(since: startedAt),
                          _dot(),
                        ],
                        Text(_formatDistance(distance), style: _strong),
                        const SizedBox(width: 4),
                        Icon(
                          _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 18,
                          color: grey500,
                        ),
                      ],
                    ),
                    if (_expanded) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Байршил дамжуулж байна',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: primary.shade700),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 220,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Row(
                              children: [
                                Text('Илгээсэн цэг', style: _muted),
                                const Spacer(),
                                Text('$sent / ${points.length}', style: _strong),
                              ],
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: points.isEmpty ? 1 : sent / points.length,
                                minHeight: 5,
                                backgroundColor: grey200,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _legend(primary, 'Илгээсэн зам'),
                            _legend(Colors.redAccent, 'Илгээгдээгүй (сүлжээ орохоор илгээнэ)'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static final _strong =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade900);
  static final _muted = TextStyle(fontSize: 12, color: grey600);

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: TextStyle(color: grey400, fontWeight: FontWeight.w900)),
      );

  Widget _legend(Color color, String text) {
    return Row(
      spacing: 8,
      children: [
        Container(
            width: 14,
            height: 4,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        Expanded(child: Text(text, style: _muted)),
      ],
    );
  }

  static double _distance(List<TrackData> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += Geolocator.distanceBetween(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return total;
  }

  static String _formatDistance(double meters) =>
      meters < 1000 ? '${meters.toStringAsFixed(0)} м' : '${(meters / 1000).toStringAsFixed(1)} км';
}

/// Time since [since], ticking every second.
class _Elapsed extends StatefulWidget {
  final DateTime since;
  const _Elapsed({required this.since});

  @override
  State<_Elapsed> createState() => _ElapsedState();
}

class _ElapsedState extends State<_Elapsed> {
  late final Timer _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var d = DateTime.now().difference(widget.since);
    if (d.isNegative) d = Duration.zero;
    String two(int v) => v.toString().padLeft(2, '0');
    final text = d.inHours > 0
        ? '${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}'
        : '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade900,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
