import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/choose_customer.dart';

class OrderSheet extends StatefulWidget {
  const OrderSheet({super.key});

  @override
  State<OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<OrderSheet> {
  final noteController = TextEditingController();
  final phoneController = TextEditingController();
  final phone2Controller = TextEditingController();

  String payType = '';
  String deliveryType = '';
  bool _loading = false;

  Sector _sector =
      Sector(-1, 'Салбар сонгоно уу!', '', '', '', '', null, true, '', 0, 0, Cmp(-1, '?'));

  bool get _isPharm => Authenticator.security?.isPharmacist ?? false;

  @override
  void initState() {
    super.initState();
    final home = context.read<HomeProvider>();
    final cart = context.read<CartProvider>();
    noteController.text = home.note ?? '';
    if (cart.isCashOnlyBasket) payType = PayType.cash.value;
    if (_isPharm) {
      WidgetsBinding.instance.addPostFrameCallback((_) async => await _loadBranches());
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async => await cart.getSellerPaymentSettings(),
      );
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    phoneController.dispose();
    phone2Controller.dispose();
    super.dispose();
  }

  Future _loadBranches() async {
    final home = context.read<HomeProvider>();
    await home.getBranches();
    if (!mounted) return;
    if (home.branches.length == 1) {
      _setBranch(home.branches[0]);
    } else {
      final main = home.branches.firstWhere((e) => e.isMain == true);
      if (main != null) _setBranch(main);
    }
  }

  void _setBranch(Sector s) {
    setState(() {
      _sector = s;
      phoneController.text = s.phone ?? '';
      phone2Controller.text = s.phone2 ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.read<HomeProvider>();
    final cart = context.read<CartProvider>();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .92),
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
              _handleBar(),
              const SizedBox(height: 20),
              const Text(
                'Захиалга баталгаажуулах',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // ── PHARM sections ──────────────────────────────────────
              if (_isPharm) ...[
                _supplierInfo(home),
                const SizedBox(height: 20),
                BottomSheetLabelBuilder('Хүргэлтийн нөхцөл'),
                const SizedBox(height: 10),
                _deliveryChips(),
                const SizedBox(height: 20),
                if (deliveryType == 'D') ...[
                  BottomSheetLabelBuilder('Хүргэлт хийх салбар'),
                  const SizedBox(height: 10),
                  _branchSelector(home),
                  if (_sector.id != -1) ...[
                    const SizedBox(height: 12),
                    BottomSheetLabelBuilder('Холбоо барих'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: phoneController, labelText: 'Утас'),
                    const SizedBox(height: 8),
                    CustomTextField(controller: phone2Controller, labelText: 'Утас 2'),
                  ],
                  const SizedBox(height: 20),
                ],
              ],

              // ── SELLER sections ─────────────────────────────────────
              if (!_isPharm) ...[
                BottomSheetLabelBuilder('Захиалагч сонгох'),
                const SizedBox(height: 12),
                _customerSelector(home),
                const SizedBox(height: 24),
              ],

              // ── Shared: payment ─────────────────────────────────────
              BottomSheetLabelBuilder('Төлбөрийн хэлбэр'),
              const SizedBox(height: 10),
              if (cart.isCashOnlyBasket) ...[
                const CashOnlyWarning(
                  message:
                      'Сагсанд зөвхөн бэлнээр төлөгдөх бараа байгаа тул зөвхөн бэлэн төлбөр боломжтой.',
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: (cart.isCashOnlyBasket ? [PayType.cash] : paymentMethods)
                    .map((pm) => Expanded(
                          child: BottomSheetOptionChip(
                            title: pm.name,
                            v: pm.value,
                            icon: pm.icon,
                            isSelected: payType == pm.value,
                            onTap: () => setState(() => payType = pm.value),
                          ),
                        ))
                    .toList(),
              ),
              if (!_isPharm && payType == 'T' && cart.paymentSettings != null) ...[
                const SizedBox(height: 10),
                _bankAccountsCard(cart.paymentSettings!),
              ],
              const SizedBox(height: 20),

              // ── Shared: note ────────────────────────────────────────
              BottomSheetLabelBuilder('Нэмэлт тайлбар (заавал биш)'),
              const SizedBox(height: 10),
              TextField(
                textInputAction: TextInputAction.done,
                controller: noteController,
                onChanged: (v) => home.setNote(v),
                decoration: const InputDecoration(
                  hintText: 'Энд тайлбар бичиж болно...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit ──────────────────────────────────────────────
              _loading
                  ? const LoadingButton()
                  : CustomButton(
                      text: 'Захиалга үүсгэх',
                      ontap: () => _submit(home, cart),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────

  Widget _handleBar() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _supplierInfo(HomeProvider home) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home_work_outlined, color: primary, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${home.picked.name} (${home.selected.name})',
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
    );
  }

  Widget _deliveryChips() {
    const methods = [
      {'title': 'Очиж авах', 'v': 'N', 'icon': '🏪'},
      {'title': 'Хүргэлтээр', 'v': 'D', 'icon': '🛵'},
    ];
    return Row(
      children: methods
          .map((dm) => Expanded(
                child: BottomSheetOptionChip(
                  title: dm['title']!,
                  v: dm['v']!,
                  icon: dm['icon']!,
                  isSelected: deliveryType == dm['v'],
                  onTap: () => setState(() => deliveryType = dm['v']!),
                ),
              ))
          .toList(),
    );
  }

  Widget _branchSelector(HomeProvider home) {
    final selected = _sector.id != -1;
    return InkWell(
      onTap: home.branches.length > 1 ? () => _showBranchMenu(home) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : Colors.grey.shade300),
          color: selected ? primary.withOpacity(0.02) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: selected ? primary : Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _sector.name,
                style: TextStyle(
                  color: selected ? primary : Colors.black87,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
            if (home.branches.length > 1) const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showBranchMenu(HomeProvider home) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .7),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _handleBar(),
                  const SizedBox(height: 20),
                  BottomSheetLabelBuilder('Хүргэлт хийх салбар'),
                  const SizedBox(height: 12),
                  ...home.branches.map((e) {
                    final sel = e.id == _sector.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          _setBranch(e);
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: sel ? primary : Colors.grey.shade300),
                            color: sel ? primary.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: sel ? primary : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                    fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                                    color: sel ? primary : Colors.black87,
                                  ),
                                ),
                              ),
                              if (sel) const Icon(Icons.check_circle, color: primary, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _customerSelector(HomeProvider home) {
    final hasCustomer = home.customer != null;
    return InkWell(
      onTap: () async {
        final value = await goto<Customer?>(const ChooseCustomer());
        if (value != null) home.setCustomer(value);
        if (mounted) setState(() {});
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
              hasCustomer ? Icons.person_rounded : Icons.person_add_alt_1_rounded,
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
                icon: const Icon(Icons.close_rounded, size: 20, color: Colors.red),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _bankAccountsCard(SellerPaymentSettings settings) {
    if (settings.bankAccounts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Text(
          'Нийлүүлэгч дансны мэдээлэл байхгүй байна.',
          style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дансаар шилжүүлэх данс',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          for (final acc in settings.bankAccounts) ...[
            const SizedBox(height: 8),
            Text(
              '${acc.bankName} — ${acc.accountNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              acc.accountHolder,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  // ── Submit logic ──────────────────────────────────────────────────────

  Future _submit(HomeProvider home, CartProvider cart) async {
    if (_isPharm) {
      await _submitPharm(home, cart);
    } else {
      await _submitSeller(home, cart);
    }
  }

  Future _submitPharm(HomeProvider home, CartProvider cart) async {
    if (deliveryType.isEmpty) {
      messageWarning('Хүргэлтийн хэлбэр сонгоно уу!');
      return;
    }
    if (deliveryType == 'D' && _sector.id == -1) {
      messageWarning('Салбар сонгоно уу!');
      return;
    }
    if (payType.isEmpty) {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if (payType != 'C') {
      final available = await cart.checkLoan(_sector.id);
      if (!available) return;
    }
    if ((_sector.phone != null && phoneController.text != _sector.phone) ||
        (_sector.phone2 != null && phone2Controller.text != _sector.phone2)) {
      final res = await api(Api.patch, 'branch/orderer/', body: {
        'branch_id': _sector.id,
        'phone': phoneController.text,
        'phone2': phone2Controller.text,
      });
      if (res == null || res.statusCode != 200) {
        messageError('Утасны дугаар шинэчилж чадсангүй');
        return;
      }
    }
    bool payViaQpay = false;
    final confirmed = await confirmDialog(
      title: 'Захиалга үүсгэх үү?',
      message: 'Үнийн дүн: ${cart.basket!.totalPrice}\n'
          'Нийт тоо ширхэг: ${cart.basket!.totalCount}\n'
          'Салбар: ${_sector.name}\n',
      messageAlign: TextAlign.start,
      messageStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
      content: _qpayButton(() {
        payViaQpay = true;
        Navigator.of(context).pop(true);
      }),
    );
    if (!confirmed) return;
    setState(() => _loading = true);
    if (payType == 'C' || payViaQpay) {
      await cart.createQR(
          branchId: _sector.id, note: noteController.text, deliveryType: deliveryType);
    } else {
      await cart.createOrder(
          branchId: _sector.id, note: noteController.text, deliveryType: deliveryType, pt: payType);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future _submitSeller(HomeProvider home, CartProvider cart) async {
    if (payType.isEmpty) {
      messageWarning('Төлбөрийн хэлбэр сонгоно уу!');
      return;
    }
    if (home.customer == null) {
      messageWarning('Захиалагч сонгоно уу!');
      return;
    }
    if ((cart.basket?.totalCount ?? 0) == 0) {
      messageWarning('Сагс хоосон байна!');
      return;
    }
    final loanAvailable = await cart.checkLoan(home.customer!.id);
    if (!loanAvailable) return;
    final confirmed = await confirmDialog(
      title: 'Захиалга үүсгэх үү?',
      message: 'Үнийн дүн: ${cart.basket!.totalPrice}\n'
          'Нийт тоо ширхэг: ${cart.basket!.totalCount}\n'
          'Захиалагч: ${home.customer!.name}\n',
      messageAlign: TextAlign.start,
      messageStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
    );
    if (!confirmed) return;
    setState(() => _loading = true);
    // seller/order/ (not the pharmacist ci/ draft-invoice flow) always
    // creates the order regardless of payType - it auto-attaches a QPay
    // invoice itself when the basket needs one, so there is no separate
    // "pay by qpay" branch here anymore: recording the sale must never
    // wait on payment.
    await home.createSellerOrder(context, payType);
    if (mounted) setState(() => _loading = false);
  }

  Widget _qpayButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.qr_code_rounded, size: 18),
        label: const Text('Шууд Qpay-р төлөх'),
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(primary),
          ),
        ),
      ),
    );
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

  final String title, v, icon;
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

// Backward-compat aliases
typedef SellerOrderSheet = OrderSheet;
typedef PharmOrderSheet = OrderSheet;
