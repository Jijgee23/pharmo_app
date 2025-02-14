import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/jagger_expense_order.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/loader/data_screen.dart';
import 'package:pharmo_app/widgets/ui_help/col.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class ShipmentExpensePage extends StatefulWidget {
  const ShipmentExpensePage({super.key});
  @override
  State<ShipmentExpensePage> createState() => _ShipmentExpensePageState();
}

class _ShipmentExpensePageState extends State<ShipmentExpensePage> {
  late JaggerProvider jaggerProvider;
  bool loading = false;
  setLoading(bool n) {
    setState(() {
      loading = n;
    });
  }

  @override
  void initState() {
    setLoading(true);
    super.initState();
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetch();
    });
  }

  fetch() async {
    await jaggerProvider.getExpenses();

    if (mounted) setLoading(false);
  }

  refresh() {
    setLoading(true);
    fetch();
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, provider, _) {
        final expenses = provider.expenses;
        bool empty = expenses.isEmpty;
        return DataScreen(
          loading: loading,
          empty: empty,
          onRefresh: () => refresh(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...expenses.map((el) => expenseBuilder(el)),
                SizedBox(height: MediaQuery.of(context).size.height * .08)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget expenseBuilder(JaggerExpenseOrder el) {
    return Container(
      decoration: BoxDecoration(borderRadius: border20, gradient: pinkGradinet),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: padding15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Col(fontSize1: 12, fontSize2: 14, t1: 'Тайлбар', t2: el.note.toString()),
              Col(t1: 'Дүн', t2: toPrice(el.amount!.toString())),
              InkWell(
                onTap: () {
                  note.text = el.note!;
                  amount.text = el.amount.toString();
                  editExpense(context, el);
                },
                child: const Text(
                  'Засах',
                  style: TextStyle(color: white, fontWeight: FontWeight.bold),
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
