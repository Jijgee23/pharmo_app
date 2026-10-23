import 'package:pharmo_app/application/application.dart';

/// Extra stops made on the way (POST delivery/addition/): a note and where
/// it was logged. Tapping one edits its note.
class AdditionalDeliveries extends StatelessWidget {
  final List<DeliveryItem> items;
  const AdditionalDeliveries({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.add_location_alt_outlined,
        title: 'Нэмэлт хүргэлт байхгүй',
        message: 'Замдаа хийсэн нэмэлт хүргэлтээ энд бүртгэнэ.',
        actionLabel: 'Нэмэлт хүргэлт бүртгэх',
        actionIcon: Icons.add_rounded,
        onAction: () => _showNoteSheet(),
      );
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 96 + bottom),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _NoteCard(item: items[i], index: i + 1),
        ),
        Positioned(
          right: 16,
          bottom: 16 + bottom,
          child: FloatingActionButton.extended(
            heroTag: 'ADDITIONAL_DELIVERY',
            onPressed: () => _showNoteSheet(),
            backgroundColor: primary,
            foregroundColor: white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Нэмэх'),
          ),
        ),
      ],
    );
  }
}

Future<void> _showNoteSheet([DeliveryItem? item]) =>
    Get.bottomSheet(_NoteSheet(item: item), isScrollControlled: true);

class _NoteCard extends StatelessWidget {
  final DeliveryItem item;
  final int index;
  const _NoteCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasNote = item.note.trim().isNotEmpty;
    return Material(
      color: white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _showNoteSheet(item),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: grey200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      hasNote ? item.note : 'Тайлбаргүй',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: hasNote ? Colors.grey.shade900 : grey500,
                        fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                    Text(
                      friendlyDateTime(item.visitedOn.toLocal()),
                      style: TextStyle(fontSize: 12.5, color: grey500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 20, color: grey400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logs a new extra stop at the current spot, or edits [item]'s note.
class _NoteSheet extends StatefulWidget {
  final DeliveryItem? item;
  const _NoteSheet({this.item});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _note = TextEditingController(text: widget.item?.note ?? '');
  bool _saving = false;

  bool get _editing => widget.item != null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = _note.text.trim();
    if (note.isEmpty) {
      messageWarning('Тайлбар оруулна уу!');
      return;
    }
    setState(() => _saving = true);
    final jagger = context.read<JaggerProvider>();
    final saved = _editing
        ? await jagger.editAdditionalDelivery(widget.item!.id, note)
        : await jagger.registerAdditionalDelivery(note);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return AppSheet(
      title: _editing ? 'Тайлбар засах' : 'Нэмэлт хүргэлт бүртгэх',
      subtitle: item == null
          ? 'Одоогийн байршил бүртгэгдэнэ'
          : 'Бүртгэсэн: ${friendlyDateTime(item.visitedOn.toLocal())}',
      closable: !_saving,
      footer: SheetButton(
        label: _editing ? 'Хадгалах' : 'Бүртгэх',
        icon: Icons.check_rounded,
        busy: _saving,
        onPressed: _save,
      ),
      children: [
        const SheetLabel('Тайлбар'),
        SheetField(
          controller: _note,
          hint: 'Юу хүргэсэн, хэнд…',
          maxLines: 4,
          autofocus: !_editing,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
