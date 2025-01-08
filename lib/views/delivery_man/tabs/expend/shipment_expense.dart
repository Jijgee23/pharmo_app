import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/bottomSheet/mySheet.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
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
    super.initState();
    init();
  }

  init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
      jaggerProvider.getExpenses();
    });
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JaggerProvider>(
        builder: (context, provider, _) {
          final jaggerOrders =
              provider.jaggerOrders.isNotEmpty ? provider.jaggerOrders : null;
          return jaggerOrders != null && jaggerOrders.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      ...jaggerOrders.map((el) => expenseBuilder(el)),
                      SizedBox(height: MediaQuery.of(context).size.height * .08)
                    ],
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
        color: card,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 3)
        ],
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
                  fontSize1: 12,
                  fontSize2: 14,
                  t1: 'Тайлбар',
                  t2: el.note.toString()),
              Col(t1: 'Дүн', t2: toPrice(el.amount!.toString())),
              InkWell(
                onTap: () {
                  note.text = el.note!;
                  amount.text = el.amount.toString();
                  editExpense(context, el);
                },
                child: const Text(
                  'Засах',
                  style:
                      TextStyle(color: secondary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Col(t1: 'Огноо', t2: el.createdOn.toString())
        ],
      ),
    );
  }

  editExpense(BuildContext context, JaggerExpenseOrder order) {
    return mySheet(
      title: 'Түгээлтийн зарлага засах',
      children: [
        CustomTextField(controller: note, hintText: 'Note'),
        CustomTextField(
          controller: amount,
          hintText: 'Дүн',
          keyboardType: TextInputType.number,
        ),
        Consumer<JaggerProvider>(
          builder: (context, p, child) => CustomButton(
            text: 'Хадгалах',
            ontap: () async {
              if (p.formKey.currentState!.validate()) {
                dynamic res = await p.editExpenseAmount(order.id);
                if (res['errorType'] == 1) {
                  message(res['message']);
                  Navigator.of(context).pop();
                } else {
                  message(res['message']);
                }
              }
            },
          ),
        )
      ],
    );
  }
}
