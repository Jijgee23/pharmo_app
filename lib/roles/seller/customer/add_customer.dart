import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/application/settings/services/taxpayer_lookup.dart';

class AddCustomer extends StatelessWidget {
  const AddCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernIcon(
      iconData: Icons.person_add_alt_1_rounded,
      color: const Color(0xFF00897B),
      onPressed: () => Get.to(() => const CustomerFormScreen()),
    );
  }
}

/// Registers a new customer, or edits [customer] when one is given: the
/// same fields, checks and register lookup either way.
class CustomerFormScreen extends StatefulWidget {
  final CustomerDetail? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rn = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _phone3 = TextEditingController();
  final _note = TextEditingController();

  bool get _editing => widget.customer != null;

  String _nameInitial = '';
  bool _loading = false;

  // Register lookup in e-barimt: fills in the name once a complete register
  // number has been typed.
  Timer? _lookupDebounce;
  String _lookedUp = '';
  _Lookup _lookup = _Lookup.idle;
  Taxpayer? _taxpayer;

  /// The name last filled in from the lookup. A name the user typed is never
  /// overwritten; one we filled in may be.
  String _filledName = '';

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer != null) {
      _name.text = customer.name ?? '';
      _rn.text = customer.rn ?? '';
      _email.text = customer.email ?? '';
      _phone.text = customer.phone ?? '';
      _phone2.text = customer.phone2 ?? '';
      _phone3.text = customer.phone3 ?? '';
      _note.text = customer.note ?? '';
      final name = _name.text.trim();
      _nameInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
      // The number on file isn't looked up again, only one changed to.
      _lookedUp = TaxpayerLookup.normalize(_rn.text);
    }
    _name.addListener(() {
      final v = _name.text.trim();
      final initial = v.isNotEmpty ? v[0].toUpperCase() : '';
      if (initial != _nameInitial) setState(() => _nameInitial = initial);
    });
    _rn.addListener(_onRegisterChanged);
    // The zone is only chosen when registering.
    if (!_editing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PharmProvider>().getZones();
      });
    }
  }

  void _onRegisterChanged() {
    final register = TaxpayerLookup.normalize(_rn.text);
    if (register == _lookedUp) return;
    _lookupDebounce?.cancel();
    _lookedUp = '';
    if (_lookup != _Lookup.idle) setState(() => _lookup = _Lookup.idle);
    if (!TaxpayerLookup.isRegister(register)) return;
    _lookupDebounce =
        Timer(const Duration(milliseconds: 400), () => _lookUp(register));
  }

  Future<void> _lookUp(String register) async {
    setState(() {
      _lookedUp = register;
      _lookup = _Lookup.loading;
    });
    Taxpayer? taxpayer;
    var result = _Lookup.notFound;
    try {
      taxpayer = await TaxpayerLookup.byRegister(register);
      if (taxpayer != null) result = _Lookup.found;
    } catch (e) {
      debugPrint('taxpayer lookup failed: $e');
      result = _Lookup.failed;
    }
    // The number was changed while this one was being looked up.
    if (!mounted || _lookedUp != register) return;
    setState(() {
      _lookup = result;
      _taxpayer = taxpayer;
      final current = _name.text.trim();
      if (taxpayer != null && (current.isEmpty || current == _filledName)) {
        _useTaxpayerName();
      }
    });
  }

  void _useTaxpayerName() {
    final name = _taxpayer!.name;
    _name.text = name;
    _filledName = name;
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _name.dispose();
    _rn.dispose();
    _email.dispose();
    _phone.dispose();
    _phone2.dispose();
    _phone3.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Set by the first submit: from then on each field re-checks as it
  /// changes, so its red marking goes away as soon as it is filled in.
  bool _submitted = false;

  static String? _required(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  /// Checked only when filled in.
  static String? Function(String?) _optional(
    String? Function(String?) validate,
  ) =>
      (v) => (v ?? '').trim().isEmpty ? null : validate(v);

  bool _zoneMissing(PharmProvider pp) =>
      !_editing && pp.zones.isNotEmpty && pp.selectedZone.id == -1;

  Future<void> _submit() async {
    final pp = context.read<PharmProvider>();
    // Every field is checked, so all the missing ones turn red at once.
    final fieldsOk = _formKey.currentState!.validate();
    setState(() => _submitted = true);
    if (!fieldsOk || _zoneMissing(pp)) return;
    setState(() => _loading = true);
    try {
      final customer = widget.customer;
      if (customer == null) {
        final saved = await pp.registerCustomer(
          name: _name.text.trim(),
          rn: _rn.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text,
          note: _note.text,
          context: context,
        );
        if (!saved) return;
        // Show the new customer in the tab's list (its search kept).
        await pp.customers.search();
      } else {
        final saved = await pp.editCustomer(
          id: customer.id!,
          name: _name.text.trim(),
          rn: _rn.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text,
          phone2: _phone2.text,
          phone3: _phone3.text,
          note: _note.text,
        );
        if (!saved) return;
        // The details page shows what was just saved.
        await pp.getCustomerDetail(customer.id!);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget? _lookupIndicator(Color primary) {
    return switch (_lookup) {
      _Lookup.loading => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      _Lookup.found => Icon(Icons.verified_rounded, size: 20, color: primary),
      _ => null,
    };
  }

  // Under the register field: what the lookup found, or why nothing was.
  Widget _lookupStatus(Color primary) {
    final taxpayer = _taxpayer;
    final (IconData icon, Color color, String text) = switch (_lookup) {
      _Lookup.loading => (
          Icons.search_rounded,
          Colors.grey.shade500,
          'Татварын бүртгэлээс хайж байна…'
        ),
      _Lookup.found => (
          Icons.check_circle_rounded,
          primary,
          '${taxpayer!.name} · ТТД ${taxpayer.tin}'
        ),
      _Lookup.failed => (
          Icons.wifi_off_rounded,
          Colors.orange.shade700,
          'Татварын бүртгэлтэй холбогдож чадсангүй. Нэрээ гараар оруулна уу.'
        ),
      _ => (
          Icons.info_outline_rounded,
          Colors.grey.shade600,
          'Татварын бүртгэлээс олдсонгүй. Нэрээ гараар оруулна уу.'
        ),
    };
    // A name the user typed differs from the register's: offer to switch.
    final canUseName = taxpayer != null &&
        _lookup == _Lookup.found &&
        _name.text.trim() != taxpayer.name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: color, height: 1.3)),
          ),
          if (canUseName)
            TextButton(
              onPressed: () => setState(_useTaxpayerName),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: context.theme.textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Нэрийг ашиглах'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        title: Text(
          _editing ? 'Харилцагч засах' : 'Харилцагч бүртгэх',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Consumer<PharmProvider>(
        builder: (context, pp, _) => Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          // Not a ListView: that drops fields scrolled far off screen, and
          // Form.validate() only checks the fields that are built.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AvatarHeader(
                  initial: _nameInitial,
                  primary: primary,
                  caption: _editing
                      ? 'Харилцагчийн мэдээлэл засах'
                      : 'Дурын харилцагч бүртгэх',
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Үндсэн мэдээлэл',
                  children: [
                    // First, so the name can be filled in from it.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Input(
                          controller: _rn,
                          hint: 'Регистрийн дугаар',
                          icon: Icons.badge_outlined,
                          capitalization: TextCapitalization.characters,
                          suffix: _lookupIndicator(primary),
                          required: true,
                          validator: (v) =>
                              _required(v, 'Регистрийн дугаар оруулна уу'),
                        ),
                        if (_lookup != _Lookup.idle) _lookupStatus(primary),
                      ],
                    ),
                    Input(
                      controller: _name,
                      hint: 'Нэр',
                      icon: Icons.person_outline_rounded,
                      required: true,
                      validator: (v) => _required(v, 'Нэр оруулна уу'),
                    ),
                    Input(
                      controller: _phone,
                      hint: 'Утасны дугаар',
                      icon: Icons.phone_outlined,
                      keyType: TextInputType.phone,
                      required: true,
                      validator: validatePhone,
                    ),
                    // Optional for the API; checked only when filled in.
                    Input(
                      controller: _email,
                      hint: 'И-мейл',
                      icon: Icons.email_outlined,
                      keyType: TextInputType.emailAddress,
                      validator: _optional(validateEmail),
                    ),
                    if (_editing) ...[
                      Input(
                        controller: _phone2,
                        hint: 'Нэмэлт утас 1',
                        icon: Icons.phone_enabled_outlined,
                        keyType: TextInputType.phone,
                        validator: _optional(validatePhone),
                      ),
                      Input(
                        controller: _phone3,
                        hint: 'Нэмэлт утас 2',
                        icon: Icons.phone_enabled_outlined,
                        keyType: TextInputType.phone,
                        validator: _optional(validatePhone),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _Section(
                  title: 'Нэмэлт мэдээлэл',
                  children: [
                    Input(
                      controller: _note,
                      hint: 'Тайлбар (заавал биш)',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
                if (!_editing && pp.zones.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Бүс сонгоно уу',
                    error: _submitted && _zoneMissing(pp)
                        ? 'Харилцагчийн бүсийг сонгоно уу'
                        : null,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pp.zones
                            .map((z) => _ZoneChip(
                                  zone: z,
                                  selected: pp.selectedZone == z,
                                  primary: primary,
                                  onTap: () => pp.setZone(z),
                                ))
                            .toList(),
                      ).marginOnly(left: 16),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                _SubmitButton(
                  label: _editing ? 'Хадгалах' : 'Бүртгэх',
                  loading: _loading,
                  onTap: _submit,
                  primary: primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Lookup { idle, loading, found, notFound, failed }

class _AvatarHeader extends StatelessWidget {
  final String initial;
  final Color primary;
  final String caption;
  const _AvatarHeader({
    required this.initial,
    required this.primary,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: initial.isEmpty
                    ? [Colors.grey.shade200, Colors.grey.shade300]
                    : [primary.withOpacity(0.7), primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: initial.isEmpty
                  ? []
                  : [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                initial.isEmpty ? '' : initial,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: initial.isEmpty ? Colors.grey.shade400 : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// Outlines the section in red with this message under it, e.g. for a
  /// required choice not made.
  final String? error;

  const _Section({required this.title, required this.children, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: error == null
            ? null
            : Border.all(color: Colors.red.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    error == null ? Colors.grey.shade500 : Colors.red.shade600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ...children.asMap().entries.map((e) {
            final isLast = e.key == children.length - 1;
            return Column(
              spacing: 16,
              children: [
                e.value,
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 52,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ErrorLine(error!),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String text;
  const _ErrorLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline_rounded, size: 15, color: Colors.red.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
        ),
      ],
    );
  }
}

class Input extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyType;
  final int maxLines;
  final TextCapitalization capitalization;

  /// Shown at the end of the field, e.g. a lookup's progress.
  final Widget? suffix;

  /// Marks the hint with a red asterisk.
  final bool required;

  /// Checked by the enclosing Form; a message turns the field red and shows
  /// under it.
  final String? Function(String?)? validator;

  const Input({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyType = TextInputType.text,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.suffix,
    this.required = false,
    this.validator,
  });

  @override
  State<Input> createState() => InputState();
}

class InputState extends State<Input> {
  final _focus = FocusNode();
  bool _focused = false;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  // Runs the validator, and tints the whole row while it reports a problem.
  // Validators run during a build, hence the post-frame update.
  String? _validate(String? value) {
    final error = widget.validator!(value);
    if ((error != null) != _invalid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _invalid = error != null);
      });
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final red = Colors.red.shade600;
    final hintStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w400,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: _invalid
          ? Colors.red.withValues(alpha: 0.05)
          : _focused
              ? primary.withValues(alpha: 0.03)
              : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Icon(
            widget.icon,
            size: 20,
            color: _invalid
                ? red
                : _focused
                    ? primary
                    : Colors.grey.shade400,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: widget.keyType,
              textCapitalization: widget.capitalization,
              maxLines: widget.maxLines,
              validator: widget.validator == null ? null : _validate,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: widget.required ? null : widget.hint,
                hint: widget.required
                    ? Text.rich(
                        TextSpan(
                          text: widget.hint,
                          style: hintStyle,
                          children: [
                            TextSpan(text: ' *', style: TextStyle(color: red)),
                          ],
                        ),
                      )
                    : null,
                hintStyle: hintStyle,
                errorStyle: TextStyle(fontSize: 12, color: red),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final Zone zone;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.zone,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              zone.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final Color primary;

  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: loading
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [const Color(0xFF26A69A), primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: primary.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
