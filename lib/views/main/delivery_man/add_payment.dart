import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/controllers/models/customer.dart';
import 'package:pharmo_app/controllers/models/payment.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:provider/provider.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({super.key});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  String selected = 'e';
  String pType = 'E';
  String? selectedCustomer;
  Customer? customer;
  setSelected(String s, String p) {
    setState(() {
      selected = s;
      pType = p;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.microtask(() => context.read<PharmProvider>().getCustomers(1, 100, context));
      Future.microtask(() => context.read<JaggerProvider>().getCustomerPayment());
    });
  }

  final TextEditingController amount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<JaggerProvider, PharmProvider>(
      builder: (context, jagger, pharm, child) => Scaffold(
        appBar: SideAppBar(text: 'Төлбөр, тооцоо бүртгэх', action: addIcon(jagger, pharm)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              const SizedBox(),
              ...jagger.payments.map(
                (payment) => paymentBuilder(payment),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container paymentBuilder(Payment payment) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), border: Border.all(color: atnessGrey)),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(payment.cust.name!),
          Text(getPayType(payment.payType)),
          Text(toPrice(payment.amount)),
          Text(payment.paidOn.toString().substring(0, 10))
        ],
      ),
    );
  }

  addIcon(JaggerProvider jagger, PharmProvider pharm) {
    return InkWell(
      onTap: () => addPayment(jagger, pharm),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: white,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: theme.primaryColor),
      ),
    );
  }

  _register(JaggerProvider jagger) async {
    print(pType);
    if (pType == "E") {
      message('Төлбөрийн хэлбэр сонгоно уу!');
    } else if (amount.text.isEmpty) {
      message('Дүн оруулна уу!');
    } else if (customer == null) {
      message('Харилцагч сонгоно уу!');
    } else {
      await jagger.addCustomerPayment(pType, amount.text, parseInt(customer!.id));
      Navigator.pop(context);
      amount.clear();
    }
  }

  addPayment(JaggerProvider jagger, PharmProvider pharm) {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              spacing: 15,
              children: [
                const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    picker('Бэлнээр', 'C', setModalState),
                    picker('Дансаар', 'T', setModalState),
                  ],
                ),
                CustomTextField(
                  controller: amount,
                  hintText: 'Дүн оруулна уу',
                  keyboardType: TextInputType.number,
                ),
                const Text('Харилцагч сонгох'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: atnessGrey)),
                  child: DropdownButton<Customer>(
                    value: customer,
                    underline: const SizedBox(),
                    hint: const Text("Харилцагч сонгох"),
                    dropdownColor: white,
                    isExpanded: true,
                    menuMaxHeight: 600,
                    items: pharm.filteredCustomers
                        .map((customer) => DropdownMenuItem<Customer>(
                              value: customer,
                              child: Text(
                                maybeNull(customer.name),
                                style: TextStyle(color: grey600),
                              ),
                            ))
                        .toList(),
                    onChanged: (Customer? newValue) {
                      setModalState(() {
                        customer = newValue;
                      });
                    },
                  ),
                ),
                CustomButton(text: 'Бүртгэх', ontap: () => _register(jagger)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget picker(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    return InkWell(
      onTap: () => setModalState(() {
        selected = n;
        pType = v;
      }),
      child: AnimatedContainer(
        duration: duration,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: sel ? 20 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? succesColor : grey300,
          ),
        ),
        child: Text(n),
      ),
    );
  }
}
