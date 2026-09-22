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
  int _step = 0;

  Sector _sector =
      Sector(-1, 'Салбар сонгоно уу!', '', '', '', '', null, true, '', 0, 0, Cmp(-1, '?'));

  bool get _isPharm => Authenticator.security?.isPharmacist ?? false;

  @override
  void initState() {
    super.initState();
    final home = context.read<HomeProvider>();
    final cart = context.read<CartProvider>();
    noteController.text = home.note ?? '';
    // Restore the PA order-sheet selections remembered on HomeProvider from
    // a previous open of this same sheet (cleared once the order actually
    // succeeds — see CartProvider.createOrder()/checkPayment()).
    if (_isPharm) {
      deliveryType = home.orderDeliveryType;
      payType = home.orderPayType;
      final rememberedBranch = home.orderBranch;
      if (rememberedBranch != null) {
        _sector = rememberedBranch;
        phoneController.text = rememberedBranch.phone ?? '';
        phone2Controller.text = rememberedBranch.phone2 ?? '';
      }
    }
    if (cart.isCashOnlyBasket) payType = PayType.cash.value;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Two different endpoints, identical response shape: PA/PM read the
      // currently-selected supplier's own settings (supplier_order_settings/),
      // Seller/VS read their own org's (seller/payment_settings/). Fetched
      // before the sheet's content settles so the payment-method row can
      // gate "Дансаар" on can_pay_by_transfer from the first frame that
      // matters, instead of only after the user might have already tapped it.
      if (_isPharm) {
        await cart.getSupplierOrderSettings();
        await _loadBranches();
      } else {
        await cart.getSellerPaymentSettings();
      }
    });
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
    // Already restored from home.orderBranch in initState — don't override
    // a remembered selection with the auto-picked default.
    if (_sector.id != -1) return;
    if (home.branches.length == 1) {
      _setBranch(home.branches[0]);
    } else {
      final main = home.branches.where((e) => e.isMain == true).firstOrNull;
      if (main != null) _setBranch(main);
    }
  }

  void _setBranch(Sector s) {
    setState(() {
      _sector = s;
      phoneController.text = s.phone ?? '';
      phone2Controller.text = s.phone2 ?? '';
    });
    context.read<HomeProvider>().setOrderBranch(s);
  }

  @override
  Widget build(BuildContext context) {
    final home = context.read<HomeProvider>();
    final cart = context.read<CartProvider>();
    // Recomputed every build so it always reflects the current deliveryType
    // (the branch step only exists for 'D') — safe to key off _step
    // directly with no clamping: deliveryType can only change while step 0
    // itself is showing (its chips only render there), so _step can never
    // end up pointing at a branch step that just stopped existing.
    final steps = _buildSteps(home, cart);
    final step = steps[_step];
    final isLastStep = _step == steps.length - 1;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .92),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Stack, not just a trailing widget in the Column: a Positioned close
      // button sits above everything else, so it stays fixed in place no
      // matter which step is showing or how far its content is scrolled.
      child: Stack(
        children: [
          // Whole thing (header + current step + nav buttons) in one
          // scrollable column that sizes to its own content — not a fixed
          // near-full-screen height regardless of step. Short steps (e.g.
          // payment type) make a short sheet; a long one (e.g. many
          // branches, or the note field) scrolls within the .92 cap below
          // instead of everything being stretched to fill it either way.
          Scrollbar(
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
                  const SizedBox(height: 16),
                  _stepProgress(_step, steps.length, step.title),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: KeyedSubtree(key: ValueKey(step.title), child: step.content),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 10,
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _step--),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Буцах'),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: !isLastStep
                            ? CustomButton(
                                text: 'Дараах',
                                ontap: () {
                                  if (!step.canAdvance()) {
                                    messageWarning(step.validationMessage);
                                    return;
                                  }
                                  setState(() => _step++);
                                },
                              )
                            : _loading
                                ? const LoadingButton()
                                : CustomButton(
                                    text: 'Захиалга үүсгэх',
                                    ontap: () => _submit(home, cart),
                                  ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step definitions ─────────────────────────────────────────────────

  Widget _stepProgress(int step, int total, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(
              '${step + 1}/$total',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (step + 1) / total,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            color: primary,
          ),
        ),
      ],
    );
  }

  // PA: delivery type -> branch (only if deliveryType == 'D') -> payment
  // type -> note, last. Seller/VS: customer -> payment type -> note, last.
  // Note is always the final step on both — never interleave it earlier.
  List<_OrderStep> _buildSteps(HomeProvider home, CartProvider cart) {
    if (_isPharm) {
      return [
        _OrderStep(
          title: 'Хүргэлтийн нөхцөл',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _supplierInfo(home),
              const SizedBox(height: 20),
              BottomSheetLabelBuilder('Хүргэлтийн нөхцөл'),
              const SizedBox(height: 10),
              _deliveryChips(),
            ],
          ),
          canAdvance: () => deliveryType.isNotEmpty,
          validationMessage: 'Хүргэлтийн хэлбэр сонгоно уу!',
        ),
        if (deliveryType == 'D')
          _OrderStep(
            title: 'Хүргэлт хийх салбар',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
            canAdvance: () => _sector.id != -1,
            validationMessage: 'Салбар сонгоно уу!',
          ),
        _OrderStep(
          title: 'Төлбөрийн хэлбэр',
          content: _paymentStepContent(cart),
          canAdvance: () => payType.isNotEmpty,
          validationMessage: 'Төлбөрийн хэлбэр сонгоно уу!',
        ),
        _OrderStep(
          title: 'Нэмэлт тайлбар',
          content: _noteStepContent(home),
          canAdvance: () => true,
          validationMessage: '',
        ),
      ];
    }
    return [
      _OrderStep(
        title: 'Захиалагч сонгох',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BottomSheetLabelBuilder('Захиалагч сонгох'),
            const SizedBox(height: 12),
            _customerSelector(home),
          ],
        ),
        canAdvance: () => home.customer != null,
        validationMessage: 'Захиалагч сонгоно уу!',
      ),
      _OrderStep(
        title: 'Төлбөрийн хэлбэр',
        content: _paymentStepContent(cart),
        canAdvance: () => payType.isNotEmpty,
        validationMessage: 'Төлбөрийн хэлбэр сонгоно уу!',
      ),
      _OrderStep(
        title: 'Нэмэлт тайлбар',
        content: _noteStepContent(home),
        canAdvance: () => true,
        validationMessage: '',
      ),
    ];
  }

  Widget _paymentStepContent(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: _availablePaymentMethods(cart)
              .map((pm) => Expanded(
                    child: BottomSheetOptionChip(
                      title: pm.name,
                      v: pm.value,
                      icon: pm.icon,
                      isSelected: payType == pm.value,
                      onTap: () {
                        setState(() => payType = pm.value);
                        if (_isPharm) {
                          context.read<HomeProvider>().setOrderPayType(pm.value);
                        }
                      },
                    ),
                  ))
              .toList(),
        ),
        if (payType == 'T' && cart.paymentSettings != null) ...[
          const SizedBox(height: 10),
          _bankAccountsCard(cart.paymentSettings!),
        ],
      ],
    );
  }

  Widget _noteStepContent(HomeProvider home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BottomSheetLabelBuilder('Нэмэлт тайлбар (заавал биш)'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            textInputAction: TextInputAction.done,
            controller: noteController,
            onChanged: (v) => home.setNote(v),
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Энд тайлбар бичиж болно...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────

  // "Дансаар" (T) is only ever valid when the relevant supplier's
  // can_pay_by_transfer says so — it's already the AND of "the supplier
  // left the option on" and "has a bank account on file", so it must be
  // read as-is rather than re-derived from bankAccounts. Offering T
  // anyway gets a 400 from the order endpoints at submit time instead of
  // a clean, upfront "not offered".
  List<PayType> _availablePaymentMethods(CartProvider cart) {
    if (cart.isCashOnlyBasket) return [PayType.cash];
    final canPayByTransfer = cart.paymentSettings?.canPayByTransfer ?? false;
    return paymentMethods.where((pm) => pm != PayType.transAccount || canPayByTransfer).toList();
  }

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
                  onTap: () {
                    setState(() => deliveryType = dm['v']!);
                    context.read<HomeProvider>().setOrderDeliveryType(dm['v']!);
                  },
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Scrollbar(
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
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ),
            ],
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
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
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
    );
    if (!confirmed) return;
    if (!mounted) return;
    setState(() => _loading = true);
    if (payType == 'C' || payViaQpay) {
      await cart.createQR(
          branchId: _sector.id, note: noteController.text, deliveryType: deliveryType);
    } else {
      await cart.createOrder(
        context,
        branchId: _sector.id,
        note: noteController.text,
        deliveryType: deliveryType,
        payType: payType,
      );
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
    if (!mounted) return;
    setState(() => _loading = true);
    // seller/order/ (not the pharmacist ci/ draft-invoice flow) always
    // creates the order regardless of payType - it auto-attaches a QPay
    // invoice itself when the basket needs one, so there is no separate
    // "pay by qpay" branch here anymore: recording the sale must never
    // wait on payment.
    await cart.createOrder(context, payType: payType);
    if (mounted) setState(() => _loading = false);
  }
}

/// One page of OrderSheet's stepper — title for the progress header,
/// the step's own content, and a gate the "Дараах" button checks before
/// advancing (with the warning message to show when it's not satisfied).
class _OrderStep {
  final String title;
  final Widget content;
  final bool Function() canAdvance;
  final String validationMessage;

  const _OrderStep({
    required this.title,
    required this.content,
    required this.canAdvance,
    required this.validationMessage,
  });
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
