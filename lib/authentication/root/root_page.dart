import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/login/login.dart';
import 'package:pharmo_app/authentication/login/pre_login_page.dart';
import 'package:pharmo_app/authentication/root/root_provider.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/update_dialog.dart';
import 'package:upgrader/upgrader.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await UpdateDialog.showIfNeeded(context, updater);
    });
  }

  final updater = Upgrader();

  Future readUser() async {
    final rooter = context.read<RootProvider>();
    await rooter.readUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RootProvider>(
      builder: (context, rooter, child) {
        AuthState state = rooter.state;

        if (state == AuthState.unknown || state == AuthState.notSplashed) {
          return PharmoSplashScreen(
            onFinished: () async {
              await Authenticator.saveSplashed(true);
              if (mounted) await rooter.readUser();
            },
          );
        }
        if (state == AuthState.notLoggedIn || state == AuthState.expired) {
          if (rooter.loginHistory.isNotEmpty) {
            return PreLoginPage(history: rooter.loginHistory);
          }
          return LoginPage();
        }

        final security = Authenticator.security;

        if (security == null) return LoginPage();
        return RoleConfig.getHomePage(security.userRole);
      },
    );
  }
}
