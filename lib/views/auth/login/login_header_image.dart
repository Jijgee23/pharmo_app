import 'package:pharmo_app/controller/providers/a_controlller.dart';

class LoginHeaderImage extends StatelessWidget {
  const LoginHeaderImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withAlpha(50),
              Colors.pink.withAlpha(80),
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Image.asset('assets/picon.png'),
      ),
    );
  }
}
