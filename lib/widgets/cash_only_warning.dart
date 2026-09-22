import 'package:pharmo_app/application/application.dart';

/// Reusable "cash only" warning banner (icon + sentence). For the small
/// per-item pill tag used on product cards, see the inline styling in
/// product_widget.dart / product_detail_page.dart / cart_item.dart instead —
/// this is the fuller banner shown where there's room to explain why.
class CashOnlyWarning extends StatelessWidget {
  final String message;

  const CashOnlyWarning({
    super.key,
    this.message = 'Энэ бараа зөвхөн бэлнээр төлөгдөнө.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
