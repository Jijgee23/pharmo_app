import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Texts a code to [phone] and asks for it in a bottom sheet. True once the
/// number is verified — phone sign-in and SMS password codes both need that.
/// [reason] says why verification is being asked for.
Future<bool> showPhoneVerifySheet(AuthController auth, String phone, {String? reason}) async {
  if (!await auth.sendPhoneVerification(phone)) return false;
  final verified = await Get.bottomSheet<bool>(
    PhoneVerifySheet(phone: phone, reason: reason),
    isScrollControlled: true,
  );
  return verified ?? false;
}

class PhoneVerifySheet extends StatefulWidget {
  final String phone;
  final String? reason;
  const PhoneVerifySheet({super.key, required this.phone, this.reason});

  @override
  State<PhoneVerifySheet> createState() => _PhoneVerifySheetState();
}

class _PhoneVerifySheetState extends State<PhoneVerifySheet> {
  String otp = '';
  bool loading = false;

  Future<void> _verify() async {
    if (loading) return;
    if (otp.length != OtpInput.length) {
      messageWarning('Баталгаажуулах кодоо бүрэн оруулна уу!');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      final verified = await context.read<AuthController>().verifyPhone(widget.phone, otp);
      if (verified && mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSheet(
      icon: Icons.phonelink_lock_rounded,
      title: 'Утас баталгаажуулах',
      subtitle: widget.reason ?? 'Утасны дугаараа баталгаажуулна уу.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthSubtitle(
            '6 оронтой баталгаажуулах кодыг ${widget.phone} дугаар руу илгээлээ.',
            highlight: widget.phone,
          ),
          const SizedBox(height: 20),
          const AuthLabel('Баталгаажуулах код'),
          OtpInput(
            onChanged: (pin) => otp = pin,
            onResend: () => context.read<AuthController>().sendPhoneVerification(widget.phone),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(text: 'Баталгаажуулах', onTap: _verify, loading: loading),
        ],
      ),
    );
  }
}
