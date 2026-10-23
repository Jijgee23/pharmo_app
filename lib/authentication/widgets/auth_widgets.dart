import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:pharmo_app/application/application.dart';

/// Shared building blocks for the login / sign up / password screens.

/// Full-screen auth layout: soft primary-colored blobs behind a scrollable,
/// padded column, with an optional back button.
class AuthScaffold extends StatelessWidget {
  final List<Widget> children;
  final bool showBack;

  const AuthScaffold({super.key, required this.children, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _blob(primaryColor.withValues(alpha: 0.12), 280),
          ),
          Positioned(
            top: 60,
            left: -100,
            child: _blob(primaryColor.withValues(alpha: 0.06), 220),
          ),
          Positioned(
            bottom: -140,
            right: -60,
            child: _blob(primaryColor.withValues(alpha: 0.06), 240),
          ),
          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: ChevronBack(),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, showBack ? 8 : 40, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Rounded gradient tile holding an icon (cross-fades when [icon] changes) or
/// any [child].
class AuthIconTile extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final double size;

  const AuthIconTile({super.key, this.icon, this.child, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return Container(
      width: size,
      height: size,
      padding: child != null ? EdgeInsets.all(size * 0.18) : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: child ??
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(icon, key: ValueKey(icon), color: Colors.white, size: size * 0.5),
          ),
    );
  }
}

/// Big bold primary-colored screen title.
class AuthText extends StatelessWidget {
  final String text;
  final double fontSize;
  const AuthText(this.text, {super.key, this.fontSize = 30});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: context.theme.primaryColor,
      ),
    );
  }
}

/// Icon tile + title + subtitle stacked, used atop full-screen auth pages.
class AuthHeader extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget subtitle;

  const AuthHeader({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(height: 24),
        AuthText(title),
        const SizedBox(height: 8),
        subtitle,
      ],
    );
  }
}

/// Grey 14px body text used for header subtitles.
class AuthSubtitle extends StatelessWidget {
  final String text;

  /// Part of [text] rendered bold in the primary color (e.g. an email).
  final String? highlight;
  final double fontSize;

  const AuthSubtitle(this.text, {super.key, this.highlight, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: grey600, fontSize: fontSize, height: 1.4);
    final h = highlight;
    if (h == null || h.isEmpty || !text.contains(h)) {
      return Text(text, style: style);
    }
    final i = text.indexOf(h);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: h,
            style: TextStyle(
              color: context.theme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(i + h.length)),
        ],
      ),
    );
  }
}

/// Two-segment progress bar with a caption underneath.
class AuthStepIndicator extends StatelessWidget {
  final bool secondStep;
  final String firstLabel;
  final String secondLabel;

  const AuthStepIndicator({
    super.key,
    required this.secondStep,
    required this.firstLabel,
    required this.secondLabel,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    Widget bar(bool active) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 5,
            decoration: BoxDecoration(
              color: active ? primaryColor : grey300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [bar(true), const SizedBox(width: 8), bar(secondStep)]),
        const SizedBox(height: 8),
        Text(
          secondStep ? 'Алхам 2/2 · $secondLabel' : 'Алхам 1/2 · $firstLabel',
          style: TextStyle(color: grey500, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Fade + slight slide transition between wizard steps. Give each step's root
/// widget a distinct key.
class AuthStepSwitcher extends StatelessWidget {
  final Widget child;
  const AuthStepSwitcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Small bold caption above a field.
class AuthLabel extends StatelessWidget {
  final String text;
  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text,
        style: TextStyle(color: grey600, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// И-мейл / Утас switch choosing what an [AuthIdentifierField] takes.
/// Disabled when [onChanged] is null.
class AuthMethodSwitch extends StatelessWidget {
  final LoginMethod value;
  final ValueChanged<LoginMethod>? onChanged;

  const AuthMethodSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: grey100, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final method in LoginMethod.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onChanged == null ? null : () => onChanged!(method),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: method == value ? white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      if (method == value)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(method.icon, size: 18, color: method == value ? primaryColor : grey500),
                      const SizedBox(width: 6),
                      Text(
                        method.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: method == value ? primaryColor : grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// E-mail or 8-digit phone input, depending on [method].
class AuthIdentifierField extends StatelessWidget {
  final LoginMethod method;
  final TextEditingController controller;
  final bool enabled;
  final Function(String?)? onSubmitted;

  const AuthIdentifierField({
    super.key,
    required this.method,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = method == LoginMethod.email;
    return CustomTextField(
      // A fresh field per method, so an error shown for one isn't kept for the other.
      key: ValueKey(method),
      controller: controller,
      hintText: isEmail ? 'example@mail.com' : '99112233',
      prefix: method.icon,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
      autofillHints: [isEmail ? AutofillHints.email : AutofillHints.telephoneNumber],
      enabled: enabled,
      validator: method.validate,
      onSubmitted: onSubmitted,
    );
  }
}

/// Full-width primary button that shows a spinner and disables while [loading].
class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool loading;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      ontap: onTap,
      enabled: !loading,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
            )
          : null,
    );
  }
}

/// Soft primary-tinted rounded box.
class AuthInfoBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AuthInfoBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

/// Primary-colored bold tappable text, optionally with a leading icon.
class AuthLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  const AuthLink(this.text, {super.key, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? grey400 : context.theme.primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Question? Action" row inside an [AuthInfoBox].
class AuthPrompt extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const AuthPrompt({
    super.key,
    required this.question,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AuthInfoBox(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(question, style: TextStyle(color: grey600, fontSize: 13)),
          AuthLink(action, onTap: onTap),
        ],
      ),
    );
  }
}

/// Eye icon toggling password visibility.
class PasswordVisibilityButton extends StatelessWidget {
  final bool visible;
  final VoidCallback? onTap;

  const PasswordVisibilityButton({super.key, required this.visible, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: grey500,
        size: 20,
      ),
    );
  }
}

/// Bottom-sheet frame for an auth step: drag handle, an icon + title +
/// subtitle header with a close button, and a body that scrolls clear of
/// the keyboard.
class AuthSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const AuthSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.height * .9),
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: grey300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthIconTile(icon: icon, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthText(title, fontSize: 22),
                        const SizedBox(height: 4),
                        AuthSubtitle(subtitle, fontSize: 13),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: grey100),
                    icon: Icon(Icons.close_rounded, size: 20, color: grey600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// 6-digit OTP boxes plus a resend row with a [resendInterval]-second
/// countdown. The countdown starts on mount, since this widget is shown right
/// after a code was sent.
class OtpInput extends StatefulWidget {
  static const length = 6;

  final ValueChanged<String> onChanged;

  /// Sends a new code; returns true on success, which clears the boxes and
  /// restarts the countdown.
  final Future<bool> Function() onResend;
  final int resendInterval;

  const OtpInput({
    super.key,
    required this.onChanged,
    required this.onResend,
    this.resendInterval = 60,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final _controller = OtpFieldControllerV2();
  Timer? _timer;
  int _secondsLeft = 0;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = widget.resendInterval;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      final sent = await widget.onResend();
      if (!sent || !mounted) return;
      _controller.clear();
      widget.onChanged('');
      setState(_startTimer);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OTPTextFieldV2(
          controller: _controller,
          length: OtpInput.length,
          width: MediaQuery.of(context).size.width,
          textFieldAlignment: MainAxisAlignment.spaceBetween,
          fieldWidth: 46,
          fieldStyle: FieldStyle.box,
          outlineBorderRadius: 14,
          otpFieldStyle: OtpFieldStyle(
            borderColor: grey300,
            enabledBorderColor: grey300,
            focusBorderColor: primaryColor,
            backgroundColor: grey100,
          ),
          cursorColor: primaryColor,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          keyboardType: TextInputType.number,
          onChanged: widget.onChanged,
          onCompleted: widget.onChanged,
        ),
        const SizedBox(height: 14),
        _resendRow(primaryColor),
      ],
    );
  }

  Widget _resendRow(Color primaryColor) {
    final canResend = _secondsLeft <= 0;
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');
    return AuthInfoBox(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 18, color: grey500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              canResend ? 'Код ирээгүй юу?' : 'Дахин илгээх боломжтой:',
              style: TextStyle(color: grey600, fontSize: 13),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: canResend
                ? _resending
                    ? Padding(
                        key: const ValueKey('sending'),
                        padding: const EdgeInsets.all(6),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: primaryColor),
                        ),
                      )
                    : AuthLink(
                        'Дахин илгээх',
                        key: const ValueKey('resend'),
                        icon: Icons.refresh_rounded,
                        onTap: _resend,
                      )
                : Padding(
                    key: const ValueKey('countdown'),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            value: _secondsLeft / widget.resendInterval,
                            strokeWidth: 2.2,
                            color: primaryColor,
                            backgroundColor: grey300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$mm:$ss',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
