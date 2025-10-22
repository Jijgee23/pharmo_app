import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/models/delman.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
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
        empty: jagger.orders.isEmpty,
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: jagger.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _orderWidget(jagger, jagger.orders[index]),
              ),
            ),
            _bottomActionButton(jagger),
            const SizedBox(height: kToolbarHeight + 20)
          ],
        ),
      ),
    );
  }

  Widget _bottomActionButton(JaggerProvider jagger) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomButton(
        text: 'Түгээлт рүү нэмэх',
        ontap: () => addSheet(jagger),
      ),
    );
  }

  Widget _orderWidget(JaggerProvider jagger, Order ord) {
    bool selected = selecteds.contains(ord.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? succesColor : atnessGrey),
        borderRadius: BorderRadius.circular(10),
        color: selected ? succesColor.withOpacity(0.1) : Colors.white,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: succesColor.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onTapOrder(ord),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
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
    );
  }

  void addSheet(JaggerProvider jagger) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: '$me түгээлт дээр нэмэх',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget picker(String n, Function(void Function()) setModalState) {
    bool sel = me == n;
    return InkWell(
      onTap: () => setModalState(() => me = n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: Sizes.width * .4,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sel ? succesColor.withOpacity(.3) : Colors.white,
          border: Border.all(color: sel ? succesColor : grey300),
        ),
        child: Center(child: Text(n)),
      ),
    );
  }
}
