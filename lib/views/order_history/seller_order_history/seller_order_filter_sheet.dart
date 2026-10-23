import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/order_history/seller_order_history/seller_order_filter.dart';
import 'package:pharmo_app/widgets/filter/filter_widgets.dart';

/// Edits [current] in a bottom sheet; the new filter, or null when closed
/// without applying.
Future<SellerOrderFilter?> showSellerOrderFilterSheet(SellerOrderFilter current) {
  return Get.bottomSheet<SellerOrderFilter>(
    SellerOrderFilterSheet(initial: current),
    isScrollControlled: true,
  );
}

class SellerOrderFilterSheet extends StatefulWidget {
  final SellerOrderFilter initial;
  const SellerOrderFilterSheet({super.key, required this.initial});

  @override
  State<SellerOrderFilterSheet> createState() => _SellerOrderFilterSheetState();
}

class _SellerOrderFilterSheetState extends State<SellerOrderFilterSheet> {
  late SellerOrderFilter draft = widget.initial;
  late final minTotal = TextEditingController(text: widget.initial.minTotal?.toString());
  late final maxTotal = TextEditingController(text: widget.initial.maxTotal?.toString());
  late final minCount = TextEditingController(text: widget.initial.minCount?.toString());
  late final maxCount = TextEditingController(text: widget.initial.maxCount?.toString());

  List<TextEditingController> get _rangeFields => [minTotal, maxTotal, minCount, maxCount];

  @override
  void dispose() {
    for (final c in _rangeFields) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(SellerOrderFilter next) => setState(() => draft = next);

  void _reset() {
    _set(draft.cleared());
    for (final c in _rangeFields) {
      c.clear();
    }
  }

  void _apply() {
    int? read(TextEditingController c) => int.tryParse(c.text.trim());
    final (lowTotal, highTotal) = (read(minTotal), read(maxTotal));
    final (lowCount, highCount) = (read(minCount), read(maxCount));
    if (lowTotal != null && highTotal != null && lowTotal > highTotal) {
      messageWarning('Доод дүн дээд дүнгээс их байна');
      return;
    }
    if (lowCount != null && highCount != null && lowCount > highCount) {
      messageWarning('Барааны доод тоо дээд тооноос их байна');
      return;
    }
    Navigator.pop(
      context,
      draft.copyWith(
        minTotal: lowTotal,
        maxTotal: highTotal,
        minCount: lowCount,
        maxCount: highCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilterSheet(
      onReset: _reset,
      onApply: _apply,
      children: [
        FilterSection(
          title: 'Огноо',
          icon: Icons.calendar_month_rounded,
          children: [
            DateRangeChoices(
              value: draft.dates,
              onChanged: (range) => _set(draft.copyWith(dates: range)),
            ),
          ],
        ),
        FilterSection(title: 'Төлөв', icon: Icons.flag_outlined, children: [
          FilterChoice('Бүгд', draft.status == null, () => _set(draft.copyWith(status: null))),
          for (final s in OrderStatus.values)
            if (s != OrderStatus.all && s != OrderStatus.unknown)
              FilterChoice(
                s.name,
                draft.status == s,
                () => _set(draft.copyWith(status: s)),
                color: s.color,
              ),
        ]),
        FilterSection(title: 'Явц', icon: Icons.timeline_rounded, children: [
          FilterChoice('Бүгд', draft.process == null, () => _set(draft.copyWith(process: null))),
          for (final p in OrderProcess.values)
            if (p != OrderProcess.all && p != OrderProcess.unknown)
              FilterChoice(
                p.name,
                draft.process == p,
                () => _set(draft.copyWith(process: p)),
                color: p.color,
              ),
        ]),
        FilterSection(title: 'Төлбөрийн хэлбэр', icon: Icons.payments_outlined, children: [
          FilterChoice('Бүгд', draft.payType == null, () => _set(draft.copyWith(payType: null))),
          for (final t in paymentMethods)
            FilterChoice(
              t.name,
              draft.payType == t,
              () => _set(draft.copyWith(payType: t)),
              color: t.color,
            ),
        ]),
        FilterSection(title: 'QPay', icon: Icons.qr_code_2_rounded, children: [
          FilterChoice('Бүгд', draft.qpay == null, () => _set(draft.copyWith(qpay: null))),
          FilterChoice(
              'QPay-ээр төлсөн', draft.qpay == true, () => _set(draft.copyWith(qpay: true))),
          FilterChoice(
            'QPay-ээр төлөөгүй',
            draft.qpay == false,
            () => _set(draft.copyWith(qpay: false)),
          ),
        ]),
        FilterSection(
          title: 'Захиалгын дүн (₮)',
          icon: Icons.price_change_outlined,
          children: [_rangeRow(minTotal, maxTotal)],
        ),
        FilterSection(
          title: 'Барааны тоо',
          icon: Icons.inventory_2_outlined,
          children: [_rangeRow(minCount, maxCount)],
        ),
      ],
    );
  }

  Widget _rangeRow(TextEditingController low, TextEditingController high) {
    return Row(
      children: [
        Expanded(child: _numberField(low, 'Доод')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('—', style: TextStyle(color: grey500)),
        ),
        Expanded(child: _numberField(high, 'Дээд')),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: grey400, fontSize: 14),
        isDense: true,
        filled: true,
        fillColor: grey100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: context.theme.primaryColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
