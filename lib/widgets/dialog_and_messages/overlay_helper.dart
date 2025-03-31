import 'package:flutter/material.dart';

class OverlayHelper {
  static final OverlayHelper _instance = OverlayHelper._internal();
  factory OverlayHelper() => _instance;

  OverlayHelper._internal();

  OverlayEntry? _overlayEntry;

  void showOverlay(BuildContext context,
      {required Widget child, required GlobalKey key}) {
    if (_overlayEntry != null) return; // Аль хэдийн байгаа бол давхардахгүй

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox
        .localToGlobal(Offset.zero); // Widget-ийн дэлгэцэн дээрх байрлал
    final size = renderBox.size; // Widget-ийн хэмжээ

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + size.height + 10, // InkWell-ийн доор байрлуулах
        left: position.dx,
        width: size.width, // Ингээд InkWell-ийн өргөнтэй тааруулна
        child: Material(
          color: Colors.transparent,
          shadowColor: Colors.black.withAlpha(50),
          elevation: 99,
          child: Row(
            spacing: 10,
            children: [
              child,
              Positioned(
                top: -30,
                right: 10,
                child: InkWell(
                  onTap: () => removeOverlay(),
                  child: Container(
                      padding: EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
