// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/ship.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home_detail.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/dialog_button.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class HomeJagger extends StatefulWidget {
  const HomeJagger({super.key});
  @override
  State<HomeJagger> createState() => _HomeJaggerState();
}

int count = 0;
Timer? timer;
bool mounted = true;

class _HomeJaggerState extends State<HomeJagger> {
  late JaggerProvider jaggerProvider;
  late HomeProvider homeProvider;
  @override
  initState() {
    homeProvider = Provider.of(context, listen: false);
    jaggerProvider = Provider.of(context, listen: false);
    jaggerProvider.fetchJaggers();
    super.initState();
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  startShipment(int shipmentId) async {
    await jaggerProvider.startShipment(shipmentId,
        homeProvider.currentLatitude!, homeProvider.currentLongitude!, context);
  }

  endShipment(int shipmentId, bool? force) async {
    await jaggerProvider.endShipment(shipmentId, homeProvider.currentLatitude!,
        homeProvider.currentLongitude!, force!, context);
  }

  Future startTimer(BuildContext context) async {
    final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        if (mounted) {
          setState(() {
            count++;
          });
        }
        await jaggerProvider.getLocation(context);
        await jaggerProvider.sendJaggerLocation(context);
      },
    );
  }

  Future endTimer(BuildContext context) async {
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        if (mounted) {
          setState(() {
            count = 0;
          });
        }
      },
    );
  }

  refreshScreen() async {
    await jaggerProvider.getJaggers();
  }

  var pad = const EdgeInsets.only(left: 5, top: 5);
  var st =
      const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() async {
        await jaggerProvider.fetchJaggers();
      }),
      child: Consumer<JaggerProvider>(
        builder: (context, jagger, child) {
          final ships = jagger.ships;
          return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: (ships.isNotEmpty)
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: ships.map((e) => shipment(e: e)).toList(),
                      ),
                    )
                  : const NoResult());
        },
      ),
    );
  }

  Widget shipment({required Ship e}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [Constants.defaultShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getStartButton(e: e),
          Padding(
              padding: pad,
              child: const Text(
                'Түгээлтийн захиалгууд',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          ...e.inItems.map((order) => orderItem(e, order)),
          getEndButton(e: e),
        ],
      ),
    );
  }

  Widget getStartButton({required Ship e}) {
    if (e.startTime == null) {
      return button(
        title: 'Түгээлт эхлүүлэх',
        color: AppColors.primary,
        iconName: 'truck',
        onTap: () => Future(() async {
          debugPrint(e.startTime);
          startShipment(e.id);
          startTimer(context);
          await jaggerProvider.fetchJaggers();
        })
      );
    } else {
      return Padding(
        padding: pad,
        child: Text('Түгээлт эхлэсэн: ${e.startTime}', style: st),
      );
    }
  }

  Widget getEndButton({required Ship e}) {
    if (e.endTime == null && e.startTime == null) {
      return const SizedBox();
    } else if (e.endTime == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: button(
          title: 'Түгээлт дуусгах',
          color: AppColors.primary,
          iconName: 'box',
          onTap: () => Future(() async {
            endShipment(e.id, false);
            endTimer(context);
            // print(e.endTime);
          }),
          onSecondaryTap: () => Future(()async {
            endShipment(e.id, true);
            endTimer(context);
            await jaggerProvider.fetchJaggers();
            // print(e.endTime);
          })
        ),
      );
    } else {
      return Padding(
        padding: pad,
        child: Text('Түгээлт дууссан: ${e.endTime}', style: st),
      );
    }
  }

  Widget orderItem(Ship e, ShipOrders order) {
    return InkWell(
      onTap: () => goto(JaggerHomeDetail(order: order, shipId: e.id), context),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            myRow('Захиалагч:', order.user.toString()),
            myRow('Захиалгын дугаар:', order.orderNo.toString()),
            myRow('Салбар:', order.branch!),
            myRow('Төлөв', getOrderProcess(order.process!)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2.5),
              child: InkWell(
                onTap: () async => await _addNote(context, e.id, order.id),
                child: const Text(
                  'Тайлбар бичих',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  myRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  buttonRow(Widget w1, Widget w2) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          w1,
          w2,
        ],
      ),
    );
  }

  button({
    required String title,
    required Color color,
    required GestureTapCallback onTap,
    GestureTapCallback? onSecondaryTap,
    required String iconName,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onSecondaryTap: onSecondaryTap,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('assets/icons/$iconName.png',
                  height: 24, color: Colors.white),
              Text(
                title,
                style: const TextStyle(color: AppColors.cleanWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addNote(BuildContext context, int shipId, int itemId) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(children: [
                  const Text('Түгээлтэнд тайлбар бичих',
                      style: TextStyle(fontSize: 14)),
                  Constants.boxV10,
                  CustomTextField(
                      controller: provider.feedback, hintText: 'Тайлбар'),
                  Constants.boxV10,
                  buttonRow(
                    const DialogBtn(),
                    DialogBtn(
                      title: 'Хадгалах',
                      onTap: () async =>
                          await provider.addnote(shipId, itemId, context).then(
                                (e) => Navigator.pop(context),
                              ),
                    ),
                  )
                ]),
              ),
            ),
          );
        });
      },
    );
  }

  dialogButton({required Function() onTap, String? title}) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child:
              Text(title!, style: const TextStyle(color: AppColors.cleanWhite)),
        ),
      ),
    );
  }
}
