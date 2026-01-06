// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';

class ResponsiveDropdownButton extends StatefulWidget {
  final String initText;
  final List<dynamic> items;
  final Function() onTapItem;
  const ResponsiveDropdownButton(
      {super.key,
      required this.initText,
      required this.items,
      required this.onTapItem});

  @override
  _ResponsiveDropdownButtonState createState() =>
      _ResponsiveDropdownButtonState();
}

class _ResponsiveDropdownButtonState extends State<ResponsiveDropdownButton> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isDropdownVisible = false;

  void _toggleDropdown() {
    if (_isDropdownVisible) {
      _hideDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox buttonRenderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonRenderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + buttonSize.height,
          child: Material(
            elevation: 4.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: buttonSize.width,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.items.map(
                    (e) => ListTile(
                      title: Text(e.name),
                      onTap: widget.onTapItem,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownVisible = true;
    });
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownVisible = false;
    });
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _buttonKey,
      onTap: _toggleDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initText,
              style: const TextStyle(color: Colors.white),
            ),
            Icon(
              _isDropdownVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
