import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/login/login.dart';
import 'package:pharmo_app/authentication/root/root_provider.dart';
import 'package:pharmo_app/authentication/root/splash_screen.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await readUser(),
    );
  }

  Future readUser() async {
    final rooter = context.read<RootProvider>();
    await rooter.readUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RootProvider>(
      builder: (context, rooter, child) {
        AuthState state = rooter.state;

        if (state == AuthState.notSplashed) {
          return SplashScreen();
        }
        if (state == AuthState.unknown) {
          return PharmoIndicator(withMaterial: true);
        }
        if (state == AuthState.notLoggedIn || state == AuthState.expired) {
          return LoginPage();
        }

        final security = Authenticator.security;

        if (security == null) return LoginPage();
        return RoleConfig.getHomePage(security.userRole);
      },
    );
  }
}
