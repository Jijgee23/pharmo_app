import 'package:pharmo_app/application/application.dart';

/// A single visit entry within the current visiting session — shown on
/// [RepHome] (today's active session) and on the [Visits] history screen.
/// Mirrors the white/bordered/shadowed card shell used across the app
/// (OrderSummaryCard, DeliverySummaryCard) instead of a flat tinted box.
class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback onEdit;

  const VisitCard({super.key, required this.visit, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final rep = context.read<RepProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    visit.note,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: black),
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                _VisitStatusChip(visit: visit),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: IconedText(
                        icon: Icons.calendar_today_outlined,
                        text: formatDate(visit.createdAt),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: primary,
                      visualDensity: VisualDensity.compact,
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
                        icon: Icons.login_rounded,
                        onTap: () async => await rep.comedVisit(visit.id),
                      ),
                    ),
                    Expanded(
                      child: _ActionButton(
                        label: 'Явсан',
                        icon: Icons.logout_rounded,
                        onTap: () async => await rep.leftVisit(visit.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Robust against both "2026-06-18T09:00:00" (ISO, per the real API docs)
/// and any legacy "2026-06-18 09:00:00" shape — a blind substring(0, 10)
/// happens to work for both, but parsing is what actually guarantees it.
String formatDate(String raw) {
  try {
    final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }
}

String formatTime(String raw) {
  try {
    final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw;
  }
}

class _VisitStatusChip extends StatelessWidget {
  final Visit visit;
  const _VisitStatusChip({required this.visit});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    if (visit.leftOn != null) {
      label = 'Явсан';
      color = Colors.green;
    } else if (visit.visitedOn != null) {
      label = 'Ирсэн';
      color = Colors.orange;
    } else {
      label = 'Төлөвлөсөн';
      color = Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
