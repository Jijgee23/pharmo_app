import 'package:pharmo_app/application/application.dart';

/// A single visit entry within the current visiting session — shown on
/// [RepHome] (today's active session) and on the [Visits] history screen.
/// Extracted so both stay in sync instead of duplicating the card markup.
class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback onEdit;

  const VisitCard({super.key, required this.visit, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final rep = context.read<RepProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(70),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.note,
                      style: const TextStyle(color: black),
                      softWrap: true,
                    ),
                    Text(
                      visit.createdAt.length >= 10 ? visit.createdAt.substring(0, 10) : visit.createdAt,
                      style: TextStyle(color: grey600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
                color: Colors.green,
                tooltip: 'Засах',
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Ирсэн',
                  onTap: () async => await rep.comedVisit(visit.id),
                ),
              ),
              Expanded(
                child: _ActionButton(
                  label: 'Явсан',
                  onTap: () async => await rep.leftVisit(visit.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: white),
      ),
    );
  }
}
