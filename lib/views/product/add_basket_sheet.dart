import 'package:pharmo_app/application/application.dart';

class PopSheet extends StatelessWidget {
  const PopSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade700,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Image.asset(
          'assets/cross-small.png',
          height: 16,
          color: Colors.black.withOpacity(.5),
        ),
      ),
    );
  }
}

/// Бараа сагслах алхамтай sheet:
///   1. Тоо ширхэг оруулах
///   2. (S, D, VS) Захиалгын дараах үлдэгдэл [Product.minQty]-ээс бага болох
///      бол баталгаажуулах
/// Баталгаажсаны дараа API дуудаж sheet-ээ хаана.
class AddBasketSheet extends StatefulWidget {
  final Product product;

  /// Амжилттай сагсалж sheet хаагдсаны дараа дуудагдана.
  final VoidCallback? onAdded;

  const AddBasketSheet({super.key, required this.product, this.onAdded});

  @override
  State<AddBasketSheet> createState() => _AddBasketSheetState();
}

class _AddBasketSheetState extends State<AddBasketSheet> {
  int _step = 0;
  double _qty = 0;

  bool get _checksMinQty {
    final security = Authenticator.security;
    if (security == null) return false;
    return security.isSaler || security.isDriver || security.isVanSales;
  }

  void _onQtySubmit(String value) {
    final qty = double.tryParse(value);
    if (qty == null) {
      message('Тоон утга оруулна уу!');
      return;
    }
    if (qty <= 0) {
      message('0 ба түүгээс бага байж болохгүй!');
      return;
    }
    _qty = qty;
    if (_checksMinQty && widget.product.dropsBelowMinQty(qty)) {
      setState(() => _step = 1);
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    await LoadingService.run(
      () => cart.addProduct(
        widget.product.id,
        widget.product.name ?? 'Бараа',
        _qty,
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
    widget.onAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _step == 0
          ? ChangeQtyPad(
              key: const ValueKey('qty'),
              title: 'Тоо хэмжээ оруулна уу',
              initValue: _qty > 0 ? _fmt(_qty) : '',
              cashOnly: widget.product.cashOnly,
              onSubmit: _onQtySubmit,
            )
          : _minQtyWarning(),
    );
  }

  Widget _minQtyWarning() {
    final product = widget.product;
    final remaining = product.stockQty - _qty;
    return Container(
      key: const ValueKey('warning'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Барааны үлдэгдэл доод үлдэгдэлээс бага хэмжээнд хүрэх гэж байна? Үргэлжлүүлэх үү?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                spacing: 6,
                children: [
                  _infoRow('Бараа', product.name ?? ''),
                  _infoRow('Одоогийн үлдэгдэл', _fmt(product.stockQty)),
                  _infoRow('Захиалах тоо', _fmt(_qty)),
                  _infoRow('Захиалгын дараах үлдэгдэл', _fmt(remaining), color: Colors.red),
                  _infoRow('Доод үлдэгдэл', _fmt(product.minQty)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Үгүй'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Тийм'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) => v.toString().replaceAll(RegExp(r'\.0$'), '');

  Widget _infoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
