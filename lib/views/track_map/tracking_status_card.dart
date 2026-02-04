import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';

class TrackingStatusCard extends StatelessWidget {
  const TrackingStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final isTracking =
            jagger.subscription != null && !jagger.subscription!.isPaused;

        if (!isTracking) return const SizedBox.shrink();

        final trackDatas = jagger.trackDatas;
        final distance = _calculateTotalDistance(trackDatas, jagger);
        final duration = _formatDuration(jagger.now, jagger.delivery?.startedOn);

        return Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildPulsingIndicator(),
                    const SizedBox(width: 8),
                    const Text(
                      'Байршил дамжуулж байна',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      value: duration,
                      label: 'Хугацаа',
                      color: Colors.blue,
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.straighten,
                      value: _formatDistance(distance),
                      label: 'Зай',
                      color: Colors.orange,
                    ),
                    _buildDivider(),
                    _buildStatItem(
                      icon: Icons.speed,
                      value: '${_calculateSpeed(distance, jagger).toStringAsFixed(1)} км/ц',
                      label: 'Дундаж хурд',
                      color: Colors.green,
                    ),
                  ],
                ),
                if (trackDatas.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(trackDatas, jagger),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulsingIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal.withOpacity(value),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.4 * value),
                blurRadius: 8 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildProgressBar(List trackDatas, JaggerProvider jagger) {
    final sentCount = trackDatas.where((e) => e.sended).length;
    final totalCount = trackDatas.length;
    final progress = totalCount > 0 ? sentCount / totalCount : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Илгээсэн: $sentCount / $totalCount цэг',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  double _calculateTotalDistance(List trackDatas, JaggerProvider jagger) {
    if (trackDatas.length < 2) return 0;

    double total = 0;
    for (int i = 1; i < trackDatas.length; i++) {
      final prev = trackDatas[i - 1];
      final curr = trackDatas[i];
      total += _distanceBetween(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
    }
    return total;
  }

  double _distanceBetween(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.14159265359 / 180;
  double _sin(double x) => _taylor(x, true);
  double _cos(double x) => _taylor(x, false);
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0;
  }

  double _atan(double x) {
    double result = 0;
    double term = x;
    for (int n = 0; n < 20; n++) {
      result += term / (2 * n + 1) * (n % 2 == 0 ? 1 : -1);
      term *= x * x;
    }
    return result;
  }

  double _taylor(double x, bool isSin) {
    x = x % (2 * 3.14159265359);
    double result = isSin ? x : 1;
    double term = isSin ? x : 1;
    for (int n = 1; n < 20; n++) {
      term *= -x * x / ((isSin ? 2 * n : 2 * n - 1) * (isSin ? 2 * n + 1 : 2 * n));
      result += term;
    }
    return result;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} м';
    }
    return '${(meters / 1000).toStringAsFixed(2)} км';
  }

  String _formatDuration(DateTime now, String? startedOn) {
    if (startedOn == null) return '00:00';

    try {
      final startTime = DateTime.parse(startedOn);
      final duration = now.difference(startTime);

      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      final seconds = duration.inSeconds % 60;

      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  double _calculateSpeed(double distanceMeters, JaggerProvider jagger) {
    if (jagger.delivery?.startedOn == null) return 0;

    try {
      final startTime = DateTime.parse(jagger.delivery!.startedOn!);
      final duration = jagger.now.difference(startTime);

      if (duration.inSeconds == 0) return 0;

      // Convert m/s to km/h
      final speedMs = distanceMeters / duration.inSeconds;
      return speedMs * 3.6;
    } catch (e) {
      return 0;
    }
  }
}
