import 'package:pharmo_app/application/application.dart';

/// Picks a month between [first] and [last] (both inclusive) in a bottom
/// sheet; the month's first day, or null when closed without picking.
Future<DateTime?> showMonthPicker({
  required String title,
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) {
  return Get.bottomSheet<DateTime>(
    MonthPickerSheet(title: title, initial: initial, first: first, last: last),
    isScrollControlled: true,
  );
}

/// A year with arrows to page through it, over a 3×4 grid of its months.
class MonthPickerSheet extends StatefulWidget {
  final String title;
  final DateTime initial, first, last;

  const MonthPickerSheet({
    super.key,
    required this.title,
    required this.initial,
    required this.first,
    required this.last,
  });

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late int year = widget.initial.year;

  bool _enabled(DateTime month) =>
      !month.isBefore(DateTime(widget.first.year, widget.first.month)) &&
      !month.isAfter(DateTime(widget.last.year, widget.last.month));

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: widget.title,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: year > widget.first.year ? () => setState(() => year--) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '$year он',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            IconButton(
              onPressed: year < widget.last.year ? () => setState(() => year++) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
          children: [for (var m = 1; m <= 12; m++) _month(DateTime(year, m))],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _month(DateTime month) {
    final tint = context.theme.primaryColor;
    final enabled = _enabled(month);
    final selected = month.year == widget.initial.year && month.month == widget.initial.month;
    return Material(
      color: selected ? tint : grey100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? () => Navigator.pop(context, month) : null,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            '${month.month}-р сар',
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected
                  ? white
                  : enabled
                      ? Colors.grey.shade800
                      : grey400,
            ),
          ),
        ),
      ),
    );
  }
}
