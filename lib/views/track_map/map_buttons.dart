import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

/// The map's own buttons, stacked on the right in two groups: zoom, then
/// my location, the whole delivery, traffic and the map type.
class MapControls extends StatelessWidget {
  const MapControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final hasStops = jagger.delivery?.stops.any((s) => s.coordinates != null) ?? false;
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            _ControlGroup(
              children: [
                _ControlButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Ойртуулах',
                  onTap: () async => jagger.mapController?.animateCamera(CameraUpdate.zoomIn()),
                ),
                _ControlButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Холдуулах',
                  onTap: () async => jagger.mapController?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
            _ControlGroup(
              children: [
                _ControlButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Миний байршил',
                  active: jagger.isTracking,
                  onTap: jagger.goToMyLocation,
                ),
                if (hasStops)
                  _ControlButton(
                    icon: Icons.zoom_out_map_rounded,
                    tooltip: 'Бүх цэгийг харах',
                    onTap: () => jagger.frameDelivery(force: true),
                  ),
                _ControlButton(
                  icon: Icons.traffic_rounded,
                  tooltip: 'Замын түгжрэл',
                  active: jagger.trafficEnabled,
                  onTap: () async => jagger.toggleTraffic(),
                ),
                _ControlButton(
                  icon: Icons.layers_rounded,
                  tooltip: 'Газрын зургийн төрөл',
                  onTap: () async =>
                      Get.bottomSheet(const _MapTypeSheet(), isScrollControlled: true),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Buttons sharing one white rounded card, split by hairlines.
class _ControlGroup extends StatelessWidget {
  final List<Widget> children;
  const _ControlGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Container(width: 28, height: 1, color: grey200),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A map button; shows a spinner (and ignores taps) until [onTap] is done,
/// as finding the caller's location can take a while.
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Future<void> Function() onTap;
  final bool active;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _running = false;

  Future<void> _tap() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        onTap: _tap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          color: widget.active ? primary.withValues(alpha: 0.1) : null,
          child: _running
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.icon,
                  size: 21,
                  color: widget.active ? primary : Colors.grey.shade800,
                ),
        ),
      ),
    );
  }
}

class _MapTypeSheet extends StatelessWidget {
  const _MapTypeSheet();

  static const _types = [
    (MapType.normal, 'Энгийн', Icons.map_outlined),
    (MapType.satellite, 'Хиймэл дагуул', Icons.satellite_alt_outlined),
    (MapType.terrain, 'Гадарга', Icons.terrain_outlined),
    (MapType.hybrid, 'Холимог', Icons.layers_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, _) => AppSheet(
        title: 'Газрын зургийн төрөл',
        children: [
          Row(
            spacing: 10,
            children: [
              for (final (type, label, icon) in _types)
                Expanded(
                  child: _MapTypeOption(
                    label: label,
                    icon: icon,
                    selected: jagger.mapType == type,
                    onTap: () {
                      jagger.setMapType(type);
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MapTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MapTypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: Durations.short4,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? primary : grey200, width: selected ? 1.6 : 1),
        ),
        child: Column(
          spacing: 8,
          children: [
            Icon(icon, size: 26, color: selected ? primary : grey600),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? primary.shade700 : grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
