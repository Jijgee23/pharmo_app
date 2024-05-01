// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/tabs/jagger_home_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/custom_text_field_icon.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class HomeJagger extends StatefulWidget {
  const HomeJagger({super.key});
  @override
  State<HomeJagger> createState() => _HomeJaggerState();
}

int count = 0;
Timer? timer;

class _HomeJaggerState extends State<HomeJagger> {
  @override
  void initState() {
    super.initState();
    getData();
    startTimer();
  }

  void startTimer() {
    final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        setState(() {
          count++;
        });
        await jaggerProvider.getLocatiion();
        await jaggerProvider.sendJaggerLocation();
      },
    );
  }

  getData() async {
    try {
      final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      dynamic res = await jaggerProvider.getJaggers();
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jagger = (provider.jaggers.isNotEmpty) ? provider.jaggers[0] : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: jagger != null && jagger.jaggerOrders != null && jagger.jaggerOrders!.isNotEmpty
              ? ListView.builder(
                  itemCount: jagger.jaggerOrders?.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: InkWell(
                      onTap: () async => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JaggerHomeDetail(
                                      index: index,
                                    )))
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Counter reached $count"),
                            Text(
                              jagger.jaggerOrders![index].user.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Захиалгын дугаар : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: jagger.jaggerOrders![index].orderNo.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Төлөв : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: jagger.jaggerOrders![index].process.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                ]),
                              ),
                              IconButton(
                                iconSize: 20,
                                icon: const Icon(Icons.text_increase_outlined),
                                onPressed: () {
                                  // ...
                                },
                              ),
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton.filledTonal(
                                  iconSize: 25,
                                  color: Colors.green,
                                  icon: const Icon(
                                    Icons.add,
                                  ),
                                  onPressed: () {
                                    _dialogBuilder(context, 'Түгээлтийн зарлага нэмэх');
                                  },
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    dynamic res = await provider.endShipment(jagger.id);
                                    if (res['errorType'] == 1) {
                                      showSuccessMessage(message: res['message'] + ' ' + res['data'], context: context);
                                    } else {
                                      showFailedMessage(message: res['message'], context: context);
                                    }
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.close,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Дуусгах',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    dynamic res = await provider.startShipment(jagger.id);
                                    if (res['errorType'] == 1) {
                                      showSuccessMessage(message: res['message'] + ' ' + res['data'], context: context);
                                    } else {
                                      showFailedMessage(message: res['message'], context: context);
                                    }
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.start,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Эхлүүлэх',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
                  })
              : const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "Түгээлтийн мэдээлэл олдсонгүй ...",
                    ),
                  ),
                ),
        );
      }),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String title) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            content: SizedBox(
              height: 190,
              child: Form(
                key: provider.formKey,
                child: Column(children: [
                  CustomTextFieldIcon(
                    hintText: "Дүн оруулна уу...",
                    prefixIconData: const Icon(Icons.numbers_rounded),
                    validatorText: "Дүн оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.amount,
                    onChanged: provider.validateAmount,
                    errorText: provider.amountVal.error,
                    isNumber: true,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFieldIcon(
                    hintText: "Тайлбар оруулна уу...",
                    prefixIconData: const Icon(Icons.comment_outlined),
                    validatorText: "Тайлбар оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.note,
                    onChanged: provider.validateNote,
                    errorText: provider.noteVal.error,
                    isNumber: false,
                  ),
                ]),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хаах'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Хадгалах'),
                onPressed: () async {
                  if (provider.formKey.currentState!.validate()) {
                    dynamic res = await provider.addExpenseAmount();
                    if (res['errorType'] == 1) {
                      showSuccessMessage(message: res['message'], context: context);
                      Navigator.of(context).pop();
                    } else {
                      showFailedMessage(message: res['message'], context: context);
                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
