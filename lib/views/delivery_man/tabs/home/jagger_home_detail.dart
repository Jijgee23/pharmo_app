// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_field_icon.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:provider/provider.dart';

class JaggerHomeDetail extends StatelessWidget {
  final int index;
  const JaggerHomeDetail({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DMAppBar(
        title: 'Түгээлтийн дэлгэрэнгүй',
      ),
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final orderItems =
            (provider.jaggers[0].jaggerOrders != null && provider.jaggers[0].jaggerOrders!.isNotEmpty && provider.jaggers[0].jaggerOrders![index].jaggerOrderItems != null) ? provider.jaggers[0].jaggerOrders![index].jaggerOrderItems : null;
        final jagger = provider.jaggers[0];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: orderItems != null && orderItems.isNotEmpty
              ? ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: InkWell(
                      onTap: () => {},
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItems[index].itemName.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // IconButton.filledTonal(
                                    //   iconSize: 25,
                                    //   color: Colors.red,
                                    //   icon: const Icon(
                                    //     Icons.remove,
                                    //   ),
                                    //   onPressed: () {
                                    //     _dialogBuilder(
                                    //       context,
                                    //       'Түгээлтийн зарлага хасах',
                                    //       orderItems[index].itemId,
                                    //       orderItems[index].iQty,
                                    //       false,
                                    //     );
                                    //   },
                                    // ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(text: 'Тоо ширхэг : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                          TextSpan(text: orderItems[index].itemQty.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                        ]),
                                      ),
                                    ),
                                    IconButton.filledTonal(
                                      iconSize: 25,
                                      color: Colors.green,
                                      icon: const Icon(
                                        Icons.edit,
                                      ),
                                      onPressed: () {
                                        _dialogBuilder(
                                          context,
                                          'Түгээлтийн зарлага нэмэх',
                                          orderItems[index].itemId,
                                          orderItems[index].iQty,
                                          true,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                IconButton(
                                  iconSize: 20,
                                  icon: const Icon(Icons.text_increase_outlined),
                                  onPressed: () {
                                    _jaggerFeedbackDialog(context, 'Түгээлтийн зарлага хасах', jagger.id, orderItems[index].itemId);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: '${orderItems[index].itemPrice} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                ]),
                              ),
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Нийт дүн : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: '${orderItems[index].itemTotalPrice} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.red)),
                                ]),
                              ),
                            ]),
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

  Future<void> _dialogBuilder(BuildContext context, String title, int itemId, int iqty, bool add) {
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
              height: 90,
              child: Form(
                key: provider.formKey,
                child: Column(children: [
                  CustomTextFieldIcon(
                    hintText: "Тоо хэмжээ оруулна уу...",
                    prefixIconData: const Icon(Icons.numbers_rounded),
                    validatorText: "Тоо хэмжээ оруулна уу.",
                    fillColor: Colors.white,
                    expands: false,
                    controller: provider.rQty,
                    onChanged: provider.validateRqty,
                    errorText: provider.rqtyVal.error,
                    isNumber: true,
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
                    dynamic res = await provider.updateItemQTY(itemId, iqty, add);
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
              height: 190,
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
                    maxLine: 3,
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
