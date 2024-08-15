// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home_detail.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_field_icon.dart';
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
  @override
  void initState() {
    getData();

    startTimer(context);
    super.initState();
  }

  @override
  void dispose() {
    
    timer?.cancel();
    super.dispose();
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
        await jaggerProvider.sendJaggerLocation();
      },
    );
  }

  getData() async {
    try {
      final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      dynamic res = await jaggerProvider.getJaggers();
      if (res['errorType'] == 1) {
       // showSuccessMessage(message: res['message'], context: context);
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
                            ),
                          ),
                        )
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Байршил илгээсэн: $count",
                              style: const TextStyle(color: Colors.amber),
                            ),
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
                                  _jaggerFeedbackDialog(context, 'Түгээлтэнд тайлбар бичих', jagger.id, jagger.jaggerOrders![index].id!);
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
                                      showSuccessMessage(message: res['message'] + 'Цаг: ' + res['data'], context: context);
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
                                      showSuccessMessage(message: res['message'] + 'Цаг: ' + res['data'], context: context);
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
              : const NoResult()
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

  Future<void> _jaggerFeedbackDialog(BuildContext context, String title, int shipId, int itemId) {
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
              height: 140,
              child: Form(
                key: provider.formKey,
                child: Column(children: [
                  CustomTextFieldIcon(
                    hintText: "Тайлбар оруулна уу...",
                    prefixIconData: const Icon(Icons.comment_outlined),
                    validatorText: "Тайлбар оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.feedback,
                    isNumber: false,
                    maxLine: 4,
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
                    dynamic res = await provider.setFeedback(shipId, itemId);
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
