
import 'package:pharmo_app/application/application.dart';

class UserTag extends StatelessWidget {
  final bool isSupplier;
  final String name;
  const UserTag({super.key, required this.name, this.isSupplier = false});

  @override
  Widget build(BuildContext context) {
    IconData headerIcon =
        !isSupplier ? Icons.person_outline : Icons.home_work_outlined;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(headerIcon, color: primary, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}