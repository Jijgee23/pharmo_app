import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pharmo — animated launch screen (design 1a)

class PharmoColors {
  static const navy = Color(0xFF16306E);
  static const blue = Color(0xFF2979FF);
  static const teal = Color(0xFF3A9199);
  static const green = Color(0xFF22D18B);
  static const ring = Color(0xFFEEF3FB);
}

class PharmoSplashScreen extends StatefulWidget {
  const PharmoSplashScreen({super.key, this.onFinished});

  /// Called once the intro finishes — push your home route here.
  final VoidCallback? onFinished;

  @override
  State<PharmoSplashScreen> createState() => _PharmoSplashScreenState();
}

class _PharmoSplashScreenState extends State<PharmoSplashScreen> with TickerProviderStateMixin {
  static const _total = Duration(milliseconds: 2600);

  late final AnimationController _c = AnimationController(vsync: this, duration: _total);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  // Logo: rotate -150° -> 0°, scale 0.25 -> 1.06 -> 1, fade in.
  late final Animation<double> _logoTurn = Tween(begin: -150 / 360, end: 0.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.46, curve: Curves.easeOutBack)));

  late final Animation<double> _logoScale = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 0.25, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70),
    TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
  ]).animate(CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.5)));

  late final Animation<double> _logoFade =
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.22, curve: Curves.easeOut));

  // Wordmark: rise 14px + fade.
  late final Animation<double> _wordFade =
      CurvedAnimation(parent: _c, curve: const Interval(0.28, 0.58, curve: Curves.easeOut));

  // Progress bar + footnote.
  late final Animation<double> _bar =
      CurvedAnimation(parent: _c, curve: const Interval(0.30, 1.0, curve: Curves.easeInOut));
  late final Animation<double> _footFade =
      CurvedAnimation(parent: _c, curve: const Interval(0.44, 0.72, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Soft brand glow behind the mark.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.32),
                  radius: 0.95,
                  colors: [Color(0x122979FF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.62],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _logo(),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _wordFade,
                  child: AnimatedBuilder(
                    animation: _wordFade,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, 14 * (1 - _wordFade.value)),
                      child: child,
                    ),
                    child: const Text(
                      'Pharmo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        height: 1,
                        letterSpacing: -0.8,
                        color: PharmoColors.navy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 74,
            child: FadeTransition(
              opacity: _footFade,
              child: Column(
                children: [
                  _progressBar(),
                  const SizedBox(height: 16),
                  Text(
                    'SECURE · LICENSED · 24/7',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      height: 1,
                      letterSpacing: 1.5,
                      color: PharmoColors.navy.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding green halo.
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final t = _pulse.value;
              return Opacity(
                opacity: (1 - t) * 0.35,
                child: Transform.scale(
                  scale: 0.6 + t * 0.75,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x5522D18B), Color(0x0022D18B)],
                        stops: [0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Circular badge + spinning-in mark.
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) => Opacity(
              opacity: _logoFade.value,
              child: Transform.rotate(
                angle: _logoTurn.value * 2 * math.pi,
                child: Transform.scale(scale: _logoScale.value, child: child),
              ),
            ),
            child: Container(
              width: 158,
              height: 158,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: PharmoColors.ring, width: 14),
                boxShadow: [
                  BoxShadow(
                    color: PharmoColors.navy.withOpacity(0.14),
                    blurRadius: 34,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo_circle.png',
                  width: 116,
                  height: 116,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return Container(
      width: 148,
      height: 4,
      decoration: BoxDecoration(
        color: PharmoColors.navy.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedBuilder(
          animation: _bar,
          builder: (_, __) => FractionallySizedBox(
            widthFactor: _bar.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [PharmoColors.blue, PharmoColors.teal, PharmoColors.green],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
