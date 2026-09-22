import 'package:pharmo_app/application/app_lite.dart';

/// Plain circular spinner (no logo) for full-screen loading overlays —
/// see PharmoIndicator for the branded, logo-rotating alternative used on
/// the splash/root screen.
class CustomLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomLoader({super.key, this.size = 44, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? primary,
        strokeWidth: 3.5,
      ),
    );
  }
}
