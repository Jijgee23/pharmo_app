import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pharmo_app/application/application.dart';

class CartItem extends StatefulWidget {
  final Map<String, dynamic> detail;
  final String type;
  const CartItem({super.key, required this.detail, this.type = "cart"});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  Future<void> removeBasketItem() async {
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Барааг сагснаас хасах уу?',
    );
    if (!confirmed) return;
    final basket = context.read<BasketProvider>();
    await basket.removeBasketItem(itemId: widget.detail['id']);
  }

  Future changeBasketItem(int productId, double qty) async {
    try {
      LoadingService.show();
      final basket = context.read<BasketProvider>();
      await basket.addProduct(productId, widget.detail['name'], qty);
    } catch (e) {
      messageError('Алдаа гарлаа');
    } finally {
      LoadingService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => removeBasketItem(),
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              icon: Icons.delete_outline,
              label: 'Устгах',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Барааны нэр
                  Expanded(
                    child: Text(
                      widget.detail['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Тоо ширхэг засварлагч
                  _buildQtyStepper(),
                ],
              ),
              const Divider(height: 20, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priceInfo('Нэгж үнэ:', toPrice(widget.detail['price'])),
                  _priceInfo('Нийт:',
                      toPrice(widget.detail['qty'] * widget.detail['price']),
                      isTotal: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyStepper() {
    final qty = parseDouble(widget.detail['qty']);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(Icons.remove,
              () => changeBasketItem(widget.detail['product_id'], qty - 1)),
          GestureDetector(
            onTap: () => Get.bottomSheet(
              ChangeQtyPad(
                initValue: qty.toString(),
                onSubmit: (v) => _updateQtyFromPad(v),
              ),
              isScrollControlled: true,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                qty.toString().replaceAll('.0', ''),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: primary),
              ),
            ),
          ),
          _stepBtn(Icons.add,
              () => changeBasketItem(widget.detail['product_id'], qty + 1)),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _priceInfo(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment:
          isTotal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        Text(
          '$value ₮',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            fontSize: isTotal ? 15 : 13,
            color: isTotal ? primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _updateQtyFromPad(String val) async {
    double newQty = parseDouble(val);
    if (newQty <= 0) {
      messageWarning('0-ээс их утга оруулна уу');
      return;
    }
    Get.back();
    await changeBasketItem(widget.detail['product_id'], newQty);
  }
}

class ChangeQtyPad extends StatelessWidget {
  final String initValue;
  final String? title;
  final Function(String) onSubmit;

  const ChangeQtyPad({
    super.key,
    required this.initValue,
    required this.onSubmit,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final basket = context.read<BasketProvider>();
    Future.delayed(Duration.zero, () => basket.setQTYvalue(initValue));

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title ?? 'Тоо ширхэг өөрчлөх',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),

            // 2. Display
            Consumer<BasketProvider>(
              builder: (context, b, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: Text(
                  b.qty.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 3. Numpad - GridView-ийг Expanded дотор багтааж харуулна
            Expanded(
              // height: context.heigh * .4,
              child: GridView.count(
                physics:
                    const BouncingScrollPhysics(), // Хэрэв дэлгэц жижиг бол дотроо scroll хийнэ
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio:
                    2, // Өндрийг бага зэрэг нэмсэн (1.8-аас 1.6 болгож)
                children: [
                  ...List.generate(
                      9, (index) => _numBtn(context, (index + 1).toString())),
                  _numBtn(context, '0'),
                  _numBtn(context, '00'),
                  _numBtn(context, '000'),
                  _actionBtn(Icons.backspace_outlined, () => basket.clear(),
                      Colors.orange),
                  _numBtn(context, '.', isSpecial: true),
                  _actionBtn(
                    Icons.check,
                    () => onSubmit(basket.qty.text),
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numBtn(BuildContext context, String txt, {bool isSpecial = false}) {
    return InkWell(
      onTap: () => context.read<BasketProvider>().write(txt),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSpecial ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          txt,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class LoadingService {
  static OverlayEntry? _entry;
  static Future<T> run<T>(Future<T> Function() runner) async {
    show();
    try {
      return await runner();
    } catch (e) {
      rethrow;
    } finally {
      hide();
    }
  }

  static void show() {
    if (_entry != null) return;
    final state = GlobalKeys.navigatorKey.currentState;
    if (state == null) return;
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: const [
          ModalBarrier(dismissible: false, color: Colors.black38),
          Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ],
      ),
    );

    if (state.overlay == null) return;

    state.overlay!.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
