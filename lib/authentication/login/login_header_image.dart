import 'dart:math' as math;
import 'package:pharmo_app/application/function/utilities/a_utils.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

class LoginHeaderImage extends StatefulWidget {
  final bool loading;

  const LoginHeaderImage({
    super.key,
    this.loading = false,
  });

  @override
  State<LoginHeaderImage> createState() => _LoginHeaderImageState();
}

class _LoginHeaderImageState extends State<LoginHeaderImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void didUpdateWidget(LoginHeaderImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !oldWidget.loading) {
      _controller.repeat();
    } else if (!widget.loading && oldWidget.loading) {
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, darkPrimary],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Loading ring animation
          if (widget.loading)
            AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      gradient: SweepGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Logo with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.loading ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Hero(
              tag: 'logo',
              child: Image.asset('assets/picon.png', width: 120),
            ),
          ),
        ],
      ),
    );
  }
}
