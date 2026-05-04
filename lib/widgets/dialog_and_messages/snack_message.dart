import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pharmo_app/application/config/app_configs.dart';
import 'package:pharmo_app/application/function/utilities/a_utils.dart';

String? _lastMessage;

enum MessageType { warning, complete, error, none }

void _showMessage(String aMessage, MessageType type) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(seconds: 3), () => _lastMessage = null);
  ToastService.show(aMessage, type: type);
}

void message(String aMessage) => _showMessage(aMessage, MessageType.none);
void messageError(String aMessage) => _showMessage(aMessage, MessageType.error);
void messageComplete(String aMessage) => _showMessage(aMessage, MessageType.complete);
void messageWarning(String aMessage) => _showMessage(aMessage, MessageType.warning);

// ---------------------------------------------------------------------------
// ToastService
// ---------------------------------------------------------------------------

class ToastService {
  static OverlayEntry? _overlayEntry;

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 3),
    MessageType type = MessageType.none,
  }) {
    final overlay = GlobalKeys.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onRemove: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }
}

// ---------------------------------------------------------------------------
// Toast widget
// ---------------------------------------------------------------------------

class _ToastWidget extends StatefulWidget {
  final String message;
  final MessageType type;
  final Duration duration;
  final VoidCallback onRemove;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onRemove,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _progressController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fade = CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _enterController.forward();
    _progressController.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _progressController.stop();
    _enterController.duration = const Duration(milliseconds: 260);
    await _enterController.reverse();
    if (mounted) widget.onRemove();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (Color accent, IconData icon) = switch (widget.type) {
      MessageType.error => (const Color(0xFFEF5350), Icons.error_rounded),
      MessageType.warning => (const Color(0xFFFF9800), Icons.warning_amber_rounded),
      MessageType.complete => (const Color(0xFF26A69A), Icons.check_circle_rounded),
      MessageType.none => (const Color(0xFF78909C), Icons.info_rounded),
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Material(
          color: transperant,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xCC111827),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accent.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  children: [
                                    // Icon bubble
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(icon, color: accent, size: 18),
                                    ),
                                    // Message
                                    Expanded(
                                      child: Text(
                                        widget.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                    // Dismiss hint
                                    Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              // Progress bar
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (_, __) => ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                                  child: LinearProgressIndicator(
                                    value: 1.0 - _progressController.value,
                                    minHeight: 2.5,
                                    backgroundColor: Colors.white.withOpacity(0.06),
                                    valueColor: AlwaysStoppedAnimation(accent.withOpacity(0.7)),
                                  ),
                                ),
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
        ),
      ),
    );
  }
}
