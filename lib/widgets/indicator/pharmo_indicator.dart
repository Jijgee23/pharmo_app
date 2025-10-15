import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class PharmoIndicator extends StatefulWidget {
  final bool withMaterial;
  final double size;
  const PharmoIndicator({
    super.key,
    this.withMaterial = false,
    this.size = 50,
  });

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
    if (widget.withMaterial) {
      return Material(
        color: white,
        child: Center(
          child: child(),
        ),
      );
    }
    return Center(
      child: child(),
    );
  }

  Widget child() {
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
        height: widget.size,
        width: widget.size,
      ),
    );
  }
}
