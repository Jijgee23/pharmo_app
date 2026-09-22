import 'package:pharmo_app/application/application.dart';

/// Shown when POST seller/order/ auto-attaches a QPay invoice to a
/// just-created seller/VS order (a cash-only group). The order already
/// exists (status W) - this screen only resolves how the advance payment
/// is handled: check it, re-issue an expired/failed QR, or skip it with a
/// reason. There is no "cancel", because there is nothing left to cancel.
class SellerQpayPage extends StatefulWidget {
  final int orderId;
  final String orderNo;
  final double totalPrice;
  final double totalCount;
  final SellerQpayInvoice invoice;

  const SellerQpayPage({
    super.key,
    required this.orderId,
    required this.orderNo,
    required this.totalPrice,
    required this.totalCount,
    required this.invoice,
  });

  @override
  State<SellerQpayPage> createState() => _SellerQpayPageState();
}

class _SellerQpayPageState extends State<SellerQpayPage> {
  late SellerQpayInvoice _invoice;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Future<void> _check() async {
    setState(() => _busy = true);
    final cart = context.read<CartProvider>();
    final paid = await cart.checkSellerQpayPayment(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (paid) {
      messageComplete('Төлбөр амжилттай төлөгдсөн.');
      await gotoRemoveUntil(OrderDone(orderNo: widget.orderNo));
    } else {
      messageWarning('Төлбөр төлөгдөөгүй байна.');
    }
  }

  Future<void> _retry() async {
    setState(() => _busy = true);
    final cart = context.read<CartProvider>();
    final invoice = await cart.createSellerQpayInvoice(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (invoice != null) {
      setState(() => _invoice = invoice);
      messageComplete('Шинэ QR код үүслээ.');
    }
  }

  Future<void> _skip() async {
    final reason = await _askSkipReason();
    if (reason == null || reason.trim().isEmpty) return;
    if (!mounted) return;
    setState(() => _busy = true);
    final cart = context.read<CartProvider>();
    final ok = await cart.skipSellerQpay(widget.orderId, reason.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      messageComplete('Урьдчилгаа төлбөргүйгээр үргэлжлүүлэв.');
      await gotoRemoveUntil(OrderDone(orderNo: widget.orderNo));
    }
  }

  Future<String?> _askSkipReason() {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Урьдчилгаа төлбөрийг алгасах'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Шалтгаанаа бичнэ үү...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Алгасах'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QrPaymentScreen(
      title: 'Урьдчилгаа төлбөр',
      orderLabel: 'Захиалга #${widget.orderNo}',
      qrText: _invoice.qrTxt,
      priceLabel: toPrice(widget.totalPrice.toString()),
      countLabel: widget.totalCount.toInt().toString(),
      bankUrls: _invoice.urls,
      canPop: false,
      busy: _busy,
      onPrimary: _check,
      secondaryActions: [
        QrPaymentSecondaryAction(
          label: 'QR дахин үүсгэх',
          icon: Icons.refresh_rounded,
          onTap: _retry,
        ),
        QrPaymentSecondaryAction(
          label: 'Урьдчилгаагүйгээр үргэлжлүүлэх',
          icon: Icons.skip_next_rounded,
          outlined: false,
          onTap: _skip,
        ),
      ],
    );
  }
}
