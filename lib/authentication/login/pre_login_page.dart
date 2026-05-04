import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/login/login.dart';

class PreLoginPage extends StatefulWidget {
  final List<Map<String, String>> history;
  const PreLoginPage({super.key, required this.history});

  @override
  State<PreLoginPage> createState() => _PreLoginPageState();
}

class _PreLoginPageState extends State<PreLoginPage> with SingleTickerProviderStateMixin {
  late List<Map<String, String>> _history;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _history = List.from(widget.history);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _removeEntry(String identifier) async {
    await Authenticator.removeFromHistory(identifier);
    setState(() {
      _history.removeWhere((e) => e['identifier'] == identifier);
    });
    if (_history.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  void _selectUser(String identifier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(prefillIdentifier: identifier),
      ),
    );
  }

  void _addNewUser() {
    final auth = context.read<AuthController>();
    auth.ema.clear();
    auth.pass.clear();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage(prefillIdentifier: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  Text(
                    'Бүртгэл сонгоно уу',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._history.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + i * 80),
                      curve: Curves.easeOutCubic,
                      builder: (ctx, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: _UserCard(
                        identifier: e['identifier'] ?? '',
                        name: e['name'] ?? '',
                        onTap: () => _selectUser(e['identifier'] ?? ''),
                        onRemove: () => _removeEntry(e['identifier'] ?? ''),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _AddNewButton(onTap: _addNewUser),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFF00695C)],
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(64),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset('assets/picon.png', width: 72),
              ),
              const SizedBox(height: 14),
              const Text(
                'Сайн уу!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pharmo',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String identifier;
  final String name;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _UserCard({
    required this.identifier,
    required this.name,
    required this.onTap,
    required this.onRemove,
  });

  String get _avatarLetter {
    if (name.isNotEmpty) return name[0].toUpperCase();
    if (identifier.isNotEmpty) return identifier[0].toUpperCase();
    return '?';
  }

  String get _maskedIdentifier {
    if (identifier.contains('@')) {
      final at = identifier.indexOf('@');
      final user = identifier.substring(0, at);
      final domain = identifier.substring(at);
      if (user.length <= 3) return identifier;
      return '${user.substring(0, 3)}***$domain';
    }
    if (identifier.length > 6) {
      return '${identifier.substring(0, 3)}***${identifier.substring(identifier.length - 2)}';
    }
    return identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8F5F3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primary.withOpacity(0.65)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : identifier,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A2B2B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _maskedIdentifier,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Нэвтрэх',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddNewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: primary.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(12),
            color: primary.withOpacity(0.04),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Өөр бүртгэлээр нэвтрэх',
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
