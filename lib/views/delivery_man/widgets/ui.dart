import 'package:flutter/material.dart';

class PricingCard extends StatelessWidget {
  const PricingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF04051D), // dark blue
              Color(0xFF2B566E), // teal blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(33, 150, 243, 0.4),
              offset: Offset(0, 10),
              blurRadius: 15,
            ),
            BoxShadow(
              color: Color.fromRGBO(33, 150, 243, 0.4),
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Personal edition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color.fromRGBO(255, 255, 255, 0.64),
                      letterSpacing: 1,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '\$39.99',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur at posuere eros. Interdum et malesuada fames ac ante ipsum primis in faucibus.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(255, 255, 255, 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  // Do something on Buy now
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3), // blue
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 10,
                  shadowColor: const Color(0xFF2C3442),
                ),
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PulsingDots extends StatefulWidget {
  const PulsingDots({super.key});

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnimations;

  final List<Duration> delays = const [
    Duration(milliseconds: 300),
    Duration(milliseconds: 100),
    Duration(milliseconds: 0),
    Duration(milliseconds: 100),
    Duration(milliseconds: 300),
  ];

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 50),
      ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(delays[i], () {
        _controllers[i].repeat();
      });
    }
  }

  // @override
  // void dispose() {
  //   for (var controller in _controllers) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.scale(
        scale: animation.value,
        child: Container(
          height: 10,
          width: 10,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: animation.value > 1
                ? const Color(0xFF6793FB)
                : const Color(0xFFB3D4FC),
            boxShadow: [
              if (animation.value > 1)
                BoxShadow(
                  color: const Color(0xFFB2D4FC).withOpacity(0.7),
                  spreadRadius: 0,
                  blurRadius: 10,
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _scaleAnimations.length,
          (index) => _buildDot(_scaleAnimations[index]),
        )..last = Padding(
            padding: EdgeInsets.zero, // Remove margin for last dot
            child: _buildDot(_scaleAnimations.last),
          ),
      ),
    );
  }
}
