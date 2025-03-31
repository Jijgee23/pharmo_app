import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/delivery.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/location_service.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/views/main/delivery_man/orderer.dart';
import 'package:pharmo_app/views/main/pharmacy/promotion/marked_promo_dialog.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/loader/waving_animation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  Position? myPos;

  fetch() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        setLoading(true);
        final pref = await SharedPreferences.getInstance();
        int? shipId = pref.getInt('onDeliveryId');
        if (shipId != null) {
          LocationService().startTracking(shipId);
        }
        Future.microtask(() => context.read<JaggerProvider>().getDeliveries());
        Future.microtask(
            () => context.read<JaggerProvider>().getCurrentLocation());
        Timer(const Duration(seconds: 1), () {
          Future.microtask(() =>
              context.read<JaggerProvider>().getDeliveryLocation(context));
        });
        setLoading(false);
      },
    );
  }

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> markers = {};

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
  var st =
      const TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 16);
  refresh() async {
    setLoading(true);
    await fetch();
  }

  bool trafficEnabled = false;
  toggleTraffic() {
    setState(() {
      trafficEnabled = !trafficEnabled;
    });
  }

  double zoomIndex = 14;
  zoomIn() {
    setState(() {
      zoomIndex = zoomIndex + 1.0;
    });
    mapController.animateCamera(CameraUpdate.zoomTo(zoomIndex));
  }

  zoomOut() {
    setState(() {
      zoomIndex = zoomIndex - 1.0;
    });
    mapController.animateCamera(CameraUpdate.zoomTo(zoomIndex));
  }

  MapType mapType = MapType.terrain;

  void toggleView() {
    setState(() {
      const mapTypes = [
        MapType.terrain,
        MapType.satellite,
        MapType.hybrid,
        MapType.normal
      ];
      mapType = mapTypes[(mapTypes.indexOf(mapType) + 1) % mapTypes.length];
    });
  }

  double aspectRatio = 3 / 2;
  toggleZoom() {
    setState(
      () {
        if (aspectRatio == 3 / 2) {
          aspectRatio = 2.3 / 4;
          physics = NeverScrollableScrollPhysics();
        } else {
          aspectRatio = 3 / 2;
          physics = AlwaysScrollableScrollPhysics();
        }
      },
    );
  }

  ScrollController scrollController = ScrollController();
  ScrollPhysics physics = AlwaysScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    Color trafficColor = trafficEnabled ? Colors.green : Colors.grey;
    Color aspectColor = aspectRatio == 2.3 / 4 ? Colors.green : Colors.grey;
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) {
        final dels = jagger.delivery;
        return DataScreen(
          loading: loading,
          empty: false,
          onRefresh: () async => await refresh(),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: physics,
            child: Column(
              spacing: 10,
              children: [
                if (jagger.lastPosition != null)
                  map(jagger, aspectColor, trafficColor),
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

  InkWell map(JaggerProvider jagger, Color aspectColor, Color trafficColor) {
    return InkWell(
      onTap: () => print('tapped'),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(),
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _onMapCreated(controller),
                  markers: markers,
                  trafficEnabled: trafficEnabled,
                  mapType: mapType,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(jagger.lastPosition!.latitude,
                        jagger.lastPosition!.longitude),
                    zoom: zoomIndex,
                  ),
                  polylines: {
                    Polyline(
                        polylineId: PolylineId("route"),
                        points: jagger.routeCoords,
                        color: neonBlue,
                        width: 5),
                  },
                ),
                mapIcon(() => toggleZoom(), Icons.fullscreen, 10, aspectColor),
                mapIcon(() => toggleTraffic(), Icons.traffic, 55, trafficColor),
                mapIcon(
                    () => toggleView(), Icons.remove_red_eye, 100, neonBlue),
                mapIcon(() => zoomIn(), Icons.add, 145, black),
                mapIcon(() => zoomOut(), Icons.remove, 190, black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  mapIcon(
      GestureTapCallback ontap, IconData icon, double fromLeft, Color iColor) {
    return Positioned(
      bottom: 10,
      left: fromLeft,
      child: InkWell(
        onTap: ontap,
        child: Container(
          padding: EdgeInsets.all(7.5),
          decoration: BoxDecoration(
              color: white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: grey500, blurRadius: 1)]),
          child: Icon(icon, color: iColor),
        ),
      ),
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
          endingWidget(del, jagger),
        ],
      ),
    );
  }

  Widget startingWidget(Delivery del, JaggerProvider jagger) {
    bool started = del.startedOn != null;
    return Container(
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
          if (started)
            const WavingAnimation(
                assetPath: 'assets/stickers/truck_animation.gif', dots: true),
          if (started) Text('Түгээлт эхлэсэн: ${del.startedOn}', style: st),
        ],
      ),
    );
  }

  Row endingWidget(Delivery del, JaggerProvider jagger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
  }

  askTracking(int id) {
    askDialog(
      context,
      () {
        LocationService().startTracking(id);
        Navigator.pop(context);
      },
      'Хүргэлтийн үед л таний байршлийг хянахыг анхаарна уу!',
      [],
    );
  }

  askEnd(Delivery del, JaggerProvider jagger) {
    List<Order>? unDeliveredOrders =
        del.orders.where((t) => t.process == 'O').toList();
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
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: black),
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
                      text: '${e.orderNo} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const TextSpan(
                  text: ') Та түгээлтийг дуусгахдаа итгэлтэй байна уу?'),
            ],
          ),
        ),
    ]);
  }

  askStart(Delivery del, JaggerProvider jagger) async {
    final s = await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    bool location = await Geolocator.isLocationServiceEnabled();
    if (!location) {
      await Geolocator.requestPermission();
      if (s == LocationPermission.deniedForever) {
        getMessage();
      }
    } else {
      if (s == LocationPermission.always) {
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
          [Text('Хүргэлтийн үед л таний байршлийг хянахыг анхаарна уу!')],
        );
      } else {
        getMessage();
      }
    }
  }

  Center noResult() {
    return Center(
        child: Image.asset('assets/icons/not-found.png',
            width: Sizes.width * 0.3));
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
        child: Center(
          child: loading
              ? const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(white))
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
