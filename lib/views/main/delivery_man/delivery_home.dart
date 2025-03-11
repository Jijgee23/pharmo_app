import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/location_service.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/delivery_man/orderer.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/waving_animation.dart';
import 'package:provider/provider.dart';

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});
  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  bool loading = false;
  setLoading(bool n) {
    setState(() => loading = n);
  }

  @override
  initState() {
    super.initState();
    fetch();
  }

  fetch() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setLoading(true);
        Future.microtask(() => context.read<JaggerProvider>().getDeliveries());
        setLoading(false);
      },
    );
  }

  startShipment(int shipmentId, JaggerProvider jagger) async {
    setLoading(true);
    await jagger.startShipment(shipmentId);
    if (mounted) setLoading(false);
  }

  endShipment(int shipmentId, JaggerProvider jagger) async {
    setLoading(true);
    await jagger.endShipment(shipmentId);
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
        return DataScreen(
          loading: loading,
          empty: dels.isEmpty,
          onRefresh: () async => await refresh(),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                ...dels.map((del) => deliveryContaier(del, jagger)),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  List<User> getUniqueUsers(List<Order> orders) {
    Set<String> userIds = {};
    List<User> users = [];

    for (var order in orders) {
      var user = getUser(order);
      if (user != null && !userIds.contains(user.id)) {
        users.add(user);
        userIds.add(user.id);
      }
    }
    return users;
  }

  Widget deliveryContaier(Delivery del, JaggerProvider jagger) {
    List<User?> users = getUniqueUsers(del.orders);
    return Container(
      padding: EdgeInsets.all(7.5),
      width: double.maxFinite,
      decoration: BoxDecoration(color: primary.withAlpha(150), borderRadius: border10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          startingWidget(del, jagger),
          button(
            title: 'Байршил дамжуулах',
            color: neonBlue,
            onTap: () => LocationService().startTracking(del.id),
          ),
          Text('Захиалгууд:', style: st),
          ...users.map((user) => OrdererOrders(user: user, del: del)),
          endingWidget(del, jagger),
        ],
      ),
    );
  }

  Widget startingWidget(Delivery del, JaggerProvider jagger) {
    bool started = del.startedOn != null;
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!started)
          button(
            title: 'Түгээлт эхлүүлэх',
            color: theme.primaryColor,
            onTap: () => askStart(del, jagger),
          ),
        if (started)
          const WavingAnimation(assetPath: 'assets/stickers/truck_animation.gif', dots: true),
        if (started)
          Padding(padding: pad, child: Text('Түгээлт эхлэсэн: ${del.startedOn}', style: st)),
      ],
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
            : const SizedBox(),
        (del.endedOn == null)
            ? const SizedBox()
            : Padding(padding: pad, child: Text('Түгээлт дууссан: ${del.endedOn!}', style: st)),
      ],
    );
  }

  askEnd(Delivery del, JaggerProvider jagger) {
    List<Order>? unDeliveredOrders = del.orders.where((t) => t.process == 'O').toList();
    askDialog(context, () => endShipment(del.id, jagger), '', [
      if (unDeliveredOrders.isEmpty)
        Text(
          'Та түгээлтийг дуусгахдаа итгэлтэй байна уу?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      if (unDeliveredOrders.isNotEmpty)
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black),
            children: [
              TextSpan(text: 'Танд хүргэж дуусаагүй ${unDeliveredOrders.length} захиалга байна. ('),
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
              const TextSpan(text: 'Та түгээлтийг дуусгахдаа итгэлтэй байна уу?'),
            ],
          ),
        ),
    ]);
  }

  askStart(Delivery del, JaggerProvider jagger) {
    askDialog(
        context,
        () => Future(
              () async {
                startShipment(del.id, jagger);
                await jagger.getDeliveries();
                Navigator.pop(context);
              },
            ),
        'Түгээлтийг эхлүүлэх үү?',
        []);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
