import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/additional_delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/orderer_card.dart';
import 'package:pharmo_app/views/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/application/application.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await init(),
    );
  }

  Future<void> init() async {
    await LoadingService.run(() async {
      final jag = context.read<JaggerProvider>();
      await jag.getDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final delivery = jagger.delivery;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: grey100,
            appBar: AppBar(
              title: Text(
                'Идэвхитэй түгээлтүүд',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () async => await init(),
                  icon: Icon(Icons.refresh_rounded),
                )
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Ерөнхий'),
                  Tab(text: 'Нэмэлт хүргэлтүүд'),
                ],
              ),
            ),
            body: Builder(
              builder: (context) {
                if (delivery != null) {
                  List<User> users = getUniqueUsers(delivery.orders);
                  return SafeArea(
                    child: TabBarView(
                      children: [
                        RefreshIndicator.adaptive(
                          onRefresh: () async => await init(),
                          child: SingleChildScrollView(
                            controller: jagger.scrollController,
                            child: Column(
                              spacing: 10,
                              children: [
                                SizedBox(height: 10),
                                startingWidget(delivery, jagger),
                                SectionCard(
                                  title: 'Захиалагчид',
                                  child: Column(
                                    children: [
                                      ...users.map(
                                        (user) => OrdererCard(
                                          user: user,
                                          del: delivery,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AdditionalDeliveries(items: delivery.items!),
                      ],
                    ),
                  );
                }
                return Center(
                  child: Text('Хувиарлагдсан түгээлт байхгүй'),
                );
              },
            ).paddingSymmetric(horizontal: 14),
          ),
        );
      },
    );
  }

  List<User> getUniqueUsers(List<DeliveryOrder> orders) {
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

  startingWidget(Delivery del, JaggerProvider jagger) {
    bool started = del.startedOn != null;
    bool trackStopped = del.startedOn != null &&
        (jagger.subscription!.isPaused || jagger.subscription == null);
    return SectionCard(
      title: '',
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!started)
            ModernActionButton(
              label: 'Түгээлт эхлүүлэх',
              icon: Icons.location_on,
              color: primary,
              onTap: () => askToStart(del.id),
            ),
          if (started)
            Text(
              'Түгээлт эхлэсэн: ${del.startedOn!.substring(11, 16)}',
              style: st,
            ),
          if (trackStopped)
            Text(
              'Байршил дамжуулалт зогссон байна, байршил дамжуулах дарна уу!',
              style: TextStyle(color: Colors.amber),
            ),
          if (trackStopped)
            ModernActionButton(
              label: 'Түгээлт үргэлжлүүлэх',
              icon: Icons.location_searching,
              color: Colors.amber,
              onTap: () async => await jagger.tracking(),
            ),
          if (del.startedOn != null)
            ModernActionButton(
              label: 'Түгээлт дуусгах',
              icon: Icons.location_off,
              color: Colors.redAccent,
              onTap: () => askToEnd(del, jagger),
            )
        ],
      ),
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

  askToEnd(Delivery del, JaggerProvider jagger) async {
    List<DeliveryOrder>? unDeliveredOrders =
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
    required Function() onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shadowColor: grey400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Center(child: text(title, color: white)),
    );
  }

  final st = const TextStyle(
    color: black,
    fontWeight: FontWeight.bold,
  );
}

User? getUser(DeliveryOrder order) {
  if (order.orderer != null) {
    return order.orderer;
  } else if (order.customer != null) {
    return order.customer;
  } else if (order.user != null) {
    return order.user;
  }
  return null;
}
