import 'package:pharmo_app/views/SELLER/customer/choose_customer.dart';
import 'package:pharmo_app/application/application.dart';

class SellerOrderSheet extends StatefulWidget {
  const SellerOrderSheet({super.key});

  @override
  State<SellerOrderSheet> createState() => _SellerOrderSheetState();
}

class _SellerOrderSheetState extends State<SellerOrderSheet> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    // Хэрэв өмнө нь тэмдэглэл байсан бол сэргээх
    noteController.text = homeProvider.note ?? '';
  }

  String payType = '';
  final List<Map<String, String>> payMethods = [
    {'title': 'Бэлнээр', 'v': 'C', 'icon': '💰'},
    {'title': 'Дансаар', 'v': 'T', 'icon': '💳'},
    {'title': 'Зээлээр', 'v': 'L', 'icon': '📝'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<HomeProvider>(
        builder: (context, home, child) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Захиалга баталгаажуулах',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),

              // 2. Төлбөрийн хэлбэр
              BottomSheetLabelBuilder('Төлбөрийн хэлбэр'),
              const SizedBox(height: 12),
              Row(
                children: payMethods
                    .map(
                      (p) => Expanded(
                        child: BottomSheetOptionChip(
                          title: p['title'] ?? '',
                          v: p['v']!,
                          icon: p['icon']!,
                          isSelected: payType == p['v'],
                          onTap: () {
                            payType = p['v']!;
                            setState(() {});
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),

              // 3. Захиалагч сонгох
              BottomSheetLabelBuilder('Захиалагч сонгох'),
              const SizedBox(height: 12),
              _customerSelector(home),
              const SizedBox(height: 24),

              // 4. Тайлбар хэсэг
              BottomSheetLabelBuilder('Нэмэлт тайлбар (заавал биш)'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 2,
                  onChanged: (v) => homeProvider.setNote(v),
                  decoration: const InputDecoration(
                    hintText: 'Энд тайлбар бичиж болно...',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Захиалах товч
              CustomButton(
                text: 'Захиалга үүсгэх',
                ontap: () => _createOrder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customerSelector(HomeProvider home) {
    bool hasCustomer = home.customer != null;
    return InkWell(
      onTap: () async {
        Customer? value = await goto<Customer?>(const ChooseCustomer());
        if (value != null) {
          home.setCustomer(value);
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasCustomer ? primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasCustomer ? primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasCustomer
                  ? Icons.person_rounded
                  : Icons.person_add_alt_1_rounded,
              color: hasCustomer ? primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasCustomer ? home.customer!.name! : 'Захиалагч сонгох',
                style: TextStyle(
                  fontWeight: hasCustomer ? FontWeight.bold : FontWeight.w500,
                  color: hasCustomer ? primary : Colors.grey.shade600,
                ),
              ),
            ),
            if (hasCustomer)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  home.setCustomer(null);
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: Colors.red),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future _createOrder() async {
    if (homeProvider.customer == null) {
      messageWarning('Захиалагч сонгоно уу!');
      return;
    }
    if (payType == '') {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if ((basketProvider.basket?.totalCount ?? 0) == 0) {
      messageWarning('Сагс хоосон байна!');
      return;
    }

    // Ачааллаж буйг харуулах
    LoadingService.show();
    try {
      await homeProvider.createSellerOrder(context, payType);
    } finally {
      LoadingService.hide();
    }
  }
}

class BottomSheetLabelBuilder extends StatelessWidget {
  const BottomSheetLabelBuilder(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class BottomSheetOptionChip extends StatelessWidget {
  const BottomSheetOptionChip({
    super.key,
    required this.title,
    required this.v,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String v;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primary : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
