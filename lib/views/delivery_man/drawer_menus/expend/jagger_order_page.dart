// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_field_icon.dart';
import 'package:provider/provider.dart';

class JaggerOrderPage extends StatefulWidget {
  const JaggerOrderPage({super.key});
  @override
  State<JaggerOrderPage> createState() => _JaggerOrderPageState();
}

class _JaggerOrderPageState extends State<JaggerOrderPage> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      final jaggerProvider =
          Provider.of<JaggerProvider>(context, listen: false);
      dynamic res = await jaggerProvider.getJaggerOrders();
      if (res['errorType'] == 1) {
        showSuccessMessage(message: res['message'], context: context);
      } else {
        showFailedMessage(message: res['message'], context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jaggerOrders =
            (provider.jaggerOrders.isNotEmpty) ? provider.jaggerOrders : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Column(
            children: [
              jaggerOrders != null && jaggerOrders.isNotEmpty
                  ? Expanded(
                      flex: 8,
                      child: ListView.builder(
                          itemCount: jaggerOrders.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 2.5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                splashColor: AppColors.soft4,
                                onTap: () => {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          jaggerOrders[index].note.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              _dialogBuilder(
                                                  context, jaggerOrders[index]);
                                              provider.amount =
                                                  TextEditingController(
                                                      text: jaggerOrders[index]
                                                          .amount
                                                          .toString());
                                              provider.note =
                                                  TextEditingController(
                                                      text: jaggerOrders[index]
                                                          .note);
                                            },
                                            child: const Text(
                                              'Засах',
                                              style: TextStyle(
                                                  color: AppColors.main),
                                            ))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    myRow('Дүн:',
                                        '${jaggerOrders[index].amount} ₮'),
                                    myRow(
                                        'Огноо:',
                                        jaggerOrders[index]
                                            .createdOn
                                            .toString()),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )
                  : const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Түгээлтийн мэдээлэл олдсонгүй ...",
                        ),
                      ),
                    ),
            ],
          ),
        );
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
            style: TextStyle(color: Colors.grey.shade800),
          ),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.cleanBlack)),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, JaggerExpenseOrder order) {
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
              child: Form(
                key: provider.formKey,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const Text('Түгээлтийн зарлага хасах',
                        style: TextStyle(fontSize: 14)),
                    Constants.boxV10,
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
                    Constants.boxV10,
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
                    Constants.boxV10,
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          dialogButton(
                              onTap: () => Navigator.of(context).pop(),
                              title: 'Хаах',
                              color: AppColors.main),
                          dialogButton(
                              onTap: () async {
                                if (provider.formKey.currentState!.validate()) {
                                  dynamic res = await provider
                                      .editExpenseAmount(order.id);
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
                              color: AppColors.main)
                        ])
                  ]),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  dialogButton(
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
