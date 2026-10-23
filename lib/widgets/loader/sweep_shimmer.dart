import 'package:flutter/material.dart';

/// Sweeps a light band across [child], for skeleton placeholders: every
/// [SkeletonBox] inside shares the one animation.
class SweepShimmer extends StatefulWidget {
  final Widget child;

  /// [BlendMode.srcATop] paints the band over everything, cards included;
  /// [BlendMode.modulate] keeps white cards white and sweeps the boxes.
  final BlendMode blendMode;

  const SweepShimmer({super.key, required this.child, this.blendMode = BlendMode.srcATop});

  @override
  State<SweepShimmer> createState() => _SweepShimmerState();
}

class _SweepShimmerState extends State<SweepShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();
  late final Animation<double> _slide = Tween<double>(begin: -2.5, end: 2.5).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slide,
      builder: (context, child) => ShaderMask(
        blendMode: widget.blendMode,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(_slide.value - 1, 0),
          end: Alignment(_slide.value + 1, 0),
          colors: const [
            Color(0xFFE8ECED),
            Color(0xFFF5F7F7),
            Color(0xFFFFFFFF),
            Color(0xFFF5F7F7),
            Color(0xFFE8ECED),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A grey placeholder rectangle, under a [SweepShimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7E7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
