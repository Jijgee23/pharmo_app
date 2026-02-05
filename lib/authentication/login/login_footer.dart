import 'package:pharmo_app/application/application.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, darkPrimary],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(80),
        ),
      ),
    );
  }
}
