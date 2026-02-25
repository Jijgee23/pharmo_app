import 'package:pharmo_app/application/application.dart';

class PharmOrderSheet extends StatefulWidget {
  const PharmOrderSheet({super.key});

  @override
  State<PharmOrderSheet> createState() => _PharmOrderSheetState();
}

class _PharmOrderSheetState extends State<PharmOrderSheet> {
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await load());
  }

  Future load() async {
    final home = context.read<HomeProvider>();
    await home.getBranches();
    if (home.branches.length == 1) {
      setBranch(home.branches[0]);
    } else {
      final main = home.branches.firstWhere((e) => e.isMain == true);
      if (main != null) setBranch(main);
    }
  }

  String deliveryType = '';
  String payType = '';
  Sector sector = Sector(-1, 'Салбар сонгоно уу!', '', '', '', '', null, true,
      '', 0, 0, Cmp(-1, '?'));

  TextEditingController phoneController = TextEditingController();
  TextEditingController phone2Controller = TextEditingController();
  TextEditingController phone3Controller = TextEditingController();

  void setDeliverType(String v) => setState(() => deliveryType = v);
  void setPayType(String v) => setState(() => payType = v);
  void setBranch(Sector s) {
    sector = s;
    if (sector.phone != null) {
      phoneController.text = sector.phone ?? '';
    }
    if (sector.phone2 != null) {
      phone2Controller.text = sector.phone2 ?? '';
    }
    if (sector.phone3 != null) {
      phone3Controller.text = sector.phone3 ?? '';
    }
    setState(() {});
  }

  final List<Map<String, String>> deliveryMethods = [
    {'title': 'Очиж авах', 'v': 'N', 'icon': '🏪'},
    {'title': 'Хүргэлтээр', 'v': 'D', 'icon': '🛵'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, CartProvider>(
      builder: (context, home, cart, child) {
        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .9),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
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
                  BottomSheetLabelBuilder('Сонгосон нийлүүлэгч'),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_work_outlined,
                            color: primary, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "${home.picked.name} (${home.selected.name})",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 2. Хүргэлтийн хэлбэр
                  BottomSheetLabelBuilder('Хүргэлтийн нөхцөл'),
                  const SizedBox(height: 10),
                  Row(
                    children: deliveryMethods
                        .map((dm) => Expanded(
                              child: BottomSheetOptionChip(
                                title: dm['title']!,
                                v: dm['v']!,
                                icon: dm['icon']!,
                                isSelected: deliveryType == dm['v'],
                                onTap: () => setDeliverType(dm['v']!),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 3. Салбар сонгох (Хэрэв Хүргэлтээр бол заавал салбар сонгоно)
                  if (deliveryType == 'D' || home.branches.length > 1) ...[
                    BottomSheetLabelBuilder('Хүргэлт хийх салбар'),
                    const SizedBox(height: 10),
                    _branchSelector(home),
                    const SizedBox(height: 10),
                    if (sector.id != -1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          BottomSheetLabelBuilder('Холбоо барих'),
                          CustomTextField(
                            controller: phoneController,
                            labelText: 'Утас',
                          ),
                          CustomTextField(
                            controller: phone2Controller,
                            labelText: 'Утас2',
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],

                  // 4. Төлбөрийн хэлбэр
                  BottomSheetLabelBuilder('Төлбөрийн хэлбэр'),
                  const SizedBox(height: 10),
                  Row(
                    children: paymentMethods
                        .map(
                          (pm) => Expanded(
                            child: BottomSheetOptionChip(
                              title: pm.name,
                              v: pm.value,
                              icon: pm.icon,
                              isSelected: payType == pm.value,
                              onTap: () => setPayType(pm.value),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 5. Тайлбар
                  BottomSheetLabelBuilder('Тайлбар (Заавал биш)'),
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
                      onChanged: (v) => home.setNote(v),
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
                    ontap: () => _handleOrder(home, cart, context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _branchSelector(HomeProvider home) {
    bool isSelected = sector.id != -1;
    return InkWell(
      onTap: home.branches.length > 1 ? () => _showBranchMenu(home) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
          ),
          color: isSelected ? primary.withOpacity(0.02) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: isSelected ? primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sector.name,
                style: TextStyle(
                  color: isSelected ? primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
            if (home.branches.length > 1)
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showBranchMenu(HomeProvider home) {
    showMenu(
      context: context,
      menuPadding: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(100, 400, 20, 0),
      items: home.branches.map((e) {
        bool selected = e.id == sector.id;
        return PopupMenuItem(
          onTap: () => setBranch(e),
          child: ListTile(
            dense: 1 == 1,
            selected: selected,
            selectedColor: primary,
            selectedTileColor: primary.withOpacity(.2),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              e.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleOrder(
      HomeProvider home, CartProvider cart, BuildContext c) async {
    if (deliveryType == '') {
      messageWarning('Хүргэлтийн хэлбэр сонгоно уу!');
      return;
    }
    if (deliveryType == 'D' && sector.id == -1) {
      messageWarning('Салбар сонгоно уу!');
      return;
    }
    if (payType == '') {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }

    if (payType != "C") {
      final available = await cart.checkLoan(sector.id);
      if (!available) return;
    }

    if ((sector.phone != null && phoneController.text != sector.phone) ||
        (sector.phone2 != null && phone2Controller.text != sector.phone2)) {
      final res = await api(Api.patch, 'branch/orderer/', body: {
        'branch_id': sector.id,
        'phone': phoneController.text,
        'phone2': phone2Controller.text,
      });
      if (res == null ||
          (res != null && (res.statusCode != 200 || res.statusCode == 201))) {
        messageError('Утасны дугаар шинэчилж чадсангүй');
        return;
      }
    }

    String priceInfo = 'Үнийн дүн: ${cart.basket!.totalPrice}\n';
    String qtyInfo = 'Нийт тоо ширхэг: ${cart.basket!.totalCount}\n';
    String branchInfo = 'Салбар: ${sector.name}\n';
    bool confirmed = await confirmDialog(
      context: c,
      title: 'Захиалга үүсгэх үү?',
      message: '$priceInfo $qtyInfo $branchInfo',
      messageAlign: TextAlign.start,
      messageStyle: TextStyle(color: primary, fontWeight: FontWeight.bold),
    );

    if (!confirmed) return;

    if (payType == 'C') {
      await cart.createQR(
        basketId: cart.basket!.id,
        branchId: sector.id,
        note: noteController.text,
        deliveryType: deliveryType,
        context: c,
      );
    } else {
      await cart.createOrder(
        branchId: sector.id,
        note: noteController.text,
        deliveryType: deliveryType,
        pt: payType,
        context: c,
      );
    }
  }
}
