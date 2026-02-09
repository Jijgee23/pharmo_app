import 'package:pharmo_app/application/application.dart';

class AuthText extends StatelessWidget {
  final String text;
  const AuthText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: context.theme.primaryColor,
        ),
      ),
    );
  }
}
