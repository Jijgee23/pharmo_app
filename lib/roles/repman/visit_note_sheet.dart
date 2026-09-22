import 'package:pharmo_app/application/application.dart';

/// Add/edit-visit bottom sheet — matches the modern scrollable sheet shape
/// used elsewhere (OrderSheet._showBranchMenu, ReadyOrders.addSheet):
/// rounded-top white sheet, drag handle, Scrollbar+SingleChildScrollView
/// (mainAxisSize.min so it only grows as tall as its content, up to the
/// maxHeight cap) with bottom padding that tracks the keyboard inset so the
/// note field and Save button stay reachable while typing.
Future<void> showVisitNoteSheet(
  BuildContext context, {
  required RepProvider rep,
  Visit? visit,
}) {
  return Get.bottomSheet(
    _VisitNoteSheet(rep: rep, visit: visit),
    isScrollControlled: true,
  );
}

class _VisitNoteSheet extends StatefulWidget {
  final RepProvider rep;
  final Visit? visit;

  const _VisitNoteSheet({required this.rep, this.visit});

  @override
  State<_VisitNoteSheet> createState() => _VisitNoteSheetState();
}

class _VisitNoteSheetState extends State<_VisitNoteSheet> {
  late final _noteController = TextEditingController(text: widget.visit?.note ?? '');
  bool _saving = false;

  bool get _isEditing => widget.visit != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      messageWarning('Тайлбар оруулна уу!');
      return;
    }
    setState(() => _saving = true);
    if (_isEditing) {
      await widget.rep.editVisit(widget.visit!.id, note);
    } else {
      await widget.rep.addVisit(note);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await confirmDialog(title: 'Уулзалт устгах уу?');
    if (!confirmed) return;
    await widget.rep.deleteVisit(widget.visit!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .8),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + keyboardInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Уулзалт засах' : 'Уулзалт бүртгэх',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (_isEditing)
                      IconButton(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Устгах',
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const BottomSheetLabelBuilder('Тайлбар'),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _noteController,
                  hintText: 'Уулзалтын тайлбар бичнэ үү',
                  filled: true,
                  maxLine: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isEditing ? 'Хадгалах' : 'Бүртгэх',
                    enabled: !_saving,
                    ontap: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
