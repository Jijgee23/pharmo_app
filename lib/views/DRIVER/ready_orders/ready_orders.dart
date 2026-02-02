import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/application/application.dart';

class ReadyOrders extends StatefulWidget {
  const ReadyOrders({super.key});

  @override
  State<ReadyOrders> createState() => _ReadyOrdersState();
}

class _ReadyOrdersState extends State<ReadyOrders> {
  List<int> selecteds = [];
  int delman = -1;
  String me = 'Өөрийн';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetch());
  }

  Future fetch() async {
    LoadingService.run(() async {
      final jag = context.read<DriverProvider>();
      await jag.getOrders();
    });
  }

  void onTapOrder(DeliveryOrder order) {
    setState(() {
      selecteds.contains(order.id)
          ? selecteds.remove(order.id)
          : selecteds.add(order.id);
    });
  }

  void setDelman(int n) {
    setState(() {
      delman = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, jagger, child) => Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Бэлэн захиалгууд',
                      style: ContextX(context).theme.appBarTheme.titleTextStyle,
                    )
                  ],
                ).paddingAll(10),
                Divider(),
                Flexible(
                  child: Builder(
                    builder: (context) {
                      if (jagger.orders.isEmpty) {
                        return NoResult();
                      }
                      return ListView.builder(
                        itemCount: jagger.orders.length,
                        itemBuilder: (context, index) => _orderWidget(
                          jagger.orders[index],
                        ),
                      );
                    },
                  ).paddingAll(10),
                )
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Durations.medium1,
            bottom: 20,
            right: selecteds.isNotEmpty ? 20 : -200,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                    ),
                    onPressed: () => addSheet(jagger),
                    child: Text(
                      'Түгээлт рүү нэмэх',
                      style: TextStyle(color: white),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _orderWidget(DeliveryOrder ord) {
    bool selected = selecteds.contains(ord.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapOrder(ord),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.green.shade300 : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: selected ? 12 : 8,
                  offset: Offset(0, selected ? 4 : 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        selected ? Colors.green.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Colors.green.shade600
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name with item count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ord.orderer?.name ?? 'Захиалагч',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: selected
                                    ? Colors.green.shade900
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 14,
                                  color: selected
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ord.items.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Order number and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Order number
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ord.orderNo,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Price
                          Text(
                            toPrice(ord.totalPrice),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addSheet(DriverProvider driver) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: '$me түгээлт дээр нэмэх',
          children: [
            Row(
              spacing: 10,
              children: [
                picker('Өөрийн', setModalState),
                picker('Бусдын', setModalState),
              ],
            ),
            if (me != 'Өөрийн')
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: driver.delmans
                    .map((dm) => _delmanWidget(dm, setModalState))
                    .toList(),
              ),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (me == 'Өөрийн') {
                  driver.addOrdersToDelivery(selecteds);
                } else {
                  if (delman == -1) {
                    message('Түгээгч сонгоно уу!');
                  } else {
                    driver.passOrdersToDelman(selecteds, delman);
                  }
                }
                Navigator.pop(context);
                cleanOrders(setModalState);
              },
            ),
          ],
        ),
      ),
    );
  }

  void cleanOrders(Function(void Function()) setModalState) {
    setModalState(() {
      selecteds.clear();
    });
  }

  Widget _delmanWidget(Delman dm, Function(void Function()) setModalState) {
    bool selected = delman == dm.id;
    return InkWell(
      onTap: () => setModalState(() => setDelman(dm.id)),
      child: IntrinsicWidth(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          constraints: BoxConstraints(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? neonBlue.withAlpha(150) : Colors.transparent,
            border: Border.all(color: selected ? neonBlue : frenchGrey),
          ),
          child: Text(
            dm.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget picker(String n, Function(void Function()) setModalState) {
    bool sel = me == n;
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: sel ? succesColor : grey500),
        ),
        color: sel ? succesColor.withAlpha(120) : Colors.white,
        child: InkWell(
          onTap: () => setModalState(() => me = n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text(n)),
          ),
        ),
      ),
    );
  }
}
