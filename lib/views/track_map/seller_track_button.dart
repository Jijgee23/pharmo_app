import 'package:pharmo_app/application/application.dart';

class SellerTrackButton extends StatefulWidget {
  final bool isStart;
  final void Function() onPressed;

  const SellerTrackButton({
    super.key,
    required this.onPressed,
    required this.isStart,
  });

  @override
  State<SellerTrackButton> createState() => _SellerTrackButtonState();
}

class _SellerTrackButtonState extends State<SellerTrackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

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

    if (!widget.isStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SellerTrackButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isStart && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.isStart && _controller.isAnimating) {
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
    return Positioned(
      bottom: 20,
      left: 20,
      child: SafeArea(
        child: Builder(builder: (context) {
          if (user == null || !user.isSaler) {
            return const SizedBox();
          }
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final bgColor = widget.isStart ? Colors.green : Colors.red;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (!widget.isStart)
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        height: 48,
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: bgColor.withOpacity(
                              0.25 * (1.15 - _pulseAnimation.value) * 6.67),
                        ),
                      ),
                    ),
                  Transform.scale(
                    scale: !widget.isStart ? _scaleAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: !widget.isStart ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        heroTag: 'trackingDeliveriesSeller',
                        onPressed: widget.onPressed,
                        backgroundColor: bgColor,
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!widget.isStart) ...[
                              _PulsingDot(),
                              const SizedBox(width: 12),
                            ] else ...[
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              "Борлуулалт ${widget.isStart ? 'эхлэх' : 'дуусгах'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (!widget.isStart) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.stop_rounded,
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
        }),
      ),
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
