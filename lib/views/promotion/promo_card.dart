import 'package:pharmo_app/application/application.dart';

// Same card chrome as SectionCard (radius 15, black@0.04 shadow) so the
// promotion list reads like the rest of the app instead of its own style.
class PromoCard extends StatelessWidget {
  final Promotion promo;
  final VoidCallback onTap;

  const PromoCard({super.key, required this.promo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDescription = (promo.description ?? '').isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (promo.hasGift == true)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.card_giftcard_rounded, color: primary, size: 18),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.name ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: 4),
                    Text(
                      promo.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
