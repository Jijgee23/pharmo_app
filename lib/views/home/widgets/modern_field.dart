import 'package:flutter/material.dart';

class ModernField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmited;
  final String hint;
  final IconButton? suffixIcon;

  const ModernField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmited,
    this.hint = 'Хайх',
    this.suffixIcon,
  });

  @override
  State<ModernField> createState() => _ModernFieldState();
}

class _ModernFieldState extends State<ModernField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused ? primary.withOpacity(0.5) : Colors.grey.shade200,
            width: _focused ? 1.4 : 1.2,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: TextFormField(
          focusNode: _focus,
          controller: widget.controller,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: widget.onSubmited,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: _focused ? primary : Colors.grey.shade400,
            ),
            suffixIcon: widget.suffixIcon,
          ),
        ),
      ),
    );
  }
}
