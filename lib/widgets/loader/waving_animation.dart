import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';

class WavingAnimation extends StatefulWidget {
  final String assetPath;
  final bool dots;

  const WavingAnimation({
    super.key,
    required this.assetPath,
    required this.dots,
  });

  @override
  State<WavingAnimation> createState() => _WavingAnimationState();
}

class _WavingAnimationState extends State<WavingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double yOffset = sin(_controller.value * pi * 2) * 10;
        return Transform.translate(
          offset: Offset(0, yOffset),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          dots(),
          if (widget.dots) space(),
          ClipOval(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: 50,
              height: 50,
              color: Colors.white,
              child: Image.asset(
                widget.assetPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (widget.dots) space(),
          if (widget.dots) dots(),
        ],
      ),
    );
  }

  SizedBox space() => const SizedBox(width: 10);

  AnimatedBuilder dots() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            double delayFactor = index * 0.2;
            double yOffset = sin((_controller.value + delayFactor) * pi * 2) * 5;
            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
