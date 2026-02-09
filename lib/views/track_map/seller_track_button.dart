import 'package:pharmo_app/application/application.dart';

class SellerTrackButton extends StatefulWidget {
  const SellerTrackButton({super.key});

  @override
  State<SellerTrackButton> createState() => _SellerTrackButtonState();
}

class _SellerTrackButtonState extends State<SellerTrackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  TrackState? _previousState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _syncAnimation(TrackState state) {
    if (_previousState == state) return;
    _previousState = state;
    if (state == TrackState.tracking || state == TrackState.paused) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
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
    final user = Authenticator.security;
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        _syncAnimation(jagger.trackState);
        return Positioned(
          bottom: 20,
          left: 20,
          child: SafeArea(
            child: Builder(
              builder: (context) {
                if (user == null || !user.isSaler) {
                  return const SizedBox();
                }
                final trackState = jagger.trackState;
                final bgColor = trackState.btnColor;
                final bool isNone = trackState == TrackState.none;
                final bool isTracking = trackState == TrackState.tracking;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (!isNone)
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              height: 48,
                              width: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: bgColor.withOpacity(0.25 *
                                    (1.15 - _pulseAnimation.value) *
                                    6.67),
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: !isNone ? _scaleAnimation.value : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: bgColor.withOpacity(0.4),
                                  blurRadius: !isNone ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FloatingActionButton.extended(
                              elevation: 0,
                              heroTag: 'trackingDeliveriesSeller',
                              onPressed: jagger.toggleTracking,
                              backgroundColor: bgColor,
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isTracking) ...[
                                    _PulsingDot(),
                                    const SizedBox(width: 12),
                                  ] else ...[
                                    Icon(
                                      trackState.icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    "Борлуулалт ${trackState.label}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isTracking) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      trackState.icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5 * _animation.value),
                blurRadius: 6 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
