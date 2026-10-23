import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController ema = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController passConfirm = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Validation хийхэд хэрэгтэй
  bool showPasss = false;
  bool otpSent = false;
  bool loading = false;
  String otp = '';

  @override
  void dispose() {
    ema.dispose();
    pass.dispose();
    phone.dispose();
    passConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        AuthHeader(
          leading: AuthIconTile(
            icon: otpSent ? Icons.mark_email_read_rounded : Icons.person_add_alt_1_rounded,
          ),
          title: 'Бүртгүүлэх',
          subtitle: otpSent
              ? AuthSubtitle(
                  'Баталгаажуулах кодыг ${ema.text.trim()} хаяг руу илгээлээ.',
                  highlight: ema.text.trim(),
                )
              : const AuthSubtitle('Шинэ бүртгэл үүсгэхийн тулд мэдээллээ оруулна уу.'),
        ),
        const SizedBox(height: 24),
        AuthStepIndicator(
          secondStep: otpSent,
          firstLabel: 'Мэдээлэл',
          secondLabel: 'Баталгаажуулалт',
        ),
        const SizedBox(height: 28),
        AuthStepSwitcher(child: otpSent ? _otpStep() : _infoStep()),
      ],
    );
  }

  Widget _infoStep() {
    final visibility = PasswordVisibilityButton(
      visible: showPasss,
      onTap: () => setState(() => showPasss = !showPasss),
    );
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          key: const ValueKey('info-step'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthLabel('И-мейл хаяг'),
            CustomTextField(
              controller: ema,
              hintText: 'example@mail.com',
              prefix: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (v) => validateEmail(v),
            ),
            const SizedBox(height: 18),
            const AuthLabel('Утасны дугаар'),
            CustomTextField(
              controller: phone,
              hintText: '99112233',
              prefix: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (v) => validatePhone(v),
            ),
            const SizedBox(height: 18),
            const AuthLabel('Нууц үг'),
            CustomTextField(
              controller: pass,
              hintText: 'Нууц үг',
              obscureText: !showPasss,
              prefix: Icons.lock_outline_rounded,
              suffixIcon: visibility,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) => validatePassword(v),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: passConfirm,
              hintText: 'Нууц үг давтах',
              obscureText: !showPasss,
              prefix: Icons.lock_reset_rounded,
              suffixIcon: visibility,
              keyboardType: TextInputType.visiblePassword,
              validator: (v) => v != pass.text ? 'Нууц үг таарахгүй байна' : null,
              onSubmitted: (_) => _getFirstOtp(),
            ),
            const SizedBox(height: 28),
            AuthPrimaryButton(
              text: 'Баталгаажуулах код авах',
              onTap: _getFirstOtp,
              loading: loading,
            ),
            const SizedBox(height: 24),
            AuthPrompt(
              question: 'Бүртгэлтэй юу? ',
              action: 'Нэвтрэх',
              onTap: loading ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpStep() {
    return Column(
      key: const ValueKey('otp-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthLabel('Баталгаажуулах код'),
        OtpInput(onChanged: (pin) => otp = pin, onResend: getOtp),
        const SizedBox(height: 28),
        AuthPrimaryButton(text: 'Бүртгэл баталгаажуулах', onTap: confirm, loading: loading),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: loading ? null : () => setState(() => otpSent = false),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Мэдээлэл засах'),
          style: TextButton.styleFrom(foregroundColor: grey600),
        ),
      ],
    );
  }

  Future<void> _getFirstOtp() async {
    if (loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      // On a cooldown the code sent moments ago is still valid, so the code
      // step is shown either way.
      final request = await _requestOtp();
      if (request != OtpRequest.failed && mounted) {
        setState(() {
          otp = '';
          otpSent = true;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Код дахин илгээх
  Future<bool> getOtp() async => await _requestOtp() == OtpRequest.sent;

  // Код авах
  Future<OtpRequest> _requestOtp() async {
    dynamic res = await context
        .read<AuthController>()
        .signUpGetOtp(ema.text.trim(), phone.text.trim());
    // null: the request never got an answer, and the user was already told why.
    if (res == null) return OtpRequest.failed;
    switch (res['errorType']) {
      case 1:
        messageComplete(res['message']);
        return OtpRequest.sent;
      case 4:
        messageWarning(res['message']);
        return OtpRequest.cooldown;
      default:
        messageWarning(res['message']);
        return OtpRequest.failed;
    }
  }

  Future<void> confirm() async {
    if (loading) return;
    if (otp.length != OtpInput.length) {
      messageWarning('Баталгаажуулах кодоо бүрэн оруулна уу!');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      dynamic res = await context.read<AuthController>().register(
            email: ema.text.trim(),
            phone: phone.text.trim(),
            otp: otp,
            password: pass.text,
          );
      if (!mounted) return;
      if (res != null && res['errorType'] == 1) {
        messageComplete(res['message']);
        Navigator.pop(context);
      } else {
        messageWarning(res?['message'] ?? 'Алдаа гарлаа');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
