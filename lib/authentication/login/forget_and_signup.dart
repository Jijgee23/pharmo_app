import 'package:pharmo_app/application/application.dart';

class ForgetAndSignup extends StatelessWidget {
  const ForgetAndSignup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextButton(
          text: 'Нууц үг сэргээх',
          onTap: () => goNamed('reset_password'),
        ),
        CustomTextButton(
          text: 'Бүртгүүлэх',
          onTap: () => goNamed('signup'),
        ),
      ],
    );
  }
}
