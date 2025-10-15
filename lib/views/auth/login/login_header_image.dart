import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/utilities/a_utils.dart';

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
          color: primary.withAlpha(75),
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
