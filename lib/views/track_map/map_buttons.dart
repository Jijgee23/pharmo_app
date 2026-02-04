import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

class MapButtons extends StatelessWidget {
  const MapButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final isTracking =
            jagger.subscription != null && !jagger.subscription!.isPaused;

        return Positioned(
          bottom: 20,
          right: 15,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(
                  heroTag: 'zoomInDMANMAP',
                  icon: Icons.add,
                  onPressed: () {
                    jagger.mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  heroTag: 'zoomOutDMANMAP',
                  icon: Icons.remove,
                  onPressed: () {
                    jagger.mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _AnimatedLocationButton(
                  isTracking: isTracking,
                  onPressed: jagger.goToMyLocation,
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  heroTag: 'toggleTrafficDMANMAP',
                  icon: Icons.traffic,
                  onPressed: jagger.toggleTraffic,
                  backgroundColor:
                      jagger.trafficEnabled ? Colors.blue : Colors.white,
                  iconColor:
                      jagger.trafficEnabled ? Colors.white : Colors.black,
                ),
                const SizedBox(height: 10),
                _buildMapButton(
                  heroTag: 'mapTypeDMANMAP',
                  icon: Icons.layers,
                  onPressed: () => _showMapTypeSheet(context, jagger),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapButton({
    required String heroTag,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        elevation: 0,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  void _showMapTypeSheet(BuildContext context, JaggerProvider jagger) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Газрын зургийн төрөл',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMapTypeOption(
                  context,
                  jagger,
                  MapType.normal,
                  'Энгийн',
                  Icons.map,
                ),
                _buildMapTypeOption(
                  context,
                  jagger,
                  MapType.satellite,
                  'Хиймэл дагуул',
                  Icons.satellite_alt,
                ),
                _buildMapTypeOption(
                  context,
                  jagger,
                  MapType.terrain,
                  'Газрын гадарга',
                  Icons.terrain,
                ),
                _buildMapTypeOption(
                  context,
                  jagger,
                  MapType.hybrid,
                  'Холимог',
                  Icons.layers,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption(
    BuildContext context,
    JaggerProvider jagger,
    MapType type,
    String label,
    IconData icon,
  ) {
    final isSelected = jagger.mapType == type;
    return GestureDetector(
      onTap: () {
        jagger.mapType = type;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        jagger.notifyListeners();
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.teal : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLocationButton extends StatefulWidget {
  final bool isTracking;
  final VoidCallback onPressed;

  const _AnimatedLocationButton({
    required this.isTracking,
    required this.onPressed,
  });

  @override
  State<_AnimatedLocationButton> createState() =>
      _AnimatedLocationButtonState();
}

class _AnimatedLocationButtonState extends State<_AnimatedLocationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isTracking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTracking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isTracking && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isTracking)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal
                        .withOpacity(0.3 * (1.2 - _pulseAnimation.value)),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.isTracking
                        ? Colors.teal.withOpacity(0.3)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: widget.isTracking ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: 'myLocationDMANMAP',
                mini: true,
                elevation: 0,
                onPressed: widget.onPressed,
                backgroundColor: widget.isTracking ? Colors.teal : Colors.white,
                child: Icon(
                  Icons.my_location,
                  color: widget.isTracking ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
