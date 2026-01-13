import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';
import 'package:pharmo_app/controller/models/customer.dart';
import 'package:pharmo_app/controller/models/payment.dart';
import 'package:pharmo_app/controller/providers/pharms_provider.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/constants.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/application/utilities/utils.dart';
import 'package:pharmo_app/views/seller/customer/choose_customer.dart';
import 'package:pharmo_app/widgets/bottomSheet/my_sheet.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';
import 'package:pharmo_app/widgets/inputs/custom_text_filed.dart';
import 'package:pharmo_app/widgets/inputs/ibtn.dart';
import 'package:pharmo_app/widgets/others/no_result.dart';
import 'package:provider/provider.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({super.key});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment>
    with SingleTickerProviderStateMixin {
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

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<JaggerProvider>().getCustomerPayment();
    });
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<JaggerProvider, PharmProvider>(
      builder: (context, jagger, pharm, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          foregroundColor: black,
          leading: Ibtn(
            onTap: () => Navigator.pop(context),
            icon: Icons.chevron_left_sharp,
          ),
          title: Text(
            'Төлбөр, тооцоо бүртгэх',
            style: TextStyle(fontSize: 14),
          ),
          centerTitle: false,
          bottom: TabBar(
            controller: tabController,
            dividerColor: black,
            labelColor: primary,
            unselectedLabelColor: black,
            tabs: [
              Tab(
                child: Text('Жагсаалт'),
              ),
              Tab(child: Text('Бүртгэх')),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(14.0),
          child: TabBarView(
            controller: tabController,
            children: [
              jagger.payments.isEmpty
                  ? Center(
                      child: Column(
                        spacing: 10,
                        children: [
                          NoResult(),
                          CustomButton(
                            text: 'Бүртгэх',
                            ontap: () => tabController.animateTo(1),
                          )
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        spacing: 14,
                        children: jagger.payments
                            .map((payment) => paymentBuilder(payment, jagger))
                            .toList(),
                      ),
                    ),
              Column(
                spacing: 15,
                children: [
                  Builder(builder: (context) {
                    bool hasCustomer = customer != null;
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Customer? value =
                                  await goto<Customer?>(ChooseCustomer());
                              if (value != null) {
                                print(value.name);
                                customer = value;
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasCustomer ? primary : white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: hasCustomer
                                      ? transperant
                                      : Colors.grey.shade400,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hasCustomer
                                      ? customer!.name!
                                      : 'Харилцагч сонгох',
                                  style: TextStyle(
                                    color: hasCustomer ? white : null,
                                  ),
                                ),
                                if (customer != null)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      customer = null;
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      color: white,
                                      size: 26,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
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
                    text: 'Бүртгэх',
                    ontap: () => _register(jagger),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentBuilder(Payment payment, JaggerProvider jagger) {
    return Card(
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: grey500),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => editPayment(jagger, payment),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7.5,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1).withBlue(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      payment.cust.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${toPrice(payment.amount)} (${getPayType(payment.payType)})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              spacing: 10,
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
      tabController.animateTo(0);
    }
  }

  Widget picker2(String n, String v, Function(void Function()) setModalState) {
    bool sel = (selected == n);
    return Expanded(
      child: InkWell(
        onTap: () => setModalState(() {
          selected = n;
          pType = v;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: sel ? primary : white,
            border: Border.all(color: sel ? primary : grey400),
          ),
          child: Center(
            child: Text(
              n,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : Colors.black,
              ),
            ),
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
