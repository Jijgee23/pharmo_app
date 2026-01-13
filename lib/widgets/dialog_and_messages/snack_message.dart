import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/a_utils.dart';

String? _lastMessage;

enum MessageType { warning, complete, error, none }

void message(String aMessage) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(milliseconds: 3000), () {
    _lastMessage = null;
  });

  ToastService.show(aMessage, type: MessageType.none);
}

void messageError(String aMessage) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(milliseconds: 3000), () {
    _lastMessage = null;
  });

  ToastService.show(aMessage, type: MessageType.error);
}

void messageComplete(String aMessage) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(milliseconds: 3000), () {
    _lastMessage = null;
  });

  ToastService.show(aMessage, type: MessageType.complete);
}

void messageWarning(String aMessage) {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(milliseconds: 3000), () {
    _lastMessage = null;
  });

  ToastService.show(aMessage, type: MessageType.warning);
}

class ToastService {
  static OverlayEntry? _overlayEntry;

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 2),
    MessageType type = MessageType.none,
  }) async {
    if (_overlayEntry != null) return;

    final overlay = GlobalKeys.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, type: type),
    );

    overlay.insert(_overlayEntry!);

    await Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final MessageType type;
  const _ToastWidget({required this.message, this.type = MessageType.none});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.black;
    IconData iconData = Icons.check;
    switch (type) {
      case MessageType.error:
        backgroundColor = Colors.red.shade300;
        iconData = Icons.error;
        break;
      case MessageType.warning:
        backgroundColor = Colors.deepOrange.shade900;
        iconData = Icons.warning;
        break;
      case MessageType.complete:
        backgroundColor = Colors.teal;
        iconData = Icons.check;

        break;
      default:
        backgroundColor = Colors.black;
        iconData = Icons.check_circle;
    }
    return Positioned(
      top: 20,
      left: 24,
      right: 24,
      child: SafeArea(
        child: Material(
          color: transperant,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(iconData, color: white),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
