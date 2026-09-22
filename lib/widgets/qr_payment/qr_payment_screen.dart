import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmo_app/application/application.dart';

/// One action button below the primary "Төлбөр шалгах" action — e.g. the
/// seller/VS flow's "QR дахин үүсгэх" (retry) or "Урьдчилгаагүйгээр
/// үргэлжлүүлэх" (skip). Empty for the pharmacist flow, which only ever
/// checks payment on an existing draft.
class QrPaymentSecondaryAction {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const QrPaymentSecondaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = true,
  });
}

/// Shared presentational shell for both "pay by QPay" screens:
/// - lib/views/cart/qr_code.dart (pharmacist ci//cp/ flow — draft order,
///   back button allowed, only a "check payment" action)
/// - lib/views/cart/seller_qpay_page.dart (seller/VS seller/order/{id}/qpay/*
///   flow — order already exists, no back button, check + retry + skip)
///
/// Each screen keeps its own provider wiring and state (which invoice is
/// current, a busy flag, ...); this widget only renders it.
class QrPaymentScreen extends StatelessWidget {
  final String title;
  final String? orderLabel;
  final String qrText;
  final String priceLabel;
  final String? countLabel;
  final List<BankUrl> bankUrls;
  final bool canPop;
  final bool busy;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimary;
  final List<QrPaymentSecondaryAction> secondaryActions;

  const QrPaymentScreen({
    super.key,
    required this.title,
    this.orderLabel,
    required this.qrText,
    required this.priceLabel,
    this.countLabel,
    required this.bankUrls,
    required this.canPop,
    required this.onPrimary,
    this.busy = false,
    this.primaryLabel = 'Төлбөр шалгах',
    this.primaryIcon = Icons.check_circle_outline_rounded,
    this.secondaryActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final body = Scaffold(
      backgroundColor: const Color(0xFFF4F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: canPop,
        leading: canPop
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              )
            : null,
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
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
                    if (orderLabel != null) ...[
                      Text(
                        orderLabel!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                    QrImageView(data: qrText, size: 200),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoTile('Дүн', priceLabel),
                        if (countLabel != null) _infoTile('Тоо ширхэг', countLabel!),
                      ],
                    ),
                  ],
                ),
              ),
              if (bankUrls.isNotEmpty) ...[
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
                    children: bankUrls.map((url) => _BankButton(url: url)).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : onPrimary,
                  icon: Icon(primaryIcon),
                  label: Text(primaryLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              for (final action in secondaryActions) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: action.outlined
                      ? OutlinedButton.icon(
                          onPressed: busy ? null : action.onTap,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: busy ? null : action.onTap,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return canPop ? body : PopScope(canPop: false, child: body);
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
