import 'package:pharmo_app/application/utilities/a_utils.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

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
              primary.withAlpha(50),
              darkPrimary.withAlpha(80),
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
