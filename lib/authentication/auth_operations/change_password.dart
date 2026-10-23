import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Signed-in password change (auth/change/). The server ends every session
/// on success, this one included, so the user is signed out to log in again.
class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPassword = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showPass = false;
  bool loading = false;

  @override
  void dispose() {
    oldPassword.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (loading || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);
    try {
      final auth = context.read<AuthController>();
      final changed = await auth.changePassword(oldPassword.text, password.text);
      if (!changed || !mounted) return;
      messageComplete('Нууц үг солигдлоо. Шинэ нууц үгээрээ нэвтэрнэ үү.');
      // The session is already gone server-side, so no logout request.
      await auth.logout(context, withoutRequest: true);
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
    return AuthScaffold(
      children: [
        const AuthHeader(
          leading: AuthIconTile(icon: Icons.password_rounded),
          title: 'Нууц үг солих',
          subtitle: AuthSubtitle(
            'Нууц үг солигдсоны дараа бүх төхөөрөмжөөс гарч, шинэ нууц үгээрээ дахин нэвтэрнэ.',
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthLabel('Одоогийн нууц үг'),
              CustomTextField(
                controller: oldPassword,
                hintText: '••••••••',
                prefix: Icons.lock_outline_rounded,
                obscureText: !showPass,
                suffixIcon: visibility,
                autofillHints: const [AutofillHints.password],
                enabled: !loading,
                validator: (v) => (v == null || v.isEmpty) ? 'Одоогийн нууц үгээ оруулна уу' : null,
              ),
              const SizedBox(height: 24),
              const AuthLabel('Шинэ нууц үг'),
              CustomTextField(
                controller: password,
                hintText: 'Нууц үг',
                prefix: Icons.lock_reset_rounded,
                obscureText: !showPass,
                suffixIcon: visibility,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !loading,
                validator: (v) =>
                    validatePassword(v) ??
                    (v == oldPassword.text ? 'Шинэ нууц үг одоогийнхоос өөр байх ёстой' : null),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: confirmPassword,
                hintText: 'Нууц үг давтах',
                prefix: Icons.lock_reset_rounded,
                obscureText: !showPass,
                suffixIcon: visibility,
                keyboardType: TextInputType.visiblePassword,
                enabled: !loading,
                validator: (v) => v != password.text ? 'Нууц үг таарахгүй байна' : null,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 28),
              AuthPrimaryButton(text: 'Нууц үг солих', onTap: _save, loading: loading),
            ],
          ),
        ),
      ],
    );
  }
}
