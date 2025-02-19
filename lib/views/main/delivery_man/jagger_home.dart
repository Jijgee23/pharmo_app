import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_widget.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/waving_animation.dart';
import 'package:provider/provider.dart';

class HomeJagger extends StatefulWidget {
  const HomeJagger({super.key});
  @override
  State<HomeJagger> createState() => _HomeJaggerState();
}

class _HomeJaggerState extends State<HomeJagger> {
  late JaggerProvider jaggerProvider;
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  initState() {
    super.initState();
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    fetch();
  }

  fetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setLoading(true);
      await jaggerProvider.getDeliveries();
      await jaggerProvider.getLocation(context);
      if (mounted) setLoading(false);
    });
  }

  startShipment(int shipmentId) async {
    setLoading(true);
    await jaggerProvider.startShipment(shipmentId, context);
    if (mounted) setLoading(false);
  }

  endShipment(int shipmentId, bool? force) async {
    setLoading(true);
    await jaggerProvider.endShipment(shipmentId, context);
    if (mounted) setLoading(false);
  }

  var pad = const EdgeInsets.only(left: 5, top: 5);
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
                      return deliveryContaier(del);
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

  Container deliveryContaier(Delivery del) {
    return Container(
      padding: padding15,
      width: double.maxFinite,
      decoration: BoxDecoration(color: primary, borderRadius: border20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          startingWidget(del),
          Padding(padding: pad, child: Text('Захиалгууд:', style: st)),
          const SizedBox(height: 10),
          ...del.orders.map((order) => DeliveryWidget(order: order)),
          endingWidget(del),
        ],
      ),
    );
  }

  Row endingWidget(Delivery del) {
    return Row(
      children: [
        (del.startedOn != null && del.endedOn == null)
            ? button(
                title: 'Түгээлт дуусгах',
                color: theme.primaryColor,
                onTap: () => endShipment(del.id, false))
            : const SizedBox(),
        (del.endedOn == null)
            ? const SizedBox()
            : Padding(padding: pad, child: Text('Түгээлт дууссан: ${del.endedOn!}', style: st)),
      ],
    );
  }

  Widget startingWidget(Delivery del) {
    bool deliveryStarted = del.startedOn != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!deliveryStarted)
          button(
              title: 'Түгээлт эхлүүлэх',
              color: theme.primaryColor,
              onTap: () => Future(() async {
                    startShipment(del.id);
                    await jaggerProvider.getDeliveries();
                  })),
        if (deliveryStarted)
          Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const WavingAnimation(
                  assetPath: 'assets/stickers/truck_animation.gif', dots: true)),
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
                ? const CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(white))
                : text(title, color: white)),
      ),
    );
  }
}
