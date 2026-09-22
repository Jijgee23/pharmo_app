import 'package:pharmo_app/application/application.dart';

class AddCustomer extends StatelessWidget {
  const AddCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernIcon(
      iconData: Icons.person_add_alt_1_rounded,
      color: const Color(0xFF00897B),
      onPressed: () => Get.to(() => const AddCustomerScreen()),
    );
  }
}

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rn = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();

  String _nameInitial = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      final v = _name.text.trim();
      final initial = v.isNotEmpty ? v[0].toUpperCase() : '';
      if (initial != _nameInitial) setState(() => _nameInitial = initial);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PharmProvider>().getZones();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _rn.dispose();
    _email.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty ||
        _rn.text.isEmpty ||
        _email.text.isEmpty ||
        _phone.text.isEmpty) {
      messageWarning('Бүртгэл гүйцээнээ үү!');
      return;
    }
    setState(() => _loading = true);
    final pp = context.read<PharmProvider>();
    final home = context.read<HomeProvider>();
    final cust = await pp.registerCustomer(
      _name.text,
      _rn.text,
      _email.text,
      _phone.text,
      _note.text,
      home.currentLatitude.toString(),
      home.currentLongitude.toString(),
      context,
    );
    if (cust) {
      setState(() => _loading = false);
      await pp.fetchCustomers();
      if (!mounted) return;
      Navigator.pop(context);
    }
    if (mounted) {
      setState(() => _loading = false);
    }
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
        title: const Text(
          'Харилцагч бүртгэх',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Consumer<PharmProvider>(
        builder: (context, pp, _) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              _AvatarHeader(initial: _nameInitial, primary: primary),
              const SizedBox(height: 20),
              _Section(
                title: 'Үндсэн мэдээлэл',
                children: [
                  Input(
                    controller: _name,
                    hint: 'Нэр',
                    icon: Icons.person_outline_rounded,
                  ),
                  Input(
                    controller: _rn,
                    hint: 'Регистрийн дугаар',
                    icon: Icons.badge_outlined,
                  ),
                  Input(
                    controller: _email,
                    hint: 'И-мейл',
                    icon: Icons.email_outlined,
                    keyType: TextInputType.emailAddress,
                  ),
                  Input(
                    controller: _phone,
                    hint: 'Утасны дугаар',
                    icon: Icons.phone_outlined,
                    keyType: TextInputType.phone,
                  ),
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
              if (pp.zones.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Section(
                  title: 'Бүс сонгоно уу',
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
                  loading: _loading, onTap: _submit, primary: primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  final String initial;
  final Color primary;
  const _AvatarHeader({required this.initial, required this.primary});

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
            'Дурын харилцагч бүртгэх',
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
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                color: Colors.grey.shade500,
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
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class Input extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyType;
  final int maxLines;

  const Input({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<Input> createState() => InputState();
}

class InputState extends State<Input> {
  final _focus = FocusNode();
  bool _focused = false;

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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: _focused ? primary.withOpacity(0.03) : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Icon(
            widget.icon,
            size: 20,
            color: _focused ? primary : Colors.grey.shade400,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: widget.keyType,
              maxLines: widget.maxLines,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
          ),
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
  final bool loading;
  final VoidCallback onTap;
  final Color primary;

  const _SubmitButton(
      {required this.loading, required this.onTap, required this.primary});

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
              : const Text(
                  'Бүртгэх',
                  style: TextStyle(
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
