import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';

class DeliveryInfoCard extends StatefulWidget {
  const DeliveryInfoCard({super.key});

  @override
  State<DeliveryInfoCard> createState() => _DeliveryInfoCardState();
}

class _DeliveryInfoCardState extends State<DeliveryInfoCard>
    with SingleTickerProviderStateMixin {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final delivery = jagger.delivery;
        final orders = delivery?.orders ?? [];

        if (delivery == null || orders.isEmpty) {
          return const SizedBox.shrink();
        }

        final pendingOrders =
            orders.where((o) => o.status != 'delivered').toList();
        if (pendingOrders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 115,
          left: 16,
          right: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isHidden = !_isHidden),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isHidden ? Icons.visibility : Icons.visibility_off,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isHidden ? 'Харуулах' : 'Нуух',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedCrossFade(
                firstChild: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Түгээлт #${delivery.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${pendingOrders.length} захиалга үлдсэн',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildProgressCircle(
                              orders.length, pendingOrders.length),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ...pendingOrders.take(2).map((order) {
                        final customer =
                            order.customer ?? order.orderer ?? order.user;
                        if (customer == null) return const SizedBox.shrink();

                        return _OrderDestinationTile(
                          name: customer.name,
                          address: '',
                          lat: customer.lat,
                          lng: customer.lng,
                          currentPosition: jagger.currentPosition,
                          onTap: () => _navigateToOrder(
                              jagger, customer.lat, customer.lng),
                        );
                      }),
                      if (pendingOrders.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${pendingOrders.length - 2} бусад захиалга',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isHidden
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressCircle(int total, int pending) {
    final completed = total - pending;
    final progress = total > 0 ? completed / total : 0.0;

    return SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 4,
          ),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrder(JaggerProvider jagger, dynamic lat, dynamic lng) {
    if (lat == null || lng == null) return;

    final latDouble = _parseDouble(lat);
    final lngDouble = _parseDouble(lng);

    jagger.gotoWithNative(LatLng(latDouble, lngDouble));
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class _OrderDestinationTile extends StatelessWidget {
  final String name;
  final String address;
  final dynamic lat;
  final dynamic lng;
  final Position? currentPosition;
  final VoidCallback onTap;

  const _OrderDestinationTile({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.currentPosition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final eta = _estimateTime(distance);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.isNotEmpty)
                    Text(
                      address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDistance(distance),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  eta,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance() {
    if (currentPosition == null || lat == null || lng == null) return 0;

    final latDouble = _parseDouble(lat);
    final lngDouble = _parseDouble(lng);

    return Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      latDouble,
      lngDouble,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} м';
    }
    return '${(meters / 1000).toStringAsFixed(1)} км';
  }

  String _estimateTime(double distanceMeters) {
    if (distanceMeters == 0) return '';

    // Assume average speed of 30 km/h in city
    final hours = distanceMeters / 1000 / 30;
    final minutes = (hours * 60).round();

    if (minutes < 1) return '< 1 мин';
    if (minutes < 60) return '~$minutes мин';

    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '~$hц $mм';
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
