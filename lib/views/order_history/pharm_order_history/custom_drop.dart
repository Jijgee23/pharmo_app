import 'package:pharmo_app/application/application.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String Function(T) getLabel;
  final void Function(T?)? onChanged;
  final String text;
  final void Function()? onRemove;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.getLabel,
    this.value,
    this.onChanged,
    required this.text,
    this.onRemove,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final MenuController _menuController = MenuController();
  bool _isOpen = false;

  bool get _isActive => widget.onRemove != null;

  void _toggle() {
    if (_isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorScheme.primary;

    return MenuAnchor(
      controller: _menuController,
      onOpen: () => setState(() => _isOpen = true),
      onClose: () => setState(() => _isOpen = false),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        elevation: WidgetStatePropertyAll(8),
        shadowColor: WidgetStatePropertyAll(Colors.black12),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
      ),
      menuChildren: widget.items.map((item) {
        final selected = widget.value == item;
        return MenuItemButton(
          onPressed: () {
            widget.onChanged?.call(item);
            _menuController.close();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              selected ? color.withOpacity(0.07) : Colors.transparent,
            ),
            padding: WidgetStatePropertyAll(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              SizedBox(
                width: 16,
                child: selected ? Icon(Icons.check_rounded, size: 15, color: color) : null,
              ),
              Text(
                widget.getLabel(item),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? color : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isActive
              ? color.withOpacity(0.08)
              : _isOpen
                  ? Colors.grey.shade100
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: _isActive ? color.withOpacity(0.5) : Colors.grey.shade300,
            width: _isActive ? 1.4 : 1.2,
          ),
          boxShadow: _isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
                  color: _isActive ? color : Colors.grey.shade700,
                  letterSpacing: 0.1,
                ),
              ),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: _isActive ? color : Colors.grey.shade500,
                ),
              ),
              if (_isActive) ...[
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
