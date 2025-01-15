import 'package:flutter/material.dart';

class PharmoIndicator extends StatefulWidget {
  const PharmoIndicator({super.key});

  @override
  State<PharmoIndicator> createState() => _PharmoIndicatorState();
}

class _PharmoIndicatorState extends State<PharmoIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 2 * 3.141592653589793,
          child: child,
        );
      },
      child: Image.asset(
        'assets/logo_circle.png',
        height: 50,
      ),
    );
  }
}
