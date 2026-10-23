import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/auth_operations/reset_pass.dart';
import 'package:pharmo_app/authentication/login/login_header_image.dart';
import 'package:pharmo_app/authentication/widgets/auth_widgets.dart';

/// Two-step sign-in: the e-mail or phone first, checked against the server
/// ([AuthController.continueWithIdentifier]), then the password.
class LoginPage extends StatefulWidget {
  final String? prefillIdentifier;
  const LoginPage({super.key, this.prefillIdentifier});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (widget.prefillIdentifier != null) {
        auth.fillIdentifier(widget.prefillIdentifier!);
      } else {
        auth.initLoginpage(skip: widget.prefillIdentifier == null);
      }
    });
  }

  final _identifierFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  Future<void> _continue(AuthController auth) async {
    if (auth.loading || !(_identifierFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await auth.continueWithIdentifier();
  }

  Future<void> _submit(AuthController auth) async {
    if (auth.loading || !(_passwordFormKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await auth.login();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        // Back from the password step returns to the identifier step.
        return PopScope(
          canPop: !auth.passwordStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !auth.loading) auth.backToIdentifier();
          },
          child: AuthScaffold(
            showBack: false,
            children: [
              AuthHeader(
                leading: LoginHeaderImage(loading: auth.loading),
                title: 'Нэвтрэх',
                subtitle: AuthSubtitle(
                  auth.passwordStep
                      ? 'Нууц үгээ оруулж нэвтэрнэ үү.'
                      : 'Үргэлжлүүлэхийн тулд бүртгэлээрээ нэвтэрнэ үү.',
                ),
              ),
              const SizedBox(height: 32),
              AuthStepSwitcher(
                child: auth.passwordStep ? _passwordStep(auth) : _identifierStep(auth),
              ),
              const SizedBox(height: 24),
              AuthPrompt(
                question: 'Бүртгэлгүй юу? ',
                action: 'Бүртгүүлэх',
                onTap: auth.loading ? null : () => goNamed('signup'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _identifierStep(AuthController auth) {
    return Form(
      key: _identifierFormKey,
      child: Column(
        key: const ValueKey('identifier-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthMethodSwitch(
            value: auth.method,
            onChanged: auth.loading ? null : auth.setMethod,
          ),
          const SizedBox(height: 20),
          AuthLabel(auth.method.fieldLabel),
          AuthIdentifierField(
            method: auth.method,
            controller: auth.identifierController,
            enabled: !auth.loading,
            onSubmitted: (_) => _continue(auth),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            text: 'Үргэлжлүүлэх',
            onTap: () => _continue(auth),
            loading: auth.loading,
          ),
        ],
      ),
    );
  }

  Widget _passwordStep(AuthController auth) {
    return Form(
      key: _passwordFormKey,
      child: AutofillGroup(
        child: Column(
          key: const ValueKey('password-step'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _identifierCard(auth),
            const SizedBox(height: 18),
            const AuthLabel('Нууц үг'),
            CustomTextField(
              controller: auth.pass,
              autofillHints: const [AutofillHints.password],
              hintText: '••••••••',
              obscureText: auth.hidePass,
              prefix: Icons.lock_outline_rounded,
              enabled: !auth.loading,
              // Only presence: strength rules apply at sign up, and
              // older accounts may predate them.
              validator: (v) => (v == null || v.isEmpty) ? 'Нууц үгээ оруулна уу' : null,
              onSubmitted: (_) => _submit(auth),
              suffixIcon: PasswordVisibilityButton(
                visible: !auth.hidePass,
                onTap: auth.loading ? null : auth.toggleHidePass,
              ),
            ),
            const SizedBox(height: 6),
            _rememberAndForgot(auth),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              text: 'Нэвтрэх',
              onTap: () => _submit(auth),
              loading: auth.loading,
            ),
          ],
        ),
      ),
    );
  }

  // The account step one confirmed, with a way back to pick another.
  Widget _identifierCard(AuthController auth) {
    return AuthInfoBox(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          Icon(auth.method.icon, size: 20, color: context.theme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              auth.identifier,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: grey600, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          AuthLink('Солих', onTap: auth.loading ? null : auth.backToIdentifier),
        ],
      ),
    );
  }

  Widget _rememberAndForgot(AuthController auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: auth.loading ? null : () => auth.setRemember(!auth.remember),
          child: Row(
            children: [
              Checkbox(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: BorderSide(color: grey400, width: 1.5),
                visualDensity: VisualDensity.compact,
                value: auth.remember,
                onChanged: auth.loading ? null : (val) => auth.setRemember(val!),
              ),
              Text(
                'Сануулах',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: auth.loading ? grey400 : grey600,
                ),
              ),
            ],
          ),
        ),
        AuthLink(
          'Нууц үг мартсан?',
          onTap: auth.loading
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  goto(ResetPassword(identifier: auth.identifier));
                },
        ),
      ],
    );
  }
}
