import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';
import 'package:pharmo_app/authentication/widgets/new_password_form.dart';

/// Bottom sheet shown on login when the account has no password yet
/// (auth/reged/ `pwd: false`, or `no_password` from auth/login/). Sends a
/// code to [identifier] (e-mail, or a phone already verified), then sets
/// the new password.
class CreatePassDialog extends StatefulWidget {
  final String identifier;
  const CreatePassDialog({
    super.key,
    required this.identifier,
  });

  @override
  State<CreatePassDialog> createState() => _CreatePassDialogState();
}

class _CreatePassDialogState extends State<CreatePassDialog> {
  bool otpSent = false;
  bool loading = false;

  LoginMethod get method => LoginMethod.of(widget.identifier);

  Future<void> _sendOtp() async {
    if (loading) return;
    setState(() => loading = true);
    try {
      final request = await context.read<AuthController>().sendPasswordOtp(widget.identifier);
      if (request != OtpRequest.failed && mounted) setState(() => otpSent = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = method == LoginMethod.email;
    return AuthSheet(
      icon: otpSent
          ? (isEmail ? Icons.mark_email_read_rounded : Icons.mark_chat_read_rounded)
          : Icons.key_rounded,
      title: 'Нууц үг үүсгэх',
      subtitle: otpSent
          ? '6 оронтой кодыг ${isEmail ? 'и-мейл рүү' : 'утас руу'} тань илгээлээ.'
          : 'Таны бүртгэлд нууц үг байхгүй байна. Шинээр үүсгэнэ үү.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthStepIndicator(
            secondStep: otpSent,
            firstLabel: 'Баталгаажуулалт',
            secondLabel: 'Шинэ нууц үг',
          ),
          const SizedBox(height: 24),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: AuthStepSwitcher(
              child: otpSent
                  ? NewPasswordForm(
                      key: const ValueKey('password-step'),
                      identifier: widget.identifier,
                    )
                  : _identifierStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identifierStep() {
    return Column(
      key: const ValueKey('identifier-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthLabel(method.fieldLabel),
        AuthInfoBox(
          child: Row(
            children: [
              Icon(method.icon, size: 20, color: context.theme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.identifier,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: grey600, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: 'Баталгаажуулах код авах', onTap: _sendOtp, loading: loading),
      ],
    );
  }
}
