import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';
import 'package:pharmo_app/authentication/widgets/new_password_form.dart';

/// E-mail or phone → code → new password (auth/reset/). [NewPasswordForm]
/// pops this page on success, back to the login page's password step.
class ResetPassword extends StatefulWidget {
  /// Prefills the identifier field, e.g. the account being signed in to.
  final String? identifier;

  const ResetPassword({super.key, this.identifier});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late LoginMethod method = LoginMethod.of(widget.identifier ?? '');
  late final email =
      TextEditingController(text: method == LoginMethod.email ? widget.identifier : null);
  late final phone =
      TextEditingController(text: method == LoginMethod.phone ? widget.identifier : null);
  final _formKey = GlobalKey<FormState>();
  bool otpSent = false;
  bool loading = false;

  TextEditingController get controller => method == LoginMethod.email ? email : phone;
  String get identifier => controller.text.trim();

  @override
  void dispose() {
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      final auth = context.read<AuthController>();
      final status = await auth.checkUsableAccount(
        identifier,
        verifyReason: 'Нууц үг сэргээхийн өмнө дугаараа баталгаажуулна уу.',
      );
      if (status == null) return;
      if (await auth.sendPasswordOtp(identifier) == OtpRequest.failed) return;
      if (mounted) setState(() => otpSent = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = method == LoginMethod.email;
    return AuthScaffold(
      children: [
        AuthHeader(
          leading: AuthIconTile(
            icon: otpSent
                ? (isEmail ? Icons.mark_email_read_rounded : Icons.mark_chat_read_rounded)
                : Icons.lock_reset_rounded,
          ),
          title: 'Нууц үг сэргээх',
          subtitle: otpSent
              ? AuthSubtitle(
                  '6 оронтой баталгаажуулах кодыг $identifier ${isEmail ? 'хаяг' : 'дугаар'} руу илгээлээ.',
                  highlight: identifier,
                )
              : const AuthSubtitle(
                  'Бүртгэлтэй и-мейл хаяг эсвэл утасны дугаараа оруулбал бид танд баталгаажуулах код илгээнэ.',
                ),
        ),
        const SizedBox(height: 24),
        AuthStepIndicator(
          secondStep: otpSent,
          firstLabel: method.label,
          secondLabel: 'Шинэ нууц үг',
        ),
        const SizedBox(height: 28),
        AuthStepSwitcher(child: otpSent ? _resetStep() : _identifierStep()),
      ],
    );
  }

  Widget _identifierStep() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('identifier-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthMethodSwitch(
            value: method,
            onChanged: loading ? null : (m) => setState(() => method = m),
          ),
          const SizedBox(height: 16),
          AuthIdentifierField(
            method: method,
            controller: controller,
            enabled: !loading,
            onSubmitted: (_) => _sendOtp(),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            text: 'Баталгаажуулах код авах',
            onTap: _sendOtp,
            loading: loading,
          ),
        ],
      ),
    );
  }

  Widget _resetStep() {
    return Column(
      key: const ValueKey('reset-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NewPasswordForm(identifier: identifier),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => otpSent = false),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(method == LoginMethod.email ? 'И-мейл хаяг солих' : 'Утасны дугаар солих'),
          style: TextButton.styleFrom(foregroundColor: grey600),
        ),
      ],
    );
  }
}
