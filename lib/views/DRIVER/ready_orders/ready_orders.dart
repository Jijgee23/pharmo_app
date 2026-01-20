import 'package:pharmo_app/views/cart/cart_item.dart';
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

  void onTapOrder(Order order) {
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
      builder: (context, jagger, child) => DataScreen(
        onRefresh: () async => await jagger.getOrders(),
        loading: false,
        pad: EdgeInsets.all(14.0),
        empty: jagger.orders.isEmpty,
        child: Stack(
          children: [
            ListView.separated(
              itemCount: jagger.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _orderWidget(
                jagger.orders[index],
              ),
            ),
            AnimatedPositioned(
              duration: Durations.medium1,
              bottom: 0,
              right: selecteds.isNotEmpty ? 0 : -200,
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
      ),
    );
  }

  Widget _orderWidget(Order ord) {
    bool selected = selecteds.contains(ord.id);
    return GestureDetector(
      onTap: () => onTapOrder(ord),
      child: Card(
        color: selected ? Colors.green.withAlpha(80) : white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? succesColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selected ? Colors.transparent : frenchGrey,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 25, color: Colors.white)
                    : const SizedBox(height: 25, width: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ord.orderer!.name} (${ord.items.length}ш бараа)',
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ord.orderNo),
                        Text(
                          toPrice(ord.totalPrice),
                          style: const TextStyle(color: secondary),
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
