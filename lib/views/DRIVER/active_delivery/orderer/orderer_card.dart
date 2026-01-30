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
        .where((order) => getUser(order)!.id == widget.user!.id)
        .toSet()
        .toList();
    final name = (widget.user == null || widget.user!.name == 'null')
        ? 'Харилцагч (${widget.user!.id})'
        : widget.user!.name;
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => Card(
        color: grey200,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => goto(
            OrdererOrders(
              orders: ordererOrders,
              ordererName: name,
              delId: widget.del.id,
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedSize(
            duration: duration,
            child: Container(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        maxLines: 3,
                        softWrap: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                          border: Border.all(color: white),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.del.orders
                              .where((t) => getUser(t)!.id == widget.user!.id)
                              .length
                              .toString(),
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!widget.user!.id.contains('p')) addPay(jagger),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addPay(JaggerProvider jagger) {
    return Row(
      children: [
        Expanded(
          child: ModernActionButton(
            label: 'Төлбөр бүртгэх',
            icon: Icons.payment,
            color: neonBlue,
            onTap: () => registerSheet(jagger, widget.user!),
          ),
        ),
      ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: sel ? succesColor : grey300,
            ),
          ),
        ),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              n,
              style: TextStyle(
                color: sec,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sel) Icon(Icons.check, color: white)
          ],
        ),
      ),
    );
  }

  Future registerSheet(JaggerProvider jagger, User user) async {
    String? name = user.name;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: name != null ? '$name харилцагч дээр төлбөр бүртгэх' : '',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                picker('Бэлнээр', 'C', setModalState),
                picker('Дансаар', 'T', setModalState),
              ],
            ),
            CustomTextField(controller: amountCr, hintText: 'Дүн оруулах'),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (amountCr.text.isEmpty) {
                  messageWarning('Дүн оруулна уу!');
                } else {
                  registerPayment(jagger, pType, amountCr.text, user.id)
                      .then((v) {});
                }
              },
            ),
            SizedBox()
          ],
        ),
      ),
    );
  }

  Future registerPayment(JaggerProvider jagger, String type, String amount,
      String customerId) async {
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
