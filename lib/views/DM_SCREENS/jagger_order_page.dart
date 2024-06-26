// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
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
      final jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      dynamic res = await jaggerProvider.getJaggerOrders();
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
      appBar: const DMAppBar(
        title: 'Түгээлтийн жагсаалт',
      ),
      body: Consumer<JaggerProvider>(builder: (context, provider, _) {
        final jaggerOrders = (provider.jaggerOrders.isNotEmpty) ? provider.jaggerOrders : null;
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
                            return Card(
                                child: InkWell(
                              onTap: () => {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => JaggerHomeDetail(
                                //               orderItems: jagger.jaggerOrders![index].jaggerOrderItems,
                                //             )))
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      jaggerOrders[index].note.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(text: 'Дүн : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                          TextSpan(text: '${jaggerOrders[index].amount} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.red)),
                                        ]),
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(text: 'Огноо : ', style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0), children: [
                                          TextSpan(text: jaggerOrders[index].createdOn.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                                        ]),
                                      ),
                                    ]),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            _dialogBuilder(context, 'Түгээлтийн зарлага засах', jaggerOrders[index]);
                                            provider.amount = TextEditingController(text: jaggerOrders[index].amount.toString());
                                            provider.note = TextEditingController(text: jaggerOrders[index].note);
                                          },
                                          icon: const Icon(
                                            color: Colors.white,
                                            Icons.edit,
                                            size: 24.0,
                                          ),
                                          label: const Text(
                                            'Засах',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ));
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

  Future<void> _dialogBuilder(BuildContext context, String title, JaggerExpenseOrder order) {
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
                    dynamic res = await provider.editExpenseAmount(order.id);
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
