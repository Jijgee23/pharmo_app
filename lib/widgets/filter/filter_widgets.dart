import 'package:pharmo_app/application/application.dart';

// Building blocks of the list filter screens (seller orders, delivery
// history): the bottom sheet, its sections and choices, date presets, and
// the row of active filters above a list.

/// The filter bottom sheet: a scrolling list of [FilterSection]s with
/// «Цэвэрлэх» and «Шүүх» underneath.
class FilterSheet extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterSheet({
    super.key,
    required this.children,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final label = context.theme.textTheme.labelLarge;
    return AppSheet(
      title: 'Шүүлтүүр',
      footer: Row(
        spacing: 12,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: label?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: const Text('Цэвэрлэх'),
            ),
          ),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: label?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: const Text('Шүүх'),
            ),
          ),
        ],
      ),
      children: children,
    );
  }
}

/// A titled group of choices (or any other controls) in a [FilterSheet].
class FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const FilterSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: grey600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

/// One selectable option in a [FilterSection], tinted with [color] (the
/// primary colour by default) when selected.
class FilterChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  const FilterChoice(
    this.label,
    this.selected,
    this.onTap, {
    super.key,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.theme.primaryColor;
    return Material(
      color: selected ? tint.withValues(alpha: 0.12) : grey100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? tint.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null || selected) ...[
                Icon(selected ? Icons.check_rounded : icon,
                    size: 16, color: selected ? tint : grey600),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? tint : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «2026.10.01 – 2026.10.21», or a single date for a one-day range.
String dateRangeLabel(DateTimeRange range) {
  String day(DateTime d) =>
      '${d.year}.${'${d.month}'.padLeft(2, '0')}.${'${d.day}'.padLeft(2, '0')}';
  final start = day(range.start);
  final end = day(range.end);
  return start == end ? start : '$start – $end';
}

/// The date choices of a [FilterSection]: all, a few common ranges, or one
/// picked on the calendar. Ranges are whole days.
class DateRangeChoices extends StatelessWidget {
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangeChoices({super.key, required this.value, required this.onChanged});

  static DateTime get _today => DateUtils.dateOnly(DateTime.now());

  static Map<String, DateTimeRange> get presets {
    final today = _today;
    final yesterday = today.subtract(const Duration(days: 1));
    final monthStart = DateTime(today.year, today.month);
    return {
      'Өнөөдөр': DateTimeRange(start: today, end: today),
      'Өчигдөр': DateTimeRange(start: yesterday, end: yesterday),
      'Сүүлийн 7 хоног': DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today),
      'Энэ сар': DateTimeRange(start: monthStart, end: today),
      'Өмнөх сар': DateTimeRange(
        start: DateTime(today.year, today.month - 1),
        end: monthStart.subtract(const Duration(days: 1)),
      ),
    };
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: _today,
      initialDateRange: value,
      helpText: 'Хугацаа сонгох',
      saveText: 'Сонгох',
    );
    if (picked == null) return;
    onChanged(DateTimeRange(
      start: DateUtils.dateOnly(picked.start),
      end: DateUtils.dateOnly(picked.end),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final all = presets;
    final custom = value != null && !all.containsValue(value);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChoice('Бүгд', value == null, () => onChanged(null)),
        for (final MapEntry(key: label, value: range) in all.entries)
          FilterChoice(label, value == range, () => onChanged(range)),
        FilterChoice(
          custom ? dateRangeLabel(value!) : 'Өөр хугацаа',
          custom,
          () => _pick(context),
          icon: Icons.edit_calendar_rounded,
        ),
      ],
    );
  }
}

/// The filters in use above a list, one removable chip each, then
/// «Бүгдийг цэвэрлэх». Nothing when there are none.
class ActiveFiltersRow extends StatelessWidget {
  final List<(String, VoidCallback)> chips;
  final VoidCallback onClearAll;

  const ActiveFiltersRow({super.key, required this.chips, required this.onClearAll});

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          for (final (label, onRemove) in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ActiveFilterChip(label: label, onRemove: onRemove),
            ),
          TextButton(onPressed: onClearAll, child: const Text('Бүгдийг цэвэрлэх')),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final tint = context.theme.primaryColor;
    return Material(
      color: tint.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: tint.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onRemove,
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: tint),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 16, color: tint),
            ],
          ),
        ),
      ),
    );
  }
}
