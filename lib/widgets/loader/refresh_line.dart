import 'package:pharmo_app/application/app_lite.dart';

/// A thin progress line while [active]; kept 2px tall either way, so
/// nothing under it jumps when it shows.
class RefreshLine extends StatelessWidget {
  final bool active;
  const RefreshLine({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: active
          ? LinearProgressIndicator(minHeight: 2, backgroundColor: primary.withValues(alpha: 0.1))
          : null,
    );
  }
}
