import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/deliveries.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/delivery_order_card.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/orderer_orders.dart';

class OrdererCard extends StatefulWidget {
  final User? user;
  final Delivery del;
  const OrdererCard({super.key, required this.user, required this.del});

  @override
  State<OrdererCard> createState() => _OrdererCardState();
}

class _OrdererCardState extends State<OrdererCard> {
  String selected = 'e';
  String pType = 'E';

  setSelected(String s, String p) {
    setState(() {
      selected = s;
      pType = p;
    });
  }

  TextEditingController amountCr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var ordererOrders = widget.del.orders
        .where((order) => getUser(order)?.id == widget.user?.id)
        .toSet()
        .toList();

    final deliveredCount = ordererOrders.where((o) => o.process == 'D').length;
    final totalCount = ordererOrders.length;
    final progress = totalCount > 0 ? deliveredCount / totalCount : 0.0;

    final name = (widget.user == null || widget.user!.name == 'null')
        ? 'Харилцагч (${widget.user?.id ?? ""})'
        : widget.user!.name;

    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => goto(
              OrdererOrders(
                orders: ordererOrders,
                ordererName: name,
                delId: widget.del.id,
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAvatar(name),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildOrderBadge(
                                  deliveredCount,
                                  totalCount,
                                  progress,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$deliveredCount / $totalCount захиалга',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(progress),
                  if (widget.user != null && !widget.user!.id.contains('p')) ...[
                    const SizedBox(height: 12),
                    _buildPaymentButton(jagger),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBadge(int delivered, int total, double progress) {
    Color color;
    if (progress == 1.0) {
      color = Colors.green;
    } else if (progress > 0) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            progress == 1.0 ? Icons.check_circle : Icons.pending,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            progress == 1.0 ? 'Дууссан' : 'Явагдаж байна',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Хүргэлтийн явц',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: progress == 1.0 ? Colors.green : primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : primary,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(JaggerProvider jagger) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => registerSheet(jagger, widget.user!),
        icon: const Icon(Icons.payment, size: 18),
        label: const Text('Төлбөр бүртгэх'),
        style: OutlinedButton.styleFrom(
          foregroundColor: neonBlue,
          side: BorderSide(color: neonBlue.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Iterable<Widget> orders() {
    return widget.del.orders.map(
      (order) => getUser(order)!.id == widget.user!.id
          ? DeliveryOrderCard(order: order, delId: widget.del.id)
          : const SizedBox(),
    );
  }

  Widget picker(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    final main = sel ? primary : white;
    final sec = !sel ? primary : white;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setModalState(() {
          selected = n;
          pType = v;
        }),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: main,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: sel ? succesColor : grey300,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              n,
              style: TextStyle(
                color: sec,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sel) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Future registerSheet(JaggerProvider jagger, User user) async {
    String? name = user.name;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payment, color: neonBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Төлбөр бүртгэх',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (name != null)
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Төлбөрийн хэлбэр',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  picker('Бэлнээр', 'C', setModalState),
                  const SizedBox(width: 12),
                  picker('Дансаар', 'T', setModalState),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Дүн',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: amountCr,
                hintText: 'Дүн оруулах',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (amountCr.text.isEmpty) {
                      messageWarning('Дүн оруулна уу!');
                    } else {
                      registerPayment(jagger, pType, amountCr.text, user.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Хадгалах',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future registerPayment(
    JaggerProvider jagger,
    String type,
    String amount,
    String customerId,
  ) async {
    if (amount.isEmpty) {
      messageWarning('Дүн оруулна уу!');
    } else if (type == 'E') {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
    } else {
      await jagger.addCustomerPayment(type, amount, customerId);
      setSelected('E', 'e');
      amountCr.clear();
      Navigator.pop(context);
    }
  }
}
