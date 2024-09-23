// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
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
  void initState() {
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    jaggerProvider.getJaggers();
    homeProvider.getPosition();
    startTimer(context);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  startShipment(int shipmentId) async {
    await jaggerProvider.startShipment(shipmentId,
        homeProvider.currentLatitude!, homeProvider.currentLongitude!, context);
  }

  endShipment(int shipmentId) async {
    await jaggerProvider.endShipment(shipmentId, homeProvider.currentLatitude!,
        homeProvider.currentLongitude!, false, context);
  }

  Future startTimer(BuildContext context) async {
    final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    timer = Timer.periodic(
      const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jagger =
            (provider.jaggers.isNotEmpty) ? provider.jaggers[0] : null;
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: (jagger != null &&
                    jagger.jaggerOrders != null &&
                    jagger.jaggerOrders!.isNotEmpty)
                ? ListView.builder(
                    itemCount: jagger.jaggerOrders?.length,
                    itemBuilder: (context, index) {
                      final order = jagger.jaggerOrders?[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JaggerHomeDetail(
                                index: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              myRow(
                                'Байршил илгээсэн:',
                                count.toString(),
                              ),
                              myRow(
                                'Захиалагч:',
                                order!.user.toString(),
                              ),
                              myRow(
                                'Захиалгын дугаар:',
                                order.orderNo.toString(),
                              ),
                              myRow('Төлөв', order.process.toString()),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.5),
                                child: InkWell(
                                  onTap: () async {
                                    await _addNote(
                                        context, order.id!, jagger.id);
                                  },
                                  child: const Text(
                                    'Тайлбар бичих',
                                    style: TextStyle(
                                      color: AppColors.main,
                                    ),
                                  ),
                                ),
                              ),
                              buttonRow(
                                button(
                                    title: 'Эхлүүлэх',
                                    color: AppColors.secondary,
                                    onTap: () => startShipment(jagger.id),
                                    icon: Icons.arrow_right_rounded),
                                button(
                                    title: 'Дуусгах',
                                    color: AppColors.main,
                                    onTap: () => endShipment(jagger.id),
                                    icon: Icons.close),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                : const NoResult());
      }),
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

  button(
      {required String title,
      required Color color,
      required GestureTapCallback onTap,
      IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 20),
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: AppColors.cleanWhite,
              ),
              Constants.boxH10,
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
                            await provider.addnote(shipId, itemId, context)),
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
