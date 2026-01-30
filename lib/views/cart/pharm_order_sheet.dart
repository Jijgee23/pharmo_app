import 'package:pharmo_app/application/application.dart';

class PharmOrderSheet extends StatefulWidget {
  const PharmOrderSheet({super.key});

  @override
  State<PharmOrderSheet> createState() => _PharmOrderSheetState();
}

class _PharmOrderSheetState extends State<PharmOrderSheet> {
  late HomeProvider homeProvider;
  late BasketProvider basketProvider;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);

    // Хэрэв ганцхан салбартай бол шууд сонгох
    if (homeProvider.branches.length == 1) {
      setBranch(homeProvider.branches[0].name!, homeProvider.branches[0].id);
    }
  }

  String deliveryType = '';
  String payType = '';
  int selectedBranchId = -1;
  String selectedBranch = 'Салбар сонгоно уу!';

  void setDeliverType(String v) => setState(() => deliveryType = v);
  void setPayType(String v) => setState(() => payType = v);
  void setBranch(String v, dynamic id) => setState(() {
        selectedBranch = v;
        selectedBranchId = id;
      });

  final List<Map<String, String>> deliveryMethods = [
    {'title': 'Очиж авах', 'v': 'N', 'icon': '🏪'},
    {'title': 'Хүргэлтээр', 'v': 'D', 'icon': '🛵'},
  ];

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

          // 2. Хүргэлтийн хэлбэр
          _buildLabel('Хүргэлтийн нөхцөл'),
          const SizedBox(height: 10),
          Row(
            children: deliveryMethods
                .map((dm) => Expanded(
                      child: _optionChip(
                          dm['title']!,
                          dm['v']!,
                          dm['icon']!,
                          deliveryType == dm['v'],
                          () => setDeliverType(dm['v']!)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // 3. Салбар сонгох (Хэрэв Хүргэлтээр бол заавал салбар сонгоно)
          if (deliveryType == 'D' || homeProvider.branches.length > 1) ...[
            _buildLabel('Хүргэлт хийх салбар'),
            const SizedBox(height: 10),
            _branchSelector(),
            const SizedBox(height: 20),
          ],

          // 4. Төлбөрийн хэлбэр
          _buildLabel('Төлбөрийн хэлбэр'),
          const SizedBox(height: 10),
          Row(
            children: payMethods
                .map((pm) => Expanded(
                      child: _optionChip(pm['title']!, pm['v']!, pm['icon']!,
                          payType == pm['v'], () => setPayType(pm['v']!)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // 5. Тайлбар
          _buildLabel('Тайлбар (Заавал биш)'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: noteController,
              onChanged: (v) => homeProvider.setNote(v),
              decoration: const InputDecoration(
                hintText: 'Энд тайлбар бичиж болно...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 6. Захиалах товч
          CustomButton(
            text: 'Захиалга үүсгэх',
            ontap: () => _handleOrder(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600),
    );
  }

  Widget _optionChip(String title, String v, String icon, bool isSelected,
      VoidCallback onTap) {
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

  Widget _branchSelector() {
    bool isSelected = selectedBranchId != -1;
    return InkWell(
      onTap: homeProvider.branches.length > 1 ? () => _showBranchMenu() : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? primary : Colors.grey.shade300),
          color: isSelected ? primary.withOpacity(0.02) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: isSelected ? primary : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedBranch,
                style: TextStyle(
                  color: isSelected ? primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
            if (homeProvider.branches.length > 1)
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showBranchMenu() {
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(100, 400, 20, 0),
      items: homeProvider.branches
          .map((e) => PopupMenuItem(
                onTap: () => setBranch(e.name!, e.id),
                child: Text(e.name!),
              ))
          .toList(),
    );
  }

  void _handleOrder() async {
    if (deliveryType == '') {
      messageWarning('Хүргэлтийн хэлбэр сонгоно уу!');
      return;
    }
    if (deliveryType == 'D' && selectedBranchId == -1) {
      messageWarning('Салбар сонгоно уу!');
      return;
    }
    if (payType == '') {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }

    LoadingService.show();
    try {
      if (payType == 'C') {
        await basketProvider.createQR(
          basketId: basketProvider.basket!.id,
          branchId: selectedBranchId,
          note: noteController.text,
          deliveryType: deliveryType,
          context: context,
        );
      } else {
        await basketProvider.createOrder(
          basketId: basketProvider.basket!.id,
          branchId: selectedBranchId,
          note: noteController.text,
          deliveryType: deliveryType,
          pt: payType,
          context: context,
        );
      }
    } finally {
      LoadingService.hide();
    }
  }
}

class MyChip extends StatelessWidget {
  final String title;
  final String v;
  final bool selected;
  final Function() ontap;
  const MyChip({
    super.key,
    required this.title,
    required this.v,
    required this.selected,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = Sizes.height * .012;
    return Expanded(
      child: InkWell(
        onTap: ontap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? theme.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: selected ? theme.primaryColor : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
