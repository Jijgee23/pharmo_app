import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/active_delivery/widgets/delivery_ui.dart';

/// Lets the driver set [order]'s delivery state.
Future<void> showOrderStatusSheet(DeliveryOrder order) =>
    Get.bottomSheet(OrderStatusSheet(order: order), isScrollControlled: true);

/// The delivery states a driver can set on an order (Түгээлтэнд гарсан,
/// Хүргэгдсэн, Буцаагдсан, Хаалттай), the current one marked. Returned and
/// closed are asked to confirm, as they take the order off the round.
class OrderStatusSheet extends StatefulWidget {
  final DeliveryOrder order;
  const OrderStatusSheet({super.key, required this.order});

  @override
  State<OrderStatusSheet> createState() => _OrderStatusSheetState();
}

class _OrderStatusSheetState extends State<OrderStatusSheet> {
  // The state being saved, to spin on its row.
  OrderProcess? _saving;

  static const _confirmed = {OrderProcess.returned, OrderProcess.closed};

  Future<void> _set(OrderProcess process) async {
    if (_saving != null || process == widget.order.orderProcess) return;
    if (_confirmed.contains(process)) {
      final ok = await confirmDialog(
        title: '"${process.name}" болгох уу?',
        message: '#${widget.order.orderNo} · ${widget.order.recipientName}',
      );
      if (!ok || !mounted) return;
    }
    HapticFeedback.selectionClick();
    setState(() => _saving = process);
    final done = await context.read<JaggerProvider>().setOrderProcess(widget.order, process);
    if (!mounted) return;
    if (done) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.order.orderProcess;
    return AppSheet(
      title: 'Төлөв солих',
      subtitle: '#${widget.order.orderNo} · ${widget.order.recipientName}',
      closable: _saving == null,
      children: [
        for (final process in OrderProcess.deliveryProcess)
          _StatusOption(
            process: process,
            current: process == current,
            saving: _saving == process,
            onTap: () => _set(process),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  final OrderProcess process;
  final bool current;
  final bool saving;
  final VoidCallback onTap;

  const _StatusOption({
    required this.process,
    required this.current,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = process.color;
    final strong = strongShade(color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: current ? color.withValues(alpha: 0.08) : grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: current ? color : Colors.transparent, width: 1.6),
        ),
        child: InkWell(
          onTap: current ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(processIcon(process), color: strong, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    process.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                      color: current ? strong : Colors.grey.shade900,
                    ),
                  ),
                ),
                if (saving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                else if (current)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'Одоогийн',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: white),
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: grey400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
