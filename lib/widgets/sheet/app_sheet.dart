import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

/// The app's bottom sheet: a handle, a title with a close button, a body
/// that scrolls once it outgrows 90% of the screen, and an optional
/// [footer] pinned under it (typically the sheet's main button). Keeps
/// clear of the keyboard and the home indicator.
class AppSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;

  /// Disables the close button, e.g. while the sheet is saving.
  final bool closable;

  const AppSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.footer,
    this.closable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.height * .9),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(color: grey300, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: grey500),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: closable ? () => Navigator.pop(context) : null,
                    style: IconButton.styleFrom(backgroundColor: grey100),
                    icon: Icon(Icons.close_rounded, size: 20, color: grey600),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// The main button of an [AppSheet]: full width, a spinner while [busy].
class SheetButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  final Color? color;

  const SheetButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.busy = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color ?? primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: context.theme.textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                if (icon != null) Icon(icon, size: 20),
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );
  }
}

/// A small bold caption over a group of controls in an [AppSheet].
class SheetLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const SheetLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text,
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
          ),
          const Spacer(),
          if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 12, color: grey500)),
        ],
      ),
    );
  }
}

/// A grey hint box with an icon, for notes and inline empty states.
class SheetNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const SheetNote(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: grey50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(icon, size: 18, color: grey500),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.5, height: 1.4, color: grey600)),
          ),
        ],
      ),
    );
  }
}

/// A filled, borderless text field for sheets.
class SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool autofocus;
  final String? suffixText;

  const SheetField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: 1,
      autofocus: autofocus,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: grey400, fontSize: 15),
        suffixText: suffixText,
        filled: true,
        fillColor: grey100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
