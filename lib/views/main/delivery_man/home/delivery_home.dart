import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/delivery.dart';
import 'package:pharmo_app/services/settings.dart';
import 'package:pharmo_app/utilities/a_utils.dart';
import 'package:pharmo_app/views/main/delivery_man/home/delivery_items.dart';
import 'package:pharmo_app/views/main/delivery_man/home/map_view.dart';
import 'package:pharmo_app/views/main/delivery_man/home/orderer.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
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

  // int? batteryLevel;
  Future<void> init() async {
    final jag = context.read<JaggerProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        jag.setLoading(true);
        await jag.getDeliveries();
        await Settings.checkAlwaysLocationPermission();
        await jag.getDeliveryLocation();
        jag.setLoading(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final dels = jagger.delivery;
        return Stack(
          children: [
            DataScreen(
              loading: jagger.loading,
              empty: false,
              onRefresh: () async => await init(),
              child: dels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Хувиарлагдсан түгээлт байхгүй'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      controller: jagger.scrollController,
                      child: Column(
                        spacing: 10,
                        children: [
                          ...dels.map((del) => deliveryContaier(del, jagger)),
                          Center(
                            child: CustomTextButton(
                              text: 'Байршил дамжуулах заавар',
                              onTap: () => launchUrlString(
                                'https://www.youtube.com/shorts/W2s9rTCIxTk',
                              ),
                            ),
                          ),
                          SizedBox(height: Sizes.height * .085),
                        ],
                      ),
                    ),
            ),
            Positioned(
              bottom: 100,
              right: 10,
              child: FloatingActionButton(
                onPressed: () => goto(MapView()),
                shape: CircleBorder(),
                child: Icon(
                  Icons.location_on_outlined,
                  color: white,
                  size: 30,
                ),
              ),
            )
          ],
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
      child: Stack(
        children: [
          Column(
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
                  onTap: () => askToStart(del.id),
                ),
              if (started)
                Text(
                  'Түгээлт эхлэсэн: ${del.startedOn!.substring(11, 16)}',
                  style: st,
                ),
            ],
          ),
        ),
      ],
    );
  }

  askToStart(int delid) async {
    var j = context.read<JaggerProvider>();
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Түгээлтийг эхлүүлэх үү?',
      message: 'Түгээлтийн үед таны байршлыг хянахыг анхаарна уу!',
    );
    if (confirmed) await j.startShipment(delid);
  }

  Widget endingWidget(Delivery del, JaggerProvider jagger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (jagger.positionSubscription == null && del.startedOn != null)
          button(
            title: 'Байршил дамжуулах',
            color: neonBlue,
            onTap: () => jagger.tracking(force: true),
          ),
        if (jagger.positionSubscription != null && del.startedOn != null)
          button(
            title: 'Түгээлт дуусгах',
            color: neonBlue,
            onTap: () => askToEnd(del, jagger),
          ),
      ],
    );
  }

  askToEnd(Delivery del, JaggerProvider jagger) async {
    List<Order>? unDeliveredOrders =
        del.orders.where((t) => t.process == 'O').toList();
    var j = context.read<JaggerProvider>();
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Түгээлтийг үнэхээр дуусгах уу?',
      message: unDeliveredOrders.isNotEmpty
          ? 'Дараах захиалгууд хүргэгдээгүй байна:\n ${unDeliveredOrders.map((e) => e.orderNo)}'
          : '',
    );
    if (confirmed) await j.endShipment(del.id);
  }

  button({
    required String title,
    required Color color,
    required GestureTapCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onPrimary,
        shadowColor: grey400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      child: Center(
        child: text(title, color: white),
      ),
    );
  }

  final st = const TextStyle(
    color: black,
    fontWeight: FontWeight.bold,
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
