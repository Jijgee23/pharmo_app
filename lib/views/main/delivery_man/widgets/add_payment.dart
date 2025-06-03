import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/models/customer.dart';
import 'package:pharmo_app/models/payment.dart';
import 'package:pharmo_app/controllers/pharms_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
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

  String viewMode = 'Жагсаалт';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.microtask(
          () => context.read<PharmProvider>().getCustomers(1, 5, context));
      Future.microtask(
          () => context.read<JaggerProvider>().getCustomerPayment());
    });
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<JaggerProvider, PharmProvider>(
      builder: (context, jagger, pharm, child) => Scaffold(
        appBar: const SideAppBar(text: 'Төлбөр, тооцоо бүртгэх'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const SizedBox(),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    switcher('Жагсаалт'),
                    switcher('Бүртгэх'),
                  ],
                ),
              ),
              Column(
                spacing: 10,
                children: (viewMode == 'Жагсаалт')
                    ? [
                        ...jagger.payments.map(
                          (payment) => paymentBuilder(payment, jagger),
                        )
                      ]
                    : [
                        CustomTextField(
                          controller: search,
                          hintText: 'Харицагч хайх',
                          onChanged: (p0) async =>
                              await pharm.filtCustomers('name', p0!, context),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            if (pharm.filteredCustomers.isNotEmpty)
                              ...pharm.filteredCustomers
                                  .take(3)
                                  .map((cus) => customerBuilder(cus)),
                            if (pharm.filteredCustomers.isEmpty)
                              const Align(
                                  alignment: Alignment.center,
                                  child: Text('Харилцагч олдсонгүй',
                                      textAlign: TextAlign.center))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            picker('Бэлнээр', 'C'),
                            picker('Дансаар', 'T'),
                          ],
                        ),
                        CustomTextField(
                          controller: amount,
                          hintText: 'Дүн оруулах',
                          keyboardType: TextInputType.number,
                        ),
                        CustomButton(
                            text: 'Бүртгэх', ontap: () => _register(jagger)),
                      ],
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget customerBuilder(Customer cus) {
    bool sel = cus == customer;
    return InkWell(
      onTap: () => setState(() {
        if (sel) {
          customer = null;
        } else {
          customer = cus;
        }
      }),
      child: AnimatedContainer(
        duration: duration,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: sel ? succesColor : atnessGrey),
            color: sel ? succesColor.withOpacity(.3) : white),
        child: Row(
          spacing: 10,
          children: [const Icon(Icons.person), Text(cus.name!)],
        ),
      ),
    );
  }

  Widget paymentBuilder(Payment payment, JaggerProvider jagger) {
    return InkWell(
      onTap: () => editPayment(jagger, payment),
      child: Card(
        margin: const EdgeInsets.symmetric(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                getPaymentColor(payment.payType).withOpacity(0.2),
                Colors.white
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1).withBlue(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(payment.cust.name!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${toPrice(payment.amount)} (${getPayType(payment.payType)})',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  timeText(payment.paidOn.toString().substring(0, 10)),
                  timeText(payment.paidOn.toString().substring(10, 19)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text timeText(String t) {
    return Text(
      t,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Color getPaymentColor(String payTime) {
    switch (payTime) {
      case 'C':
        return Colors.green;
      case 'T':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  TextEditingController ctr = TextEditingController();

  editPayment(JaggerProvider jagger, Payment payment) async {
    setState(() {
      ctr.text = payment.amount.toString();
    });

    setSelected(
        payment.payType == 'C' ? 'Бэлнээр' : 'Дансаар', payment.payType);
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return SheetContainer(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                picker2('Бэлнээр', 'C', setModalState),
                picker2('Дансаар', 'T', setModalState)
              ],
            ),
            CustomTextField(controller: ctr),
            CustomButton(
              text: 'Хадгалах',
              ontap: () {
                jagger.editCustomerPayment(payment.cust.id.toString(),
                    payment.paymentId, pType, ctr.text);
                Navigator.pop(context);
              },
            )
          ]);
        },
      ),
    );
  }

  Widget switcher(String n) {
    bool picked = n == viewMode;
    return InkWell(
      onTap: () => setState(() {
        viewMode = n;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: picked ? Sizes.width * .5 : Sizes.width * .38,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: picked ? Colors.green : Colors.blueGrey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (picked)
              BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 6)
          ],
        ),
        child: Center(
          child: Text(
            n,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: picked ? Colors.white : Colors.black54,
            ),
          ),
        ),
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
      await jagger.addCustomerPayment(
          pType, amount.text, customer!.id.toString());
      amount.clear();
      setState(() {
        customer = null;
        pType = 'E';
        selected = 'e';
      });
    }
  }

  Widget picker2(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    return InkWell(
      onTap: () => setModalState(() {
        selected = n;
        pType = v;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: sel ? 22 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: sel ? succesColor.withOpacity(.4) : Colors.white,
          border: Border.all(
            color: sel ? succesColor : Colors.grey.shade300,
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: succesColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          n,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget picker(String n, String v) {
    bool sel = (selected == n);
    return InkWell(
      onTap: () => setState(() {
        selected = n;
        pType = v;
      }),
      child: AnimatedContainer(
        duration: duration,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: sel ? 20 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sel ? succesColor.withOpacity(.3) : white,
          border: Border.all(
            color: sel ? succesColor : grey300,
          ),
        ),
        child: Text(n),
      ),
    );
  }
}
