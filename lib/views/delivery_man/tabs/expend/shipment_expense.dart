import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/others/dialog_button.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class ShipmentExpensePage extends StatefulWidget {
  const ShipmentExpensePage({super.key});
  @override
  State<ShipmentExpensePage> createState() => _ShipmentExpensePageState();
}

class _ShipmentExpensePageState extends State<ShipmentExpensePage> {
  late JaggerProvider jaggerProvider;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      jaggerProvider.getExpenses();
    });
    super.initState();
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: Image.asset('assets/icons/wallet.png'),
        onPressed: () => addExpense(),
      ),
      body: Consumer<JaggerProvider>(
        builder: (context, provider, _) {
          final jaggerOrders =
              provider.jaggerOrders.isNotEmpty ? provider.jaggerOrders : null;
          return jaggerOrders != null && jaggerOrders.isNotEmpty
              ? Scrollbar(
                  thickness: 1.5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...jaggerOrders.map((el) => expenseBuilder(el)),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * .08)
                      ],
                    ),
                  ),
                )
              : const Center(child: NoResult());
        },
      ),
    );
  }

  Widget expenseBuilder(JaggerExpenseOrder el) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0XFFEDF2F7),
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 3)],
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Col(
                  cxs: CrossAxisAlignment.center,
                  fontSize1: 12,
                  fontSize2: 14,
                  t1: 'Тайлбар',
                  t2: el.note.toString()),
              Col(
                  cxs: CrossAxisAlignment.center,
                  t1: 'Дүн',
                  t2: toPrice(el.amount!.toString())),
              InkWell(
                onTap: () {
                  note.text = el.note!;
                  amount.text = el.amount.toString();
                  editExpense(context, el);
                },
                child: const Text(
                  'Засах',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Col(
              cxs: CrossAxisAlignment.center,
              t1: 'Огноо',
              t2: el.createdOn.toString())
        ],
      ),
    );
  }

  final bd = BoxDecoration(
      borderRadius: BorderRadius.circular(10), color: Colors.white);
  final pad = const EdgeInsets.all(10);

  addExpenseAmount() {
    Future(() async {
      await jaggerProvider.addExpense(note.text, amount.text, context);
    }).whenComplete(() async {
      await jaggerProvider.getExpenses();
      amount.clear();
      note.clear();
      Navigator.pop(context);
    });
  }

  addExpense() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: dialogChild(
              title: 'Түгээлтийн зарлага нэмэх',
              children: [
                CustomTextField(controller: note, hintText: 'Тайлбар'),
                Constants.boxV10,
                CustomTextField(
                  controller: amount,
                  hintText: 'Дүн',
                  keyboardType: TextInputType.number,
                ),
              ],
              submit: addExpenseAmount),
        );
      },
    );
  }

  editExpense(BuildContext context, JaggerExpenseOrder order) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<JaggerProvider>(builder: (context, provider, _) {
          return Dialog(
            child: dialogChild(
                title: 'Түгээлтийн зарлага засах',
                children: [
                  CustomTextField(controller: note, hintText: 'Note'),
                  Constants.boxV10,
                  CustomTextField(
                    controller: amount,
                    hintText: 'Дүн',
                    keyboardType: TextInputType.number,
                  ),
                ],
                submit: () async {
                  if (provider.formKey.currentState!.validate()) {
                    dynamic res = await provider.editExpenseAmount(order.id);
                    if (res['errorType'] == 1) {
                      message(message: res['message'], context: context);
                      Navigator.of(context).pop();
                    } else {
                      message(message: res['message'], context: context);
                    }
                  }
                }),
          );
        });
      },
    );
  }

  dialogChild({
    required String title,
    required List<Widget> children,
    required Function() submit,
  }) {
    return Container(
      decoration: bd,
      padding: pad,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Constants.boxV10,
            ...children,
            Constants.boxV10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DialogBtn(),
                DialogBtn(title: 'Хадгалах', onTap: submit),
              ],
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
          Text(title, style: TextStyle(color: Colors.grey.shade800)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.cleanBlack)),
        ],
      ),
    );
  }
}
