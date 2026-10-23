import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

/// Records a payment the driver took from [customerName] ([customerId]).
Future<void> showCustomerPaymentSheet(int customerId, String customerName) => Get.bottomSheet(
      CustomerPaymentSheet(customerId: customerId, customerName: customerName),
      isScrollControlled: true,
    );

class CustomerPaymentSheet extends StatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerPaymentSheet({super.key, required this.customerId, required this.customerName});

  @override
  State<CustomerPaymentSheet> createState() => _CustomerPaymentSheetState();
}

class _CustomerPaymentSheetState extends State<CustomerPaymentSheet> {
  // A driver takes cash or a transfer; nothing is chosen for them.
  static const _types = [PayType.cash, PayType.transAccount];

  final _amount = TextEditingController();
  PayType? _type;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final type = _type;
    final amount = _amount.text.trim();
    if (type == null) {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if ((int.tryParse(amount) ?? 0) <= 0) {
      messageWarning('Дүн оруулна уу!');
      return;
    }
    setState(() => _saving = true);
    final added = await context
        .read<JaggerProvider>()
        .addCustomerPayment(type.value, amount, widget.customerId);
    if (!mounted) return;
    if (added) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Төлбөр бүртгэх',
      subtitle: widget.customerName,
      closable: !_saving,
      footer: SheetButton(
        label: 'Бүртгэх',
        icon: Icons.check_rounded,
        busy: _saving,
        onPressed: _save,
      ),
      children: [
        const SheetLabel('Төлбөрийн хэлбэр'),
        Row(
          spacing: 10,
          children: [
            for (final type in _types)
              Expanded(
                child: _TypeChoice(
                  type: type,
                  selected: _type == type,
                  onTap: () => setState(() => _type = type),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const SheetLabel('Дүн'),
        SheetField(
          controller: _amount,
          hint: '0',
          suffixText: '₮',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TypeChoice extends StatelessWidget {
  final PayType type;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChoice({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: Durations.short4,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : grey200, width: selected ? 1.6 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(
              type == PayType.cash ? Icons.payments_outlined : Icons.account_balance_outlined,
              size: 20,
              color: selected ? primary : grey600,
            ),
            Text(
              type.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? primary.shade700 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
