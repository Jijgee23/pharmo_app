import 'package:pharmo_app/application/application.dart';

class MapHeading extends StatelessWidget {
  final bool isSeller;
  final bool showTracking;
  const MapHeading({
    super.key,
    required this.isSeller,
    required this.showTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 16,
      left: 16,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSeller)
              Container(
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
                  heroTag: 'backST',
                  mini: true,
                  elevation: 0,
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
            if (showTracking) const _LiveTrackingIndicator(),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _LiveTrackingIndicator extends StatefulWidget {
  const _LiveTrackingIndicator();

  @override
  State<_LiveTrackingIndicator> createState() => _LiveTrackingIndicatorState();
}

class _LiveTrackingIndicatorState extends State<_LiveTrackingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _dotAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.teal.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _dotAnimation,
              builder: (context, child) {
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.withOpacity(_dotAnimation.value),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4 * _dotAnimation.value),
                        blurRadius: 6 * _dotAnimation.value,
                        spreadRadius: 1 * _dotAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
