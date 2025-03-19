import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/controllers/models/delman.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';

class DeliveryOrders extends StatefulWidget {
  const DeliveryOrders({super.key});

  @override
  State<DeliveryOrders> createState() => _DeliveryOrdersState();
}

class _DeliveryOrdersState extends State<DeliveryOrders> {
  @override
  initState() {
    super.initState();
    Future.microtask(() => context.read<JaggerProvider>().getOrders());
    Future.microtask(() => context.read<JaggerProvider>().getDelmans());
  }

  List<int> selecteds = [];

  onTapOrder(Order order) {
    setState(() {
      if (selecteds.contains(order.id)) {
        selecteds.remove(order.id);
      } else {
        selecteds.add(order.id);
      }
    });
  }

  int delman = -1;
  setDelman(int n) {
    setState(() {
      delman = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => DataScreen(
        onRefresh: () => jagger.getOrders(),
        loading: false,
        empty: jagger.orders.isEmpty,
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    ...jagger.orders.map((ord) => _orderWidget(jagger, ord)),
                    SizedBox(height: 20)
                  ],
                ),
              ),
            ),
            Expanded(
                child: Container(
              color: transperant,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: CustomButton(
                  text: 'Түгээлтрүү нэмэх', ontap: () => addSheet(jagger)),
            )),
            SizedBox(height: kToolbarHeight + 20)
          ],
        ),
      ),
    );
  }

  _orderWidget(JaggerProvider jagger, Order ord) {
    bool selected = selecteds.contains(ord.id);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
      decoration: BoxDecoration(
          border: Border.all(color: atnessGrey),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onTapOrder(ord),
            child: AnimatedContainer(
              duration: duration,
              padding: EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                  color: selected ? succesColor : transperant,
                  borderRadius: BorderRadius.circular(3.5),
                  border:
                      Border.all(color: selected ? transperant : frenchGrey)),
              child: selected
                  ? Icon(Icons.check, size: 25, color: white)
                  : SizedBox(height: 25, width: 25),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ord.orderer!.name} (${ord.items.length}ш бараа)',
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ord.orderNo),
                    Text(toPrice(ord.totalPrice),
                        style: TextStyle(color: secondary))
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  addSheet(JaggerProvider jagger) {
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
                children: [
                  ...jagger.delmans
                      .map((dm) => _delmanWidget(dm, setModalState)),
                ],
              ),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                if (me == 'Өөрийн') {
                  jagger.addOrdersToDelivery(selecteds);
                } else {
                  print('delman id: $delman');
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

  cleanOrders(Function(void Function()) setModalState) {
    setModalState(() {
      selecteds.clear();
    });
  }

  _delmanWidget(Delman dm, Function(void Function()) setModalState) {
    bool selected = delman == dm.id;
    return InkWell(
      onTap: () => setModalState(() {
        setDelman(dm.id);
      }),
      child: AnimatedContainer(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        duration: duration,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? neonBlue.withAlpha(150) : transperant,
            border: Border.all(color: selected ? neonBlue : frenchGrey)),
        child: Text(
          dm.name,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: selected ? white : black),
        ),
      ),
    );
  }

  String me = 'Өөрийн';

  Widget picker(String n, Function(void Function()) setModalState) {
    bool sel = (me == n);
    return InkWell(
      onTap: () => setModalState(() {
        me = n;
        print(me);
      }),
      child: AnimatedContainer(
        duration: duration,
        width: Sizes.width * .4,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: sel ? 20 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sel ? succesColor.withOpacity(.3) : white,
          border: Border.all(
            color: sel ? succesColor : grey300,
          ),
        ),
        child: Center(child: Text(n)),
      ),
    );
  }
}
