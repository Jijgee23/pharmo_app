import 'dart:math' as math;

import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Logo in an [AuthIconTile] atop the login screen. Pulses and shows a
/// rotating ring while [loading].
class LoginHeaderImage extends StatefulWidget {
  final bool loading;

  const LoginHeaderImage({
    super.key,
    this.loading = false,
  });

  @override
  State<LoginHeaderImage> createState() => _LoginHeaderImageState();
}

class _LoginHeaderImageState extends State<LoginHeaderImage> with SingleTickerProviderStateMixin {
  static const tileSize = 88.0;

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.loading) _controller.repeat();
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
    final primaryColor = context.theme.primaryColor;
    return SizedBox(
      width: tileSize + 24,
      height: tileSize + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.loading)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: child,
              ),
              child: Container(
                width: tileSize + 22,
                height: tileSize + 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: SweepGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.0),
                      primaryColor.withValues(alpha: 0.5),
                      primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ScaleTransition(
            scale: widget.loading ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: AuthIconTile(
              size: tileSize,
              child: Hero(
                tag: 'logo',
                child: Image.asset('assets/picon.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
