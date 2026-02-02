import 'package:pharmo_app/application/function/utilities/a_utils.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

class LoginHeaderImage extends StatelessWidget {
  const LoginHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3, // Тогтмол харьцаа
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, darkPrimary],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(80), // Илүү загварлаг хэлбэр
        ),
      ),
      child: Center(
        child: Hero(
          // Animation-д зориулсан
          tag: 'logo',
          child: Image.asset('assets/picon.png', width: 120),
        ),
      ),
    );
  }
}
