// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_order_item.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/custom_text_field_icon.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';

class JaggerHomeDetail extends StatelessWidget {
  final List<JaggerOrderItem>? orderItems;
  const JaggerHomeDetail({super.key, required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Түгээлтийн дэлгэрэнгүй',
      ),
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        // final jagger = provider.jaggers[0];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: orderItems!.isNotEmpty
              ? ListView.builder(
                  itemCount: orderItems?.length,
                  itemBuilder: (context, index) {
                    return Card(
                        child: InkWell(
                      onTap: () => {print('shineodko')},
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItems![index].itemName.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Үнэ : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: orderItems![index].itemPrice.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                ]),
                              ),
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(text: 'Тоо ширхэг : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                  TextSpan(text: orderItems![index].itemQty.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                ]),
                              ),
                            ]),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              text: TextSpan(text: 'Нийт дүн : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                TextSpan(text: orderItems![index].itemTotalPrice.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                              ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _dialogBuilder(
                                      context,
                                      'Түгээлтийн зарлага хасах',
                                      orderItems![index].itemId,
                                      false,
                                    );
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.delete,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Хасах',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    _dialogBuilder(
                                      context,
                                      'Түгээлтийн зарлага нэмэх',
                                      orderItems![index].itemId,
                                      true,
                                    );
                                  },
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.add,
                                    size: 24.0,
                                  ),
                                  label: const Text(
                                    'Нэмэх',
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

  Future<void> _dialogBuilder(BuildContext context, String title, int itemId, bool add) {
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
                    dynamic res = await provider.updateItemQTY(itemId, add);
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
