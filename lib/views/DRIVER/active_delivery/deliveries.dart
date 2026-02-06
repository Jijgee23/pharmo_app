import 'package:pharmo_app/controller/models/delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/additional_delivery.dart';
import 'package:pharmo_app/views/DRIVER/active_delivery/orderer/orderer_card.dart';
import 'package:pharmo_app/application/application.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await init());
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
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildSliverAppBar(delivery, jagger),
              ],
              body: Builder(
                builder: (context) {
                  if (delivery != null) {
                    List<User> users = getUniqueUsers(delivery.orders);
                    return TabBarView(
                      children: [
                        _buildMainTab(delivery, jagger, users),
                        AdditionalDeliveries(items: delivery.items ?? []),
                      ],
                    );
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(Delivery? delivery, JaggerProvider jagger) {
    final isTracking =
        jagger.subscription != null && !jagger.subscription!.isPaused;

    return SliverAppBar(
      expandedHeight: delivery != null ? 200 : 120,
      floating: false,
      pinned: true,
      backgroundColor: primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async => await init(),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Шинэчлэх',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, primary.withOpacity(0.8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 60),
              child: delivery != null
                  ? _buildDeliveryHeader(delivery, jagger, isTracking)
                  : const SizedBox(),
            ),
          ),
        ),
        title: Text(
          delivery != null ? 'Түгээлт #${delivery.id}' : 'Түгээлтүүд',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            labelColor: primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Захиалгууд'),
              Tab(text: 'Нэмэлт хүргэлт'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryHeader(
      Delivery delivery, JaggerProvider jagger, bool isTracking) {
    final totalOrders = delivery.orders.length;
    final deliveredOrders =
        delivery.orders.where((o) => o.process == 'D').length;
    final progress = totalOrders > 0 ? deliveredOrders / totalOrders : 0.0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (isTracking) ...[
                    _buildLiveBadge(),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    delivery.startedOn != null
                        ? '${delivery.startedOn!.substring(11, 16)}-с эхэлсэн'
                        : 'Эхлээгүй',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$deliveredOrders / $totalOrders захиалга',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildProgressCircle(totalOrders, deliveredOrders),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(int total, int completed) {
    final progress = total > 0 ? completed / total : 0.0;
    final percentage = (progress * 100).toInt();

    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 6,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainTab(
      Delivery delivery, JaggerProvider jagger, List<User> users) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => await init(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActionCard(delivery, jagger),
          const SizedBox(height: 16),
          _buildStatsRow(delivery),
          const SizedBox(height: 16),
          _buildOrderersSection(users, delivery),
        ],
      ),
    );
  }

  Widget _buildActionCard(Delivery delivery, JaggerProvider jagger) {
    final bool started = delivery.startedOn != null;
    final bool trackStopped = started &&
        (jagger.subscription == null || jagger.subscription!.isPaused);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: started
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  started ? Icons.play_circle : Icons.pause_circle,
                  color: started ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      started ? 'Түгээлт явагдаж байна' : 'Түгээлт эхлээгүй',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (started && delivery.startedOn != null)
                      Text(
                        '${delivery.startedOn!.substring(11, 16)}-с эхэлсэн',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (trackStopped) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Байршил дамжуулалт зогссон байна',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (!started)
                Expanded(
                  child: _buildActionButton(
                    label: 'Эхлүүлэх',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onTap: () => askToStart(delivery.id),
                  ),
                ),
              if (trackStopped) ...[
                Expanded(
                  child: _buildActionButton(
                    label: 'Үргэлжлүүлэх',
                    icon: Icons.refresh,
                    color: Colors.amber,
                    onTap: () async => await jagger.tracking(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (started)
                Expanded(
                  child: _buildActionButton(
                    label: 'Дуусгах',
                    icon: Icons.stop,
                    color: Colors.red,
                    onTap: () => askToEnd(delivery, jagger),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Delivery delivery) {
    final pending = delivery.orders.where((o) => o.process == 'O').length;
    final inProgress = delivery.orders.where((o) => o.process == 'P').length;
    final delivered = delivery.orders.where((o) => o.process == 'D').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions,
            label: 'Хүлээгдэж буй',
            value: pending.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_shipping,
            label: 'Хүргэж буй',
            value: inProgress.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Хүргэсэн',
            value: delivered.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderersSection(List<User> users, Delivery delivery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Захиалагчид',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${users.length}',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...users.map(
          (user) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrdererCard(user: user),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Хувиарлагдсан түгээлт байхгүй',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Түгээлт хувиарлагдахад энд харагдана',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: init,
            icon: const Icon(Icons.refresh),
            label: const Text('Шинэчлэх'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
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

  askToStart(int delid) async {
    var j = context.read<JaggerProvider>();
    bool confirmed = await confirmDialog(
      context: context,
      title: 'Түгээлтийг эхлүүлэх үү?',
      message: 'Түгээлтийн үед таны байршлыг хянахыг анхаарна уу!',
    );

    if (confirmed) {
      await Authenticator.saveTrackId(delid);
      await j.startShipment();
    }
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
    if (confirmed) await j.endTrack();
  }
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

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _opacity = 0.4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _controller.addListener(() {
      setState(() {
        _opacity = 0.4 + (_controller.value * 0.6);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.greenAccent.withOpacity(_opacity.clamp(0.0, 1.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
