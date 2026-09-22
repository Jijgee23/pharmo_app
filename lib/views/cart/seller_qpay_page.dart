import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final primary = Theme.of(context).colorScheme.primary;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Урьдчилгаа төлбөр',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Захиалга #${widget.orderNo}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(data: _invoice.qrTxt, size: 200),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoTile('Дүн', toPrice(widget.totalPrice.toString())),
                          _infoTile('Тоо ширхэг', widget.totalCount.toInt().toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_invoice.urls.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _invoice.urls.map((url) => _BankButton(url: url)).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _check,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Төлбөр шалгах'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('QR дахин үүсгэх'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _busy ? null : _skip,
                  child: const Text('Урьдчилгаагүйгээр үргэлжлүүлэх'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _BankButton extends StatelessWidget {
  final BankUrl url;
  const _BankButton({required this.url});

  Future<void> _launch() async {
    final uri = Uri.parse(url.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messageWarning('${url.description} апп олдсонгүй.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launch,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(image: NetworkImage(url.logo), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              url.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
