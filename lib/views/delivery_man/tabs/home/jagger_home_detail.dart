// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
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
        final orderItems = (provider.jaggers[0].jaggerOrders != null &&
                provider.jaggers[0].jaggerOrders!.isNotEmpty &&
                provider.jaggers[0].jaggerOrders![index].jaggerOrderItems !=
                    null)
            ? provider.jaggers[0].jaggerOrders![index].jaggerOrderItems
            : null;
        final jagger = provider.jaggers[0];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: orderItems != null && orderItems.isNotEmpty
              ? ListView.builder(
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          row(
                              title: 'Нэр:',
                              value: orderItems[index].itemName.toString()),
                          row(
                              title: 'Тоо ширхэг:',
                              value: orderItems[index].itemQty.toString()),
                          row(
                              title: 'Үнэ:',
                              value: '${orderItems[index].itemPrice} ₮'),
                          row(
                              title: 'Нийт дүн:',
                              value: '${orderItems[index].itemTotalPrice} ₮'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => _dialogBuilder(
                                    context,
                                    orderItems[index].itemId,
                                    orderItems[index].iQty,
                                    true),
                                child: const Text(
                                  'Буцаалт хийх',
                                  style: TextStyle(color: AppColors.main),
                                ),
                              ),
                              InkWell(
                                onTap: () => _jaggerFeedbackDialog(context,
                                    jagger.id, orderItems[index].itemId),
                                child: const Text(
                                  'Нэмэх',
                                  style: TextStyle(color: AppColors.main),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
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

  row({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade900),
          ),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, int itemId, int iqty, bool add) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              padding: const EdgeInsets.all(10),
              child: Form(
                key: provider.formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const Text('Түгээлтийн бараанаас буцаалт хийх',
                        style: TextStyle(fontSize: 14)),
                    Constants.boxV10,
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
                    Constants.boxV10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dialogButton(
                            onTap: () => Navigator.of(context).pop(),
                            title: 'Хаах',
                            color: AppColors.main),
                        dialogButton(
                            onTap: () async {
                              if (provider.formKey.currentState!.validate()) {
                                dynamic res = await provider.updateItemQTY(
                                    itemId, iqty, add);
                                if (res['errorType'] == 1) {
                                  showSuccessMessage(
                                      message: res['message'],
                                      context: context);
                                  Navigator.of(context).pop();
                                } else {
                                  showFailedMessage(
                                      message: res['message'],
                                      context: context);
                                }
                              }
                            },
                            title: 'Хадгалах',
                            color: AppColors.main),
                      ],
                    )
                  ]),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _jaggerFeedbackDialog(
      BuildContext context, int shipId, int itemId) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return Dialog(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              padding: const EdgeInsets.all(10),
              child: Form(
                key: provider.formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const Text('Түгээлтийн бараанаас нэмж авах',
                        style: TextStyle(fontSize: 14)),
                    Constants.boxV10,
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
                    Constants.boxV10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dialogButton(
                            onTap: () => Navigator.of(context).pop(),
                            title: 'Хаах',
                            color: AppColors.main),
                        dialogButton(
                            onTap: () async {
                              if (provider.formKey.currentState!.validate()) {
                                dynamic res =
                                    await provider.setFeedback(shipId, itemId);
                                if (res['errorType'] == 1) {
                                  showSuccessMessage(
                                      message: res['message'],
                                      context: context);
                                  Navigator.of(context).pop();
                                } else {
                                  showFailedMessage(
                                      message: res['message'],
                                      context: context);
                                }
                              }
                            },
                            title: 'Хадгалах',
                            color: AppColors.main),
                      ],
                    )
                  ]),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Container dialogButton(
      {required GestureTapCallback onTap, String? title, Color? color}) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary),
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
