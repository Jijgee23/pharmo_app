import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_widget.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final dels = jagger.delivery;
        final zones = jagger.zones;
        return DataScreen(
          loading: loading,
          empty: false,
          onRefresh: () async => await refresh(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(gradient: pinkGradinet, borderRadius: border20),
                  width: double.infinity,
                  padding: padding15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Танд одоогоор идэвхитэй ${dels.length} түгээлт байна.',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (zones.isNotEmpty)
                              const Text(
                                'Хүргэлт хийх бүсүүд:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            if (zones.isNotEmpty) const SizedBox(height: 6),
                            if (zones.isNotEmpty)
                              Wrap(
                                spacing: 10,
                                runSpacing: 5,
                                children: zones
                                    .map(
                                      (e) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          e.name,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
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

  Container deliveryContaier(Delivery del, JaggerProvider jagger) {
    return Container(
      padding: padding15,
      width: double.maxFinite,
      decoration: BoxDecoration(color: primary, borderRadius: border20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          startingWidget(del, jagger),
          const SizedBox(),
          Button(
              text: 'Байршил дамжуулах',
              color: neonBlue,
              onTap: () =>
                  jagger.start(del.id, context).then((e) => message('Байршил дамжуулж эхлэлээ'))),
          Text('Захиалгууд:', style: st),
          ...del.orders.map((order) => DeliveryWidget(order: order, delId: del.id)),
          endingWidget(del, jagger),
        ],
      ),
    );
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
}
