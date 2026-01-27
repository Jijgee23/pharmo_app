import 'package:pharmo_app/views/DRIVER/payment/payment_builder.dart';
import 'package:pharmo_app/views/SELLER/customer/choose_customer.dart';
import 'package:pharmo_app/application/application.dart';

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
          padding: EdgeInsets.all(5.0),
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
                        spacing: 10,
                        children: jagger.payments
                            .map(
                              (payment) => PaymentBuilder(
                                payment: payment,
                                handler: () => editPayment(jagger, payment),
                              ),
                            )
                            .toList(),
                      ),
                    ),
              Column(
                spacing: 10,
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

  _register(JaggerProvider jagger) async {
    print(pType);
    if (pType == "E") {
      message('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if (amount.text.isEmpty) {
      message('Дүн оруулна уу!');
      return;
    }
    if (customer == null) {
      message('Харилцагч сонгоно уу!');
      return;
    }
    await jagger.addCustomerPayment(
        pType, amount.text, customer!.id.toString());
    amount.clear();
    setState(
      () {
        customer = null;
        pType = 'E';
        selected = 'e';
      },
    );
    tabController.animateTo(0);
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
