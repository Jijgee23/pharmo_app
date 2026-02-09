import 'package:pharmo_app/application/application.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  final bool? obscureText;
  final bool? isPassword;
  final bool enabled;
  final bool filled;
  final IconButton? suffixIcon;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final TextAlign? align;
  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final Function(String?)? onChangedDelayed;
  final Function(String?)? onSubmitted;
  final Function()? onComplete;
  final int? maxLine;
  final IconData? prefix;
  final Duration debounceDuration;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.obscureText,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.onChangedDelayed,
    this.onSubmitted,
    this.isPassword,
    this.autofillHints,
    this.focusNode,
    this.onComplete,
    this.align,
    this.maxLine,
    this.prefix,
    this.enabled = true,
    this.filled = false,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Timer? _debounceTimer;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onChanged(String? value) {
    widget.onChanged?.call(value);

    if (widget.onChangedDelayed != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onChangedDelayed?.call(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(mediumFontSize);

    final defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: grey400, width: 1),
      borderRadius: borderRadius,
    );

    final focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: primary, width: 1.5),
      borderRadius: borderRadius,
    );

    final errorBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1),
      borderRadius: borderRadius,
    );

    final disabledBorder = OutlineInputBorder(
      borderSide: BorderSide(color: grey300, width: 1),
      borderRadius: borderRadius,
    );

    final TextStyle textStyle = TextStyle(
      color: widget.enabled ? grey600 : grey400,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );

    final TextStyle hintStyle = TextStyle(
      color: grey400,
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: _isFocused && widget.enabled
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        textAlign: widget.align ?? TextAlign.start,
        style: textStyle,
        onChanged: _onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onEditingComplete: widget.onComplete,
        autofillHints: widget.autofillHints,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        focusNode: _focusNode,
        enabled: widget.enabled,
        cursorWidth: 1.5,
        cursorColor: primary,
        maxLines: widget.maxLine ?? 1,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelText: widget.labelText,
          labelStyle: textStyle.copyWith(color: grey500),
          floatingLabelStyle: TextStyle(
            color: _isFocused ? primary : grey500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: widget.prefix != null
              ? Icon(
                  widget.prefix,
                  color: _isFocused ? primary : grey500,
                  size: 20,
                )
              : null,
          hintText: widget.hintText,
          hintStyle: hintStyle,
          filled: widget.filled,
          fillColor: widget.enabled ? grey100 : grey200,
          border: defaultBorder,
          enabledBorder: defaultBorder,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          disabledBorder: disabledBorder,
          suffixIcon: widget.suffixIcon,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        obscureText: widget.obscureText ?? false,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: widget.validator as String? Function(String?)?,
      ),
    );
  }
}
