import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/config/app_configs.dart';
import 'package:pharmo_app/application/function/utilities/a_utils.dart';

class DialogButton extends StatelessWidget {
  final String title;
  final Color? bColor;
  final Color? tColor;
  final Function()? onTap;

  const DialogButton({
    super.key,
    required this.title,
    this.bColor,
    this.tColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = bColor ?? const Color(0xFF00897B);
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: onTap ?? () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: tColor ?? Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(title),
      ),
    );
  }
}

void myDialog({required List<Widget> children, String? title}) {
  Get.defaultDialog(
    title: title ?? '',
    titleStyle:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A2B2B)),
    backgroundColor: Colors.white,
    radius: 20,
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(spacing: 10, children: children),
      ),
    ),
    contentPadding: const EdgeInsets.all(20),
  );
}

Future<bool> confirmDialog({
  String title = 'Итгэлтэй байна уу?',
  String message = '',
  String? attentionText,
  TextAlign messageAlign = TextAlign.center,
  TextStyle? messageStyle,
  Widget? content,
}) async {
  final context = Get.context ?? GlobalKeys.navigatorKey.currentContext;
  if (context == null) return false;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => _GlassConfirmDialog(
      title: title,
      message: message,
      attentionText: attentionText,
      messageAlign: messageAlign,
      messageStyle: messageStyle,
      content: content,
    ),
  );
  return result ?? false;
}

// ---------------------------------------------------------------------------
// Glass confirmation dialog
// ---------------------------------------------------------------------------

class _GlassConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? attentionText;
  final TextAlign messageAlign;
  final TextStyle? messageStyle;
  final Widget? content;

  const _GlassConfirmDialog({
    required this.title,
    required this.message,
    this.attentionText,
    required this.messageAlign,
    this.messageStyle,
    this.content,
  });

  @override
  State<_GlassConfirmDialog> createState() => _GlassConfirmDialogState();
}

class _GlassConfirmDialogState extends State<_GlassConfirmDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: Material(
            color: transperant,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xF0FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              size: 28,
                              color: Color(0xFF00897B),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B2B),
                              letterSpacing: -0.2,
                            ),
                          ),

                          // Message
                          if (widget.message.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.message,
                              textAlign: widget.messageAlign,
                              style: widget.messageStyle ??
                                  const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF4A6361),
                                    height: 1.5,
                                  ),
                            ),
                          ],

                          // Attention
                          if (widget.attentionText != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF5350).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFEF5350).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                widget.attentionText!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF5350),
                                ),
                              ),
                            ),
                          ],

                          // Extra content
                          if (widget.content != null) ...[
                            const SizedBox(height: 12),
                            widget.content!,
                          ],

                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: const Text(
                                      'Үгүй',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4A6361),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00897B),
                                          Color(0xFF00796B),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00897B).withOpacity(0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Тийм',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
