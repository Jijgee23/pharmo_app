import 'package:flutter/material.dart';
import 'package:pharmo_app/application/application.dart';

class ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double height;
  const ShimmerBox({super.key, required this.controller, required this.height});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: const [0.1, 0.5, 0.9],
              transform: GradientRotation(controller.value * 3.14),
            ).createShader(bounds);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            height: height,
            width: double.maxFinite,
          ),
        );
      },
    );
  }
}
