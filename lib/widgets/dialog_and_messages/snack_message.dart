import 'package:flutter/material.dart';
import 'package:pharmo_app/application/function/utilities/a_utils.dart';

String? _lastMessage;

enum MessageType { warning, complete, error, none }

// ---------------------------------------------------------------------------
// Public helpers – single entry point, zero duplication
// ---------------------------------------------------------------------------

void _showMessage(String aMessage, MessageType type) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(seconds: 3), () {
    _lastMessage = null;
  });
  ToastService.show(aMessage, type: type);
}

void message(String aMessage) => _showMessage(aMessage, MessageType.none);

void messageError(String aMessage) => _showMessage(aMessage, MessageType.error);

void messageComplete(String aMessage) =>
    _showMessage(aMessage, MessageType.complete);

void messageWarning(String aMessage) =>
    _showMessage(aMessage, MessageType.warning);

// ---------------------------------------------------------------------------
// ToastService – overlay lifecycle
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

    // Replace any currently visible toast instead of silently dropping it
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
// Animated toast widget
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

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    await _controller.reverse();
    if (mounted) widget.onRemove();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    switch (widget.type) {
      case MessageType.error:
        bgColor = Colors.red.shade700;
        icon = Icons.error_rounded;
        break;
      case MessageType.warning:
        bgColor = Colors.deepOrange.shade800;
        icon = Icons.warning_rounded;
        break;
      case MessageType.complete:
        bgColor = Colors.green.shade700;
        icon = Icons.check_circle_rounded;
        break;
      default:
        bgColor = Colors.blueGrey.shade800;
        icon = Icons.info_rounded;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GestureDetector(
              onTap: _dismiss,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, color: white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.3,
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
    );
  }
}
