import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/delivery_items.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer.dart';
import 'package:pharmo_app/views/ORDERER/promotion/marked_promo_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
    init();
  }

  Future<void> init() async {
    final jag = context.read<JaggerProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        jag.setLoading(true);
        await jag.getDeliveries();
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
              appbar: AppBar(
                title: Text(
                  'Идэвхитэй түгээлтүүд',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
              loading: jagger.loading,
              empty: false,
              onRefresh: () async => await init(),
              child: Builder(
                builder: (context) {
                  if (dels.isEmpty) {
                    return Center(
                      child: Text('Хувиарлагдсан түгээлт байхгүй'),
                    );
                  }
                  return SingleChildScrollView(
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
                      ],
                    ),
                  );
                },
              ),
            ),
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
    return Stack(
      children: [
        Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            startingWidget(del, jagger),
            Text('Захиалгууд:', style: st),
            ...users.map((user) => OrdererOrders(user: user, del: del)),
            Text('Нэмэлт хүргэлтүүд:', style: st),
            DeliveryItemsWidget(items: del.items!),
          ],
        ),
      ],
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
              if (jagger.subscription == null && del.startedOn != null)
                Text(
                  'Байршил дамжуулалт зогссон байна, байршил дамжуулах дарна уу!',
                  style: TextStyle(color: Colors.red),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 10,
                children: [
                  if (jagger.subscription == null && del.startedOn != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          button(
                            title: 'Байршил дамжуулах',
                            color: neonBlue,
                            onTap: () async => await jagger.tracking(),
                          ),
                        ],
                      ),
                    ),
                  if (del.startedOn != null)
                    Expanded(
                      child: button(
                        title: 'Түгээлт дуусгах',
                        color: neonBlue,
                        onTap: () => askToEnd(del, jagger),
                      ),
                    )
                ],
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
