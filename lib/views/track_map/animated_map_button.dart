import 'package:flutter/material.dart';

class AnimatedMapButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final String heroTag;
  final bool showPulse;
  final String? tooltip;

  const AnimatedMapButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.heroTag,
    this.backgroundColor,
    this.iconColor,
    this.showPulse = false,
    this.tooltip,
  });

  @override
  State<AnimatedMapButton> createState() => _AnimatedMapButtonState();
}

class _AnimatedMapButtonState extends State<AnimatedMapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.showPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedMapButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.showPulse && _controller.isAnimating) {
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
            if (widget.showPulse)
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.backgroundColor ?? Colors.white)
                        .withOpacity(0.3 * (1.3 - _pulseAnimation.value)),
                  ),
                ),
              ),
            Transform.scale(
              scale: widget.showPulse ? _scaleAnimation.value : 1.0,
              child: FloatingActionButton(
                heroTag: widget.heroTag,
                elevation: widget.showPulse ? 8 : 4,
                onPressed: widget.onPressed,
                backgroundColor: widget.backgroundColor ?? Colors.white,
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = Colors.teal,
    this.size = 12,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedTrackingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isStart;
  final bool isLoading;

  const AnimatedTrackingButton({
    super.key,
    required this.onPressed,
    required this.isStart,
    this.isLoading = false,
  });

  @override
  State<AnimatedTrackingButton> createState() => _AnimatedTrackingButtonState();
}

class _AnimatedTrackingButtonState extends State<AnimatedTrackingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (!widget.isStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTrackingButton oldWidget) {
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
    final bgColor = widget.isStart ? Colors.green : Colors.red;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (!widget.isStart)
              Transform.scale(
                scale: _pulseAnimation.value * 1.15,
                child: Container(
                  height: 48,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: bgColor.withOpacity(
                        0.3 * (1.05 - (_pulseAnimation.value - 1.0) * 10)),
                  ),
                ),
              ),
            Transform.scale(
              scale: !widget.isStart ? _pulseAnimation.value : 1.0,
              child: FloatingActionButton.extended(
                elevation: !widget.isStart ? 12 : 6,
                heroTag: 'trackingButton',
                onPressed: widget.isLoading ? null : widget.onPressed,
                backgroundColor: bgColor,
                label: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!widget.isStart) ...[
                            const PulsingDot(color: Colors.white, size: 10),
                            const SizedBox(width: 12),
                          ] else ...[
                            Icon(
                              Icons.gps_fixed,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            'Борлуулалт ${widget.isStart ? 'эхлэх' : 'дуусгах'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
