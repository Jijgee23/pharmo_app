import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Second step of password reset / creation: OTP (sent to [identifier], an
/// e-mail or phone number) + new password twice. Shown right after the first
/// code was sent.
class NewPasswordForm extends StatefulWidget {
  final String identifier;
  const NewPasswordForm({super.key, required this.identifier});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> {
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String otp = '';
  bool showPass = false;
  bool loading = false;

  @override
  void dispose() {
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (loading) return;
    if (otp.length != OtpInput.length) {
      messageWarning('Баталгаажуулах кодоо бүрэн оруулна уу!');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      // Pops the current route (screen or sheet) on success.
      await context
          .read<AuthController>()
          .createPassword(widget.identifier, otp, password.text, context);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = PasswordVisibilityButton(
      visible: showPass,
      onTap: () => setState(() => showPass = !showPass),
    );
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthLabel('Баталгаажуулах код'),
          OtpInput(
            onChanged: (pin) => otp = pin,
            onResend: () async =>
                await context.read<AuthController>().sendPasswordOtp(widget.identifier) ==
                OtpRequest.sent,
          ),
          const SizedBox(height: 24),
          const AuthLabel('Шинэ нууц үг'),
          CustomTextField(
            controller: password,
            hintText: 'Нууц үг',
            prefix: Icons.lock_outline_rounded,
            obscureText: !showPass,
            suffixIcon: visibility,
            keyboardType: TextInputType.visiblePassword,
            autofillHints: const [AutofillHints.newPassword],
            validator: (v) => validatePassword(v),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: confirmPassword,
            hintText: 'Нууц үг давтах',
            prefix: Icons.lock_reset_rounded,
            obscureText: !showPass,
            suffixIcon: visibility,
            keyboardType: TextInputType.visiblePassword,
            validator: (v) => v != password.text ? 'Нууц үг таарахгүй байна' : null,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(text: 'Нууц үг хадгалах', onTap: _save, loading: loading),
        ],
      ),
    );
  }
}
