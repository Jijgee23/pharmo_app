import 'package:pharmo_app/app_configs.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';

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
