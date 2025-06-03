import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/services/settings.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/delivery_man/home/delivery_items.dart';
import 'package:pharmo_app/views/main/delivery_man/home/map_view.dart';
import 'package:pharmo_app/views/main/delivery_man/home/orderer.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});
  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  @override
  initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final jag = context.read<JaggerProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      jag.setLoading(true);
      final provider = context.read<JaggerProvider>();
      await provider.getDeliveries();
      await Settings.checkAlwaysLocationPermission();
      await provider.getDeliveryLocation();
      jag.setLoading(false);
    });
  }

  startShipment(int shipmentId) async {
    final jag = context.read<JaggerProvider>();
    jag.setLoading(true);
    await jag.startShipment(shipmentId);
    if (mounted) jag.setLoading(false);
  }

  endShipment(int shipmentId) async {
    final jag = context.read<JaggerProvider>();
    jag.setLoading(true);
    await jag.endShipment(shipmentId);
    Navigator.pop(context);
    if (mounted) jag.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final dels = jagger.delivery;
        return DataScreen(
          loading: jagger.loading,
          empty: false,
          onRefresh: () async => await init(),
          child: SingleChildScrollView(
            controller: jagger.scrollController,
            physics: jagger.physics,
            child: Column(
              spacing: 10,
              children: [
                MapView(),
                ...dels.map((del) => deliveryContaier(del, jagger)),
                CustomTextButton(
                    text: 'Байршил дамжуулах заавар',
                    onTap: () => launchUrlString(
                        'https://www.youtube.com/shorts/W2s9rTCIxTk')),
                SizedBox(height: Sizes.height * .085),
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
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: white,
        borderRadius: border10,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3.0)],
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          startingWidget(del, jagger),
          Text('Захиалгууд:', style: st),
          ...users.map((user) => OrdererOrders(user: user, del: del)),
          DeliveryItemsWidget(items: del.items!),
          endingWidget(del, jagger)
        ],
      ),
    );
  }

  startingWidget(Delivery del, JaggerProvider jagger) {
    bool started = del.startedOn != null;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 10.0),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!started)
                button(
                  title: 'Түгээлт эхлүүлэх',
                  color: primary,
                  onTap: () => askStart(del, jagger),
                ),
              // if (started)
              //   const WavingAnimation(
              //     assetPath: 'assets/stickers/truck_animation.gif',
              //     dots: true,
              //   ),
              if (started) Text('Түгээлт эхлэсэн: ${del.startedOn}', style: st),
            ],
          ),
        ),
      ],
    );
  }

  Widget endingWidget(Delivery del, JaggerProvider jagger) {
    print(del.startedOn);
    if (del.startedOn != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (del.startedOn != null)
            button(
              title: 'Байршил дамжуулах',
              color: neonBlue,
              onTap: () => askTracking(del.id),
            ),
          button(
            title: 'Түгээлт дуусгах',
            color: neonBlue,
            onTap: () => askEnd(del, jagger),
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  askTracking(int id) async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      message('Байршил авах зөвшөөрөл өгнө үү!');
      return;
    }
    askDialog(
      context,
      () {
        context.read<JaggerProvider>().startTracking();
        Navigator.pop(context);
      },
      'Хүргэлтийн үед л таний байршлийг хянахыг анхаарна уу!',
      [],
    );
  }

  askEnd(Delivery del, JaggerProvider jagger) {
    List<Order>? unDeliveredOrders =
        del.orders.where((t) => t.process == 'O').toList();
    askDialog(context, () => endShipment(del.id), '', [
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
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: black),
            children: [
              TextSpan(text: 'Дараах захиалгууд хүргэгдээгүй байна:\n'),
              ...unDeliveredOrders.map(
                (e) => TextSpan(
                  children: [
                    TextSpan(
                      text: '# ${e.orderNo}\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const TextSpan(
                  text: 'Та түгээлтийг дуусгахдаа итгэлтэй байна уу?'),
            ],
          ),
        ),
    ]);
  }

  askStart(Delivery del, JaggerProvider jagger) async {
    if (!await Settings.checkAlwaysLocationPermission()) {
      return;
    }
    askDialog(
      context,
      () async {
        await startShipment(del.id);
        await jagger.getDeliveries();
        Navigator.pop(context);
      },
      'Түгээлтийг эхлүүлэх үү?',
      [Text('Хүргэлтийн үед л таний байршлийг хянахыг анхаарна уу!')],
    );
  }

  button(
      {required String title,
      required Color color,
      required GestureTapCallback onTap}) {
    return SizedBox(
      width: Sizes.width * .40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.onPrimary,
            shadowColor: grey400,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10)),
        child: Center(child: text(title, color: white)),
      ),
    );
  }

  final st = const TextStyle(
    color: black,
    fontWeight: FontWeight.bold,
    fontSize: 16,
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
