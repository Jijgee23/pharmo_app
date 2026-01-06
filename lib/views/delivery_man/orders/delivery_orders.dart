import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:pharmo_app/controller/providers/jagger_provider.dart';
import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/controller/models/delman.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';

class DeliveryOrders extends StatefulWidget {
  const DeliveryOrders({super.key});

  @override
  State<DeliveryOrders> createState() => _DeliveryOrdersState();
}

class _DeliveryOrdersState extends State<DeliveryOrders> {
  List<int> selecteds = [];
  int delman = -1;
  String me = 'Өөрийн';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    final jag = context.read<JaggerProvider>();
    jag.setLoading(true);
    await jag.getOrders();
    await jag.getDelmans();
    if (mounted) {
      jag.setLoading(false);
    }
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
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => DataScreen(
        onRefresh: () => jagger.getOrders(),
        loading: jagger.loading,
        pad: EdgeInsets.all(14.0),
        empty: jagger.orders.isEmpty,
        child: Stack(
          children: [
            ListView.separated(
              itemCount: jagger.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _orderWidget(
                jagger,
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

  Widget _orderWidget(JaggerProvider jagger, Order ord) {
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

  void addSheet(JaggerProvider jagger) {
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
                children: jagger.delmans
                    .map((dm) => _delmanWidget(dm, setModalState))
                    .toList(),
              ),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (me == 'Өөрийн') {
                  jagger.addOrdersToDelivery(selecteds);
                } else {
                  if (delman == -1) {
                    message('Түгээгч сонгоно уу!');
                  } else {
                    jagger.passOrdersToDelman(selecteds, delman);
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
