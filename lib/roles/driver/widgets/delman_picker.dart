import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

/// The deliverymen [delmen] to pick one from, [selectedId] marked; a search
/// box once there are more than a handful.
class DelmanPicker extends StatefulWidget {
  final List<Delman> delmen;
  final int? selectedId;
  final ValueChanged<Delman> onSelected;

  const DelmanPicker({
    super.key,
    required this.delmen,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<DelmanPicker> createState() => _DelmanPickerState();
}

class _DelmanPickerState extends State<DelmanPicker> {
  // The list gets a search box past this many deliverymen.
  static const _searchFrom = 6;

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final delmen = widget.delmen;
    if (delmen.isEmpty) return const SheetNote(Icons.person_off_outlined, 'Өөр түгээгч алга.');
    final text = _query.trim().toLowerCase();
    final shown =
        text.isEmpty ? delmen : delmen.where((d) => d.name.toLowerCase().contains(text)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (delmen.length > _searchFrom) ...[
          _searchField(),
          const SizedBox(height: 10),
        ],
        if (shown.isEmpty)
          SheetNote(Icons.search_off_rounded, '"${_query.trim()}" нэртэй түгээгч алга.')
        else
          for (final d in shown)
            _DelmanTile(
              delman: d,
              selected: d.id == widget.selectedId,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onSelected(d);
              },
            ),
      ],
    );
  }

  Widget _searchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Түгээгч хайх',
        hintStyle: TextStyle(color: grey400, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: grey500, size: 20),
        isDense: true,
        filled: true,
        fillColor: grey100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _DelmanTile extends StatelessWidget {
  final Delman delman;
  final bool selected;
  final VoidCallback onTap;

  const _DelmanTile({required this.delman, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = delman.name.trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Durations.short4,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? primary.withValues(alpha: 0.08) : grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? primary : Colors.transparent, width: 1.6),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: selected ? primary : primary.withValues(alpha: 0.12),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? white : primary.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name.isEmpty ? 'Нэргүй' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Durations.short4,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? primary : Colors.transparent,
                    border: Border.all(color: selected ? primary : grey400, width: 2),
                  ),
                  child: selected ? const Icon(Icons.check_rounded, size: 14, color: white) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
