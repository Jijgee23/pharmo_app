import 'package:pharmo_app/application/application.dart';

/// Floats over a list while orders are selected: how many and what they
/// come to, a way to drop the selection, and [actionLabel] to go on with
/// them. Slides away once [count] is 0, still reading what it last did
/// rather than "0".
class SelectionBar extends StatefulWidget {
  final int count;
  final double total;
  final VoidCallback onClear;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const SelectionBar({
    super.key,
    required this.count,
    required this.total,
    required this.onClear,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  State<SelectionBar> createState() => _SelectionBarState();
}

class _SelectionBarState extends State<SelectionBar> {
  late int _count = widget.count;
  late double _total = widget.total;

  @override
  Widget build(BuildContext context) {
    final visible = widget.count > 0;
    if (visible) {
      _count = widget.count;
      _total = widget.total;
    }
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: Durations.medium2,
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 1.6),
        child: AnimatedOpacity(
          duration: Durations.medium1,
          opacity: visible ? 1 : 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onClear,
                  tooltip: 'Сонголт цуцлах',
                  style: IconButton.styleFrom(backgroundColor: white.withValues(alpha: 0.1)),
                  icon: const Icon(Icons.close_rounded, color: white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_count захиалга',
                        style: const TextStyle(
                          color: white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        toPrice(_total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: white.withValues(alpha: 0.65), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: widget.onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: context.theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: Icon(widget.actionIcon, size: 18),
                  label: Text(widget.actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
