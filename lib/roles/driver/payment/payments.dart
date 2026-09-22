import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/payment/payment_builder.dart';
import 'package:pharmo_app/roles/seller/customer/choose_customer.dart';

class Payments extends StatefulWidget {
  const Payments({super.key});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  String selected = 'e';
  Customer? customer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<JaggerProvider>().getCustomerPayment();
      if (mounted) setState(() => _loading = false);
    });
  }

  final TextEditingController amount = TextEditingController();
  final TextEditingController ctr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<JaggerProvider>(
      builder: (context, jagger, child) => Scaffold(
        backgroundColor: grey50,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(backgroundColor: grey200),
            icon: const Icon(Icons.chevron_left),
          ),
          title: const Text('Төлбөр, тооцоо'),
          centerTitle: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateSheet(jagger),
          backgroundColor: primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : jagger.payments.isEmpty
                ? const Center(child: NoResult())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: jagger.payments.length,
                    itemBuilder: (context, index) {
                      final payment = jagger.payments[index];
                      return PaymentBuilder(
                        payment: payment,
                        handler: () => _editPayment(jagger, payment),
                      );
                    },
                  ),
      ),
    );
  }

  void _showCreateSheet(JaggerProvider jagger) {
    selected = 'e';
    customer = null;
    amount.clear();
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(
          title: 'Төлбөр бүртгэх',
          children: [
            // Customer picker
            Builder(builder: (_) {
              bool hasCustomer = customer != null;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: hasCustomer ? primary.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: hasCustomer ? primary : Colors.grey.shade300,
                    width: hasCustomer ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    Customer? value = await goto<Customer?>(ChooseCustomer());
                    if (value != null) setModalState(() => customer = value);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: hasCustomer ? primary : Colors.grey.shade100,
                          child: Icon(
                            hasCustomer ? Icons.person : Icons.person_search,
                            color: hasCustomer ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Харилцагч',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              Text(
                                hasCustomer ? customer!.name! : 'Сонгох хэсэгт дарна уу',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: hasCustomer ? primary : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasCustomer)
                          IconButton(
                            onPressed: () => setModalState(() => customer = null),
                            icon: const Icon(Icons.cancel, color: Colors.redAccent),
                          )
                        else
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Payment type picker
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypePicker('Бэлнээр', 'C', Icons.payments_outlined, setModalState),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTypePicker(
                        'Дансаар', 'T', Icons.account_balance_outlined, setModalState),
                  ),
                ],
              ),
            ),

            // Amount field
            CustomTextField(
              controller: amount,
              hintText: 'Дүн оруулах',
              prefix: Icons.monetization_on_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Бүртгэх',
                padding: const EdgeInsets.symmetric(vertical: 16),
                ontap: () => _register(jagger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypePicker(String title, String type, IconData icon, StateSetter setModalState) {
    bool isSelected = selected == type;
    return GestureDetector(
      onTap: () => setModalState(() => selected = type),
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

  _editPayment(JaggerProvider jagger, Payment payment) {
    selected = payment.payType == 'C' ? 'C' : 'T';
    ctr.text = payment.amount.toString();
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) => SheetContainer(children: [
          Row(
            spacing: 10,
            children: [
              _picker2('Бэлнээр', 'C', setModalState),
              _picker2('Дансаар', 'T', setModalState),
            ],
          ),
          CustomTextField(controller: ctr),
          CustomButton(
            text: 'Хадгалах',
            ontap: () {
              jagger.editCustomerPayment(
                  payment.cust.id.toString(), payment.paymentId, selected, ctr.text);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  _register(JaggerProvider jagger) async {
    if (selected == 'e') {
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
    await jagger.addCustomerPayment(selected, amount.text, customer!.id.toString());
    amount.clear();
    selected = 'e';
    customer = null;
    Navigator.pop(Get.context!);
  }

  Widget _picker2(String n, String v, Function(void Function()) setModalState) {
    bool sel = selected == v;
    return Expanded(
      child: InkWell(
        onTap: () => setModalState(() => selected = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
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
}
