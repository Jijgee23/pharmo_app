import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_widget.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/waving_animation.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});
  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setLoading(true);
      Future.microtask(() => context.read<JaggerProvider>().getDeliveries());
      if (context.read<JaggerProvider>().delivery.isNotEmpty) {
        Future.microtask(() => context.read<JaggerProvider>().initJagger());
      }

      setLoading(false);
    });
  }

  startShipment(int shipmentId, JaggerProvider jagger) async {
    setLoading(true);
    await jagger.startShipment(shipmentId, context);
    if (mounted) setLoading(false);
  }

  endShipment(int shipmentId, JaggerProvider jagger) async {
    setLoading(true);
    jagger.stopForegroundService();
    await jagger.endShipment(shipmentId, context);
    Navigator.pop(context);
    if (mounted) setLoading(false);
  }

  var pad = const EdgeInsets.only(left: 5);
  var st = const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 16);
  refresh() async {
    setLoading(true);
    await fetch();
  }

  String selected = 'e';
  String pType = 'E';
  setSelected(String s, String p) {
    setState(() {
      selected = s;
      pType = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final dels = jagger.delivery;
        return DataScreen(
          loading: loading,
          empty: false,
          onRefresh: () async => await refresh(),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                ...dels.map(
                  (del) {
                    if (del.orders.isEmpty) {
                      return const SizedBox.shrink();
                    } else {
                      return deliveryContaier(del, jagger);
                    }
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  User? getUser(Order order) {
    if (order.orderer != null) {
      return order.orderer;
    } else if (order.customer != null) {
      return order.customer;
    } else if (order.user != null) {
      return order.user;
    }
    return null;
  }

  List<User> getUniqueUsers(List<Order> orders) {
    Set<String> userIds = {}; // Track unique user IDs
    List<User> users = [];

    for (var order in orders) {
      var user = getUser(order);
      if (user != null && !userIds.contains(user.id)) {
        users.add(user);
        userIds.add(user.id); // Store ID to prevent duplicates
      }
    }
    return users;
  }

  Widget deliveryContaier(Delivery del, JaggerProvider jagger) {
    List<User?> users = getUniqueUsers(del.orders);

    return Container(
      padding: padding10,
      width: double.maxFinite,
      decoration: BoxDecoration(color: primary.withAlpha(150), borderRadius: border20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          startingWidget(del, jagger),
          const SizedBox(),
          if (jagger.timer == null || !jagger.timer!.isActive)
            Button(
              text: 'Байршил дамжуулах',
              color: neonBlue,
              onTap: () async {
                await jagger.initJagger();
                await jagger
                    .start(del.id, context)
                    .then((e) => message('Байршил дамжуулж эхлэлээ'));
              },
            ),
          Text('Захиалгууд:', style: st),
          ...users.map(
            (user) => Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: atnessGrey), borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(maybeNull(user!.name),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (!user.id.contains('p'))
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          decoration: BoxDecoration(
                              color: neonBlue, borderRadius: BorderRadius.circular(15)),
                          child: CustomTextButton(
                              color: white,
                              text: 'Төлбөр бүртгэх',
                              onTap: () => registerSheet(jagger, user)),
                        ),
                    ],
                  ),
                  ...del.orders.map((order) => getUser(order)!.id == user.id
                      ? DeliveryWidget(order: order, delId: del.id)
                      : const SizedBox()),
                ],
              ),
            ),
          ),
          // ...del.orders.map((order) => DeliveryWidget(order: order, delId: del.id)),
          // customer(123, del.orders),
          endingWidget(del, jagger),
        ],
      ),
    );
  }

  TextEditingController amountCr = TextEditingController();

  registerSheet(JaggerProvider jagger, User user) {
    String? name = user.name;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: name != null ? '$name харилцагч дээр төлбөр бүртгэх' : '',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  message('Дүн оруулна уу!');
                } else {
                  registerPayment(jagger, pType, amountCr.text, user.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  registerPayment(JaggerProvider jagger, String type, String amount, String customerId) async {
    if (amount.isEmpty) {
      message('Дүн оруулна уу!');
    } else if (type == 'E') {
      message('Төлбөрийн хэлбэр сонгоно уу!');
    } else {
      await jagger.addCustomerPayment(type, amount, customerId);
      setSelected('E', 'e');
      amountCr.clear();
      Navigator.pop(context);
    }
  }

  Row endingWidget(Delivery del, JaggerProvider jagger) {
    return Row(
      children: [
        (del.startedOn != null && del.endedOn == null)
            ? button(
                title: 'Түгээлт дуусгах',
                color: theme.primaryColor,
                onTap: () => askEnd(del, jagger))
            // endShipment(del.id, jagger))
            : const SizedBox(),
        (del.endedOn == null)
            ? const SizedBox()
            : Padding(padding: pad, child: Text('Түгээлт дууссан: ${del.endedOn!}', style: st)),
      ],
    );
  }

  askEnd(Delivery del, JaggerProvider jagger) {
    List<Order>? unDeliveredOrders = del.orders.where((t) => t.process == 'O').toList();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                spacing: 15,
                children: [
                  if (unDeliveredOrders.isEmpty)
                    const Text(
                      'Та түгээлтийг дуусгахдаа итгэлтэй байна уу?',
                      textAlign: TextAlign.center,
                    ),
                  if (unDeliveredOrders.isNotEmpty)
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(color: black, fontSize: 16),
                        children: [
                          TextSpan(
                              text:
                                  'Танд хүргэж дуусаагүй ${unDeliveredOrders.length} захиалга байна. ('),
                          ...unDeliveredOrders.map(
                            (e) => TextSpan(
                              children: [
                                const TextSpan(
                                  text: ' #',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: succesColor,
                                  ),
                                ),
                                TextSpan(
                                  text: '${e.orderNo},',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const TextSpan(text: ') ,Та түгээлтийг дуусгахдаа итгэлтэй байна уу?'),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DialogButton(
                        width: 100,
                        child: const Text('Үгүй'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      DialogButton(
                        width: 100,
                        color: theme.primaryColor,
                        child: const Text('Тийм'),
                        onPressed: () => endShipment(del.id, jagger),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  askStart(Delivery del, JaggerProvider jagger) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                spacing: 15,
                children: [
                  const Text('Түгээлтийг эхлүүлэх үү?', textAlign: TextAlign.center),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DialogButton(
                        width: 100,
                        child: const Text('Үгүй'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      DialogButton(
                        width: 100,
                        color: theme.primaryColor,
                        child: const Text('Тийм'),
                        onPressed: () => Future(
                          () async {
                            startShipment(del.id, jagger);
                            await jagger.getDeliveries();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget startingWidget(Delivery del, JaggerProvider jagger) {
    bool deliveryStarted = del.startedOn != null;
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!deliveryStarted)
          button(
              title: 'Түгээлт эхлүүлэх',
              color: theme.primaryColor,
              onTap: () => askStart(del, jagger)),
        if (deliveryStarted)
          const WavingAnimation(assetPath: 'assets/stickers/truck_animation.gif', dots: true),
        if (deliveryStarted)
          Padding(padding: pad, child: Text('Түгээлт эхлэсэн: ${del.startedOn}', style: st)),
      ],
    );
  }

  Center noResult() {
    return Center(child: Image.asset('assets/icons/not-found.png', width: Sizes.width * 0.3));
  }

  button({required String title, required Color color, required GestureTapCallback onTap}) {
    return SizedBox(
      width: Sizes.width * .45,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.onPrimary,
            shadowColor: grey400,
            shape: RoundedRectangleBorder(borderRadius: border20),
            padding: const EdgeInsets.symmetric(vertical: 10)),
        child: Center(
          child: loading
              ? const CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation(white))
              : text(title, color: white),
        ),
      ),
    );
  }

  Widget picker(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    return InkWell(
      onTap: () => setModalState(() {
        selected = n;
        pType = v;
      }),
      child: AnimatedContainer(
        duration: duration,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: sel ? 20 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sel ? succesColor.withOpacity(.3) : white,
          border: Border.all(
            color: sel ? succesColor : grey300,
          ),
        ),
        child: Text(n),
      ),
    );
  }
}
