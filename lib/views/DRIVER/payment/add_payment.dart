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
        backgroundColor: grey50,
        appBar: AppBar(
          leading: ChevronBack(),
          title: Text('Төлбөр, тооцоо бүртгэх'),
          centerTitle: false,
          bottom: TabBar(
            controller: tabController,
            dividerColor: black,
            labelColor: primary,
            unselectedLabelColor: black,
            tabs: [
              Tab(child: Text('Жагсаалт')),
              Tab(child: Text('Бүртгэх')),
            ],
          ),
        ),
        body: TabBarView(
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
                : ListView.builder(
                    itemCount: jagger.payments.length,
                    itemBuilder: (context, index) {
                      final payment = jagger.payments[index];
                      return PaymentBuilder(
                        payment: payment,
                        handler: () => editPayment(jagger, payment),
                      );
                    },
                  ),
            Column(
              spacing: 16, // Зайг бага зэрэг ихэсгэвэл илүү цэмцгэр харагдана
              children: [
                // 1. Харилцагч сонгох хэсэг
                Builder(builder: (context) {
                  bool hasCustomer = customer != null;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: hasCustomer
                          ? primary.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: hasCustomer ? primary : Colors.grey.shade300,
                        width: hasCustomer ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        Customer? value =
                            await goto<Customer?>(ChooseCustomer());
                        if (value != null) {
                          setState(() => customer = value);
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  hasCustomer ? primary : Colors.grey.shade100,
                              child: Icon(
                                hasCustomer
                                    ? Icons.person
                                    : Icons.person_search,
                                color: hasCustomer ? Colors.white : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Харилцагч',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    hasCustomer
                                        ? customer!.name!
                                        : 'Сонгох хэсэгт дарна уу',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: hasCustomer
                                          ? primary
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasCustomer)
                              IconButton(
                                onPressed: () =>
                                    setState(() => customer = null),
                                icon: const Icon(Icons.cancel,
                                    color: Colors.redAccent),
                              )
                            else
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // 2. Төлбөрийн хэлбэр (Picker)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypePicker(
                          'Бэлнээр',
                          'C',
                          Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypePicker(
                          'Дансаар',
                          'T',
                          Icons.account_balance_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Дүн оруулах хэсэг
                CustomTextField(
                  controller: amount,
                  hintText: 'Дүн оруулах',
                  prefix: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  // Энд тоог форматлах formatter нэмж болно
                ),

                const SizedBox(height: 8),

                // 4. Бүртгэх товч
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Бүртгэх',
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    ontap: () => _register(jagger),
                  ),
                ),
              ],
            )
          ],
        ).paddingAll(10),
      ),
    );
  }

  Widget _buildTypePicker(String title, String type, IconData icon) {
    bool isSelected = selected == type; // Таны State-д байгаа төрөл
    return GestureDetector(
      onTap: () => setState(() => selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? primary : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primary : Colors.grey,
              ),
            ),
          ],
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
